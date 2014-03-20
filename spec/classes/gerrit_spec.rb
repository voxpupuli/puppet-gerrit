require 'spec_helper'

describe 'gerrit', :type => :class do

  context 'using default parameters on RedHat' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS',
        :operatingsystemrelease => '6.5',
        :processorcount => 1
      }
    end

    let(:params) do
      {
        :source      => 'http://www.example.com/gerrit.war',
        :target      => '/opt/gerrit',
      }
    end
    it {
        should contain_class('gerrit')
      }
  


end
