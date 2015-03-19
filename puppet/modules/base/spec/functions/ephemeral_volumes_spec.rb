require 'spec_helper'

describe 'the ephemeral_volumes function' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'is loaded in the Puppet namespace' do
    expect(Puppet::Parser::Functions.function('ephemeral_volumes')).to eq('function_ephemeral_volumes')
  end

  it 'should generate a set of logical groups' do
    expect(scope.function_ephemeral_volumes(['xvda,xvdb,xvdc', '/vol'])).to eq({'ephemeral1' => {'mountpath' => '/vol/ephemeral1', 'fs_type' => 'ext4', 'size' => nil, 'options' => 'defaults,nobootwait'}})
  end
end
