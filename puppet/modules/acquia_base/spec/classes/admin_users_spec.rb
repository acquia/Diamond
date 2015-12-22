require 'spec_helper'

describe 'acquia_base::admin_users' do
  let(:facts) do |_|
    {
      osfamily: 'RedHat',
    }
  end

  describe 'puppet module' do
    it {
      should contain_class('acquia_base::admin_users')
    }
  end

  describe 'user configuration' do
    let(:user) { 'test_user' }
    let(:ssh_key) { 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDEbn7D7RCrLXSE104MphsPZNFoviq50H0YQsisbe89XXSz3UvTlw9M2Ng1an+v0glZqV7klMNFfct+1NiMlz3ZSB5VKH0mhokvaNjhEJ2WrIPoO2asy/AsouFofcUk0A64n3m+kaOmPvrw7iqOzPz0cAk6BdQx9nFa1E06BFCZ+L49VKOzZloOon1oDFyAPybWWP1ZtmR/yHHiu/YwKW5keytTF1Fwx21wK4jxDg6ifpEM1xpPttXt5FkbA6KF3SJuSuLUq743ayTe292MTSWEA37u/6YA11nOVIoNBtt1CBug0qT5+LZ8ze7hRs3xkwTG+DG4QExUulEYaR8bqFu/iTHHs27QqBfaqq04bxQhS9yaBE7Yvz9GCJMLVnBaG0TsaOMD4zj0THuf/crDSu73I77Q8m78CGG7r4A7bB8zvOXHLi5hr/IMnsWPGdMM7cyhBgzSD57pHzsKD0UfN5/kPSBz9D0EXDVlxcDS+xolyUVjETtN7woJYwbMIcfqnYjQzn4JOvcoIpwUVeaDRu3rj46cPLSULj6B2SP3feklnn18Gyco61IHZaJUw6YUWrp+6mUMgmee5/x5O1AQvrzRTOxugEgEyVFS9Fmkcnp1wk6YtwpJK0cUQwnUioDSBWawxWmDApSphBiRDzxBVD+xez66jxjkEx+SPdxpYgGuMQ==' }
    it {
      should contain_acquia_base__admin_users__create(user)
      should contain_user(user)
      should contain_ssh_authorized_key(user)
        .with_key(ssh_key)
    }
  end
end
