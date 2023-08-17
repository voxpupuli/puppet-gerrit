require 'spec_helper'

describe 'gerrit', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
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

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('gerrit') }
        it { is_expected.to contain_class('gerrit::params') }
        it { is_expected.to contain_user('gerrit') }
        it { is_expected.to contain_service('gerrit') }
        it { is_expected.to contain_exec('config_auth.type') }
        it { is_expected.to contain_exec('config_database.database') }
        it { is_expected.to contain_exec('config_database.type') }
        it { is_expected.to contain_exec('config_download.scheme') }
        it { is_expected.to contain_exec('config_download.scheme_empty') }
        it { is_expected.to contain_exec('config_gerrit.canonicalWebUrl') }
        it { is_expected.to contain_exec('reload_gerrit') }
        it { is_expected.to contain_exec('config_gitweb.cgi') }
        it { is_expected.to contain_exec('config_httpd.listenUrl') }
        it { is_expected.to contain_exec('install_gerrit') }
        it { is_expected.to contain_file('/srv/gerrit/hooks') }
        it { is_expected.to contain_file('/srv/gerrit/lib/mysql-connector-java.jar') }
        it { is_expected.to contain_file('/srv/gerrit/plugins') }
        it { is_expected.to contain_package('git') }
        it { is_expected.to contain_package('gitweb') }
        it { is_expected.to contain_gerrit__config('auth.type') }
        it { is_expected.to contain_gerrit__config('database.database') }
        it { is_expected.to contain_gerrit__config('database.type') }
        it { is_expected.to contain_gerrit__config('download.scheme') }
        it { is_expected.to contain_gerrit__config('gerrit.canonicalWebUrl') }
        it { is_expected.to contain_gerrit__config('gitweb.cgi') }
        it { is_expected.to contain_gerrit__config('httpd.listenUrl') }
        it { is_expected.to contain_gerrit__folder('hooks') }
        it { is_expected.to contain_gerrit__folder('plugins') }

        case facts[:operatingsystem]
        when 'Debian', 'Ubuntu'
          it { is_expected.to contain_package('libmysql-java') }
          it { is_expected.to contain_package('default-jdk') }
        when 'Redhat', 'RedHat'
          it { is_expected.to contain_package('mysql-connector-java') }
          it { is_expected.to contain_package('java-1.6.0-openjdk') }
        end
      end
    end
  end
end
