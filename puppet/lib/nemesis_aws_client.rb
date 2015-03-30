require 'aws-sdk-v1'

module NemesisAwsClient
  include AWS
  # Monkey-patch to make the back-off much longer
  module AWS::Core

    # Base client class for all of the Amazon AWS service clients.
    class Client

      ############################
      # Keep these private
      private

      def sleep_durations(response)
        if expired_credentials?(response)
          [0]
        else
          factor = scaling_factor(response)
          # Change this to use n + 2 instead of n so
          # we have a 4x larger delay than the stock SDK.
          Array.new(config.max_retries) {|n| (2 ** (n + 2)) * factor }
        end
      end

      def scaling_factor(response)
        # Once the AWS API request limit is hit, it can take 60-120s for
        # requests to begin working again.  This back-off should allow that
        # to happen before giving up.
        throttled?(response) ? Kernel.rand(2.0..5.0) : Kernel.rand(0.5..2.0)
      end

    end
  end # Module AWS::Core
end
