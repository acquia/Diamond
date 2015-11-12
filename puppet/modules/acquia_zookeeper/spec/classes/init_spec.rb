require 'spec_helper'

describe 'acquia_zookeeper', :type => :class do
  it { should have_class_count(1) }

  context 'compiles' do
    let(:facts) {
      {
        :operatingsystem => 'redhat',
      }
    }
    it { should compile.with_all_deps }
  end

  context 'creates all necessary files and directories' do
    let(:zk_config_location) { 'some-bucket' }
    let(:zk_s3_prefix) { 'some-prefix' }
    let(:zk_exhibitor_aws_access_key_id) { 'some-access-key' }
    let(:zk_exhibitor_aws_secret_access_key) { 'some-secret-key' }
    let(:zk_exhibitor_ui_password) { 'some-password' }

    let(:facts) {
      {
        :zk_config_location => zk_config_location,
        :zk_s3_prefix => zk_s3_prefix,
        :zk_exhibitor_aws_access_key_id => zk_exhibitor_aws_access_key_id,
        :zk_exhibitor_aws_secret_access_key => zk_exhibitor_aws_secret_access_key,
        :zk_exhibitor_ui_password => zk_exhibitor_ui_password,
      }
    }

    it {
      should contain_file('/opt/exhibitor/web.xml')
        .with_ensure('present')
        .with_source('puppet:///modules/acquia_zookeeper/web.xml')
        .that_comes_before('Service[exhibitor]')
    }

    it {
      should contain_file('/opt/exhibitor/defaults.conf')
        .with_ensure('present')
        .with_content(/bucket-name\\=#{zk_config_location}&key-prefix\\=#{zk_s3_prefix}/)
        .that_comes_before('Service[exhibitor]')
    }

    it {
      should contain_file('/etc/init.d/exhibitor')
        .with_ensure('present')
        .with_content(/S3CONFIG=#{zk_config_location}:#{zk_s3_prefix}/)
        .with_content(%r{SECURITY="--security /opt/exhibitor/web.xml --realm Zookeeper:/opt/exhibitor/realm})
        .with_content(%r{java -jar /opt/exhibitor/exhibitor.jar .*--configtype s3})
        .with_content(%r{java -jar /opt/exhibitor/exhibitor.jar .*--s3backup true})
        .that_comes_before('Service[exhibitor]')
    }

    it {
      should contain_file('/opt/exhibitor/realm')
        .with_ensure('present')
        .with_content("admin: #{zk_exhibitor_ui_password},admin")
        .that_comes_before('Service[exhibitor]')
    }
  end

  context 'installs the correct zookeeper version' do
    let(:version) { '3.4.6' }
    it {
      should contain_package('zookeeper')
        .with_ensure(version)
        .that_notifies('Exec[refresh-zookeeper]')
    }
  end

  context 'installs the correct exhibitor version' do
    let(:version) { '1.5.5' }
    it { should contain_package('zookeeper-exhibitor').with_ensure(version) }
    it { should contain_service('exhibitor').with_ensure('running') }
  end

  context 'restarts zookeeper on a version change' do
    it {
      should contain_exec('refresh-zookeeper')
        .with_refreshonly(true)
        .with_require('Service[exhibitor]')
    }
  end
end
