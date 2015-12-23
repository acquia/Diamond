# Copyright 2015 Acquia, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'set'

require 'aws-sdk'
require 'base64'
require 'rbnacl'

class SecretsDisabledError < StandardError; end

class SecretsHelper
  attr_reader :stack

  # @param [Aws::CloudFormation::Stack] A stack which contains the current instance.
  # @return [SecretsHelper]
  def initialize(stack)
    @stack = stack
  end

  # @return [Boolean] true if secrets are enabled for this stack
  def enabled?
    # Stacks with bootstrap secrets enabled have the KMS reader policy
    # as a parameter.
    stack.parameters.any? { |p| p.parameter_key == Nemesis::Secrets::KMS_READER_POLICY_NAME }
  end

  def get(secret_key)
    raise SecretsDisabledError.new("Secrets not enabled for stack #{stack.stack_name}") unless enabled?
    box.load_secret(secret_key)
  end

  private

  def box
    @box ||= Nemesis::Secrets::BootstrapBox.new(stack.stack_name)
  end
end

# TODO: The code below comes directly from the Nemesis codebase. We
# could use a more elegant means of referencing it from nemesis-puppet.
#
# Our most likely strategy for solving this is to replace all this with a
# Go-based secrets tool that we use to retrieve our custom Puppet facts.

