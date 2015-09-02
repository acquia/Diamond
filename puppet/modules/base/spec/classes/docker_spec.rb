require 'spec_helper'

describe 'base::docker' do
  let(:facts) do |_|
    {
      lsbdistcodename: 'trusty',
      lsbdistdescription: 'Ubuntu 14.04.2 LTS',
      lsbdistid: 'Ubuntu',
      lsbdistrelease: '14.04',
      lsbmajdistrelease: '14.04',
      osfamily: 'Debian',
      operatingsystem: 'Ubuntu',
    }
  end

  describe 'docker puppet module' do
    it {
      should contain_class('base::docker')

      should contain_apt__pin('docker')

      should contain_package('apparmor')
      should contain_package('apt-transport-https')
      should contain_package('cgroup-lite')
    }
  end

  describe 'docker configuration' do
    it {
      should contain_class('docker').with_root_dir('/mnt/lib/docker')
      should contain_class('docker').with_tmp_dir('/mnt/tmp')
      should contain_file('/mnt/lib/docker')
    }
  end
end
