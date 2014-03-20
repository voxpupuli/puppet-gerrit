require 'spec_helper'

describe 'gerrit::params', :type => :class do

  let(:facts) do
    {
      :osfamily => 'RedHat',
      :operatingsystem => 'CentOS'
    }
  end

  it { should contain_gerrit__params }

end