module Nemesis
  module Secrets
    class KeyError < StandardError; end
    class StackNotFoundError < StandardError; end
    class SecretNotFoundError < StandardError; end

    # 'Subdirectory' of the S3 bucket where secrets are stored.
    SECRETS_PREFIX = 'secrets'

    # Key of a sentinel object that lives in the secrets S3 bucket.
    SECRETS_SENTINEL_KEY = SECRETS_PREFIX + '/README'

    # Name of the Nemesis KMS key CloudFormation resource.
    KMS_KEY_NAME = 'SecretsKey'
    # Name of the Nemesis KMS-key-reader-policy CloudFormation resource.
    KMS_READER_POLICY_NAME = 'SecretsReaderPolicy'

    # Check the given key to make sure it matches the allowed format
    # for secrets keys.
    #
    # With two exceptions, we require keys to be composed of the 'safe
    # characters for S3 object key names'; see
    # http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingMetadata.html
    #
    # The exceptions are that we permit forward slashes ('/') in
    # secret key names -- because conceptualizing keyspaces as paths
    # has a long history -- and to accommodate this we disallow apostrophes
    # ("'") so that we can internally represent slashes as apostrophes.
    #
    # @param [String] candidate_key Potential key for identifying a secret.
    # @return [Boolean] If the key has the allowed format.
    def self.key_format_correct?(candidate_key)
      candidate_key =~ %r{\A[-.*\(\)/A-Za-z0-9!_]+\z} ? true : false
    end

    # Transform the given key from its publicly-visible format to the
    # internal format used for storage.
    def self.canonicalize_key(key)
      raise KeyError.new('Secret key is not in the permitted format') unless key_format_correct?(key)
      key.tr('/', '\'')
    end

    # Transform the given key from its internal format to the
    # publicly-visible key format.
    def self.decanonicalize_key(key)
      raise KeyError.new('Secret key cannot be nil') if key.nil?
      raise KeyError.new('Secret key internal format contains slashes') if key.include?('/')
      k = key.tr('\'', '/')
      raise KeyError.new('Secret key is not in the permitted format') unless key_format_correct?(k)
      k
    end

    # Given a secrets key in the correct format, return the
    # S3 object key for that secret.
    def self.object_key_for_secret(secret_key)
      "#{SECRETS_PREFIX}/#{canonicalize_key(secret_key)}"
    end

    # Stores secrets, in a very simple single-namespace fashion,
    # in an S3 bucket with a given KMS key.
    class SimpleS3Box
      extend Forwardable
      def_delegators :bucket, :object, :objects, :put_object
      def_delegator :decrypter, :decrypt

      attr_reader :bucket_name

      def initialize(bucket_name)
        @bucket_name = bucket_name
      end

      def bucket
        @bucket ||= ::Aws::S3::Resource.new.bucket(bucket_name)
      end

      def encrypter(kms_key_id)
        @encrypter ||= {}
        @encrypter[kms_key_id] ||= Encrypter.new(kms_key_id)
      end

      def decrypter
        @decrypter ||= Decrypter.new
      end

      # Encrypts a message with a per-message key and returns the
      # result as JSON ready to be saved to S3
      def secret_to_json(secret_key, secret_value, kms_key_id, context)
        {
          'secret_key' => secret_key,
          'context' => context,
          'message' => encrypter(kms_key_id).encrypt(secret_value, context)
        }.to_json
      end

      def save_secret(secret_key, secret_value, kms_key_id, context = {})
        put_object(
          key: Nemesis::Secrets.object_key_for_secret(secret_key),
          body: secret_to_json(secret_key, secret_value, kms_key_id, context)
        )
      end

      def load_secret(secret_key)
        obj = object(Nemesis::Secrets.object_key_for_secret(secret_key))
        raise SecretNotFoundError.new unless obj.exists?
        msg = JSON.parse(obj.get.body.read)
        decrypt(msg['message'], msg['context'])
      end

      def list_secret_keys
        keys = objects(prefix: "#{Nemesis::Secrets::SECRETS_PREFIX}/").map do |o|
          next if o.key == Nemesis::Secrets::SECRETS_SENTINEL_KEY
          next unless o.key =~ %r{\A#{Nemesis::Secrets::SECRETS_PREFIX}\/(.*)\z}
          Nemesis::Secrets.decanonicalize_key($1)
        end
        keys.compact.sort
      end
    end

    # Stores bootstrap secrets for a particular Nemesis repo stack.
    #
    # This Box is very Nemesis-specific and understands stacks,
    # options, and parameters. It wraps a more basic Box that doesn't
    # need to know any of the Nemesis stuff.
    class BootstrapBox
      attr_reader :stack_name, :context

      def initialize(stack_name, context = {})
        @stack_name = stack_name
        @context = { writer: '*', reader: '*' }.merge(context)
      end

      def stack
        return @stack if @stack
        @stack = ::Aws::CloudFormation::Resource.new.stack(stack_name)
        # Will raise an error if the stack does not exist:
        @stack.stack_status
        @stack
      rescue ::Aws::CloudFormation::Errors::ValidationError => e
        raise StackNotFoundError.new(e.message)
      end

      def kms_key_id
        output(Nemesis::Secrets::KMS_KEY_NAME)
      end

      def bucket_name
        parameter('RepoS3') || output('RepoMirrorS3BucketName')
      end

      def storage_box
        @storage_box ||= SimpleS3Box.new(bucket_name)
      end

      def save_secret(secret_key, secret_value)
        storage_box.save_secret(secret_key, secret_value, kms_key_id, context)
      end

      def load_secret(secret_key)
        storage_box.load_secret(secret_key)
      end

      def list_secret_keys
        storage_box.list_secret_keys
      end

      private

      def output(key)
        output = stack.outputs.find { |o| o.output_key == key }
        output ? output.output_value : nil
      end

      def parameter(key)
        param = stack.parameters.find { |p| p.parameter_key == key }
        param ? param.parameter_value : nil
      end
    end

    # Abstract base class for KMS encryption objects.
    class Engine
      def kms
        @kms ||= ::Aws::KMS::Client.new
      end
    end

    # Encrypts secrets using KMS and libsodium.
    #
    # KMS only supports secrets up to 4k in size, so to be able to
    # handle larger values we use libsodium (via the rbnacl gem) to
    # provide well-designed symmetric crypto and then use KMS just to
    # store the key, according to the GenerateDataKey pattern
    # recommended by KMS itself.
    #
    # See: https://github.com/cryptosphere/rbnacl
    # See: http://nacl.cr.yp.to/index.html
    class Encrypter < Engine
      attr_reader :key_id

      def initialize(kms_key_id)
        raise KeyError.new('Must provide a non-nil KMS key ID to an Encrypter') if kms_key_id.nil? || kms_key_id.empty?
        super()
        @key_id = kms_key_id
      end

      # Generate a per-message data key using KMS.
      def generate_data_key(context = {})
        kms.generate_data_key(
          key_id: key_id,
          number_of_bytes: RbNaCl::SecretBox.key_bytes,
          encryption_context: context)
      end

      def encrypt(plaintext, context = {})
        # Generate a unique key for this secret
        data_key = generate_data_key(context)
        box = RbNaCl::SimpleBox.from_secret_key(data_key.plaintext)
        ciphertext = box.encrypt(plaintext)
        # TODO: At this point, it would be nice to definitively remove
        # the plaintext data_key from system memory. Can we do that in
        # Ruby? Having it wait around to be garbage-collected is not
        # optimal for security.
        { 'data_key' => Base64.encode64(data_key.ciphertext_blob),
          'ciphertext' => Base64.encode64(ciphertext) }
      end
    end

    # Decrypts secrets that were encrypted by an Encrypter.
    #
    # Unlike Encrypter, this class does not require a specific KMS
    # key.  KMS-encrypted ciphertexts include an internal pointer to
    # their key. However, it is essential that the AWS user calling
    # this Decrypter have "Decrypt" permission on the key for the
    # message being decrypted, or an error will be raised.
    class Decrypter < Engine
      def decrypt(encrypted_data, context = {})
        data_key = kms.decrypt(
          ciphertext_blob: Base64.decode64(encrypted_data['data_key']),
          encryption_context: context)
        box = RbNaCl::SimpleBox.from_secret_key(data_key.plaintext)
        box.decrypt(Base64.decode64(encrypted_data['ciphertext']))
      end
    end
  end
end
