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
        it { should contain_class('gerrit::params') }
        it { should contain_user('gerrit') }
        it { should contain_service('gerrit') }
        it { should contain_exec('config_auth.type') }
        it { should contain_exec('config_database.database') }
        it { should contain_exec('config_database.type') }
        it { should contain_exec('config_download.scheme') }
        it { should contain_exec('config_download.scheme_empty') }
        it { should contain_exec('config_gerrit.canonicalWebUrl') }
        it { should contain_exec('reload_gerrit') }
        it { should contain_exec('config_gitweb.cgi') }
        it { should contain_exec('config_httpd.listenUrl') }
        it { should contain_exec('install_gerrit') }
        it { should contain_file('/srv/gerrit/hooks') }
        it { should contain_file('/srv/gerrit/lib/mysql-connector-java.jar') }
        it { should contain_file('/srv/gerrit/plugins') }
        it { should contain_package('git') }
        it { should contain_package('gitweb') }
        it { should contain_gerrit__config('auth.type') }
        it { should contain_gerrit__config('database.database') }
        it { should contain_gerrit__config('database.type') }
        it { should contain_gerrit__config('download.scheme') }
        it { should contain_gerrit__config('gerrit.canonicalWebUrl') }
        it { should contain_gerrit__config('gitweb.cgi') }
        it { should contain_gerrit__config('httpd.listenUrl') }
        it { should contain_gerrit__folder('hooks') }
        it { should contain_gerrit__folder('plugins') }

        case facts[:operatingsystem]
        when 'Debian', 'Ubuntu'
          it { should contain_package('libmysql-java') }
          it { should contain_package('default-jdk') }
        when 'Redhat', 'RedHat'
          it { should contain_package('mysql-connector-java') }
          it { should contain_package('java-1.6.0-openjdk') }
        end
      end
    end
  end
end
