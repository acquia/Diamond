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

  describe 'docker configuration' do
    it do
      should contain_class('base::docker')
      should contain_class('docker').with_root_dir('/mnt/lib/docker')
      should contain_class('docker').with_tmp_dir('/mnt/tmp')
      should contain_file('/mnt/lib/docker')
    end
  end
end
