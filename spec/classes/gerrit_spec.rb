require 'spec_helper'

describe 'gerrit', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      describe 'gerrit' do
        let :params do
          {
            source: '/tmp/gerrit.war',
            target: '/srv/gerrit'
          }
        end
        it { should compile.with_all_deps }
        it { should contain_class('gerrit') }
      end
    end
  end
end
