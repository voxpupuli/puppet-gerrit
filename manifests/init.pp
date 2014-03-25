# == Class: gerrit
#
# Full description of class gerrit here.
#
# === Parameters
#
# Document parameters here.
#
# [*source*]
#   the path to the gerrit.war file
#   You can now specify URLs or local paths for your war file
#
# [*target*]
#   the path to install gerrit to
#
# [*auth_type*]
#   auth type (ldap, http, ...)
#
# [*canonicalweburl*]
#   canonical web url used in several places by gerrit
#
# [*configure_gitweb*]
#   boolean. should we adapt gerrit configuration to support gitweb
#
# [*database_backend*]
#   database backend. currently mysql and h2 are supported
#
# [*database_hostname*]
#   database hostname (mysql)
#
# [*database_name*]
#   database name (h2 and mysql)
#
# [*database_password*]
#   database name (mysql)
#
# [*database_username*]
#   database username (mysql)
#
# [*download_scheme*]
#   download scheme (ssh, http, ...)
#
# [*git_package*]
#   the name of the git package
#
# [*gitweb_cgi_path*]
#   path to the gitweb cgi executable
#
# [*gitweb_package*]
#   the name of the gitweb package
#
# [*java_package*]
#   the name of the java package
#
# [*create_user*]
#   boolean. should this module create the user.
#
# [*install_git*]
#   boolean. should this module install git.
#
# [*install_gitweb*]
#   boolean. should this module install gitweb.
#
# [*install_java*]
#   boolean. should this module install java.
#
# [*install_java_mysql*]
#   boolean. should this module install java mysql connector.
#
# [*install_user*]
#   boolean. should this module setup the gerrit user
#
# [*ldap_accountbase*]
#   The base dn for the accounts
#
# [*ldap_groupbase*]
#   The base dn for the groups
#
# [*ldap_password*]
#   the ldap password to bind to
#
# [*ldap_server*]
#   the ldap server address
#
# [*ldap_sslverify*]
#   If false and $ldap_server is an ldaps:// style URL, Gerrit will not verify
#   the server certificate when it connects to perform a query.
#
# [*ldap_timeout*]
#   The read timeout for an LDAP operation. The value is in the usual time-unit
#   format like "1 s", "100 ms", etc..
#
# [*ldap_username*]
#   the ldap user to bind to
#
# [*manage_service*]
#   boolean. should this module launch the service
#
# [*mysql_java_connector*]
#   the name of the java connector file
#
# [*mysql_java_package*]
#   the name of the java connector package
#
# [*manage_service*]
#   boolean. should this module launch the service
#
# [*user*]
#   the user used to install gerrit
#
# === Examples
#
#  class {
#   gerrit:
#     source => '/vagrant/gerrit-2.8.1.war',
#     target => '/opt/gerrit'
#  }
#
# === Authors
#
# Julien Pivotto <roidelapluie@inuits.eu>
#
# === Copyright
#
# Copyright 2014 Julien Pivotto
#
class gerrit (
  $source,
  $target,
  $auth_type              = 'OPENID',
  $canonicalweburl        = 'http://127.0.0.1:8080/',
  $configure_gitweb       = true,
  $database_backend       = 'h2',
  $database_hostname      = undef,
  $database_name          = 'reviewdb',
  $database_password      = false,
  $database_root_password = false,
  $database_username      = undef,
  $download_scheme        = 'ssh,anon_http,http',
  $git_package            = $gerrit::params::git_package,
  $gitweb_cgi_path        = $gerrit::params::gitweb_cgi_path,
  $gitweb_package         = $gerrit::params::gitweb_package,
  $manage_db              = true,
  $db_type                = 'mysql',
  $install_path           = '/opt/gerrit',
  $install_git            = true,
  $install_gitweb         = true,
  $install_java           = true,
  $install_java_mysql     = true,
  $install_user           = true,
  $java_package           = $gerrit::params::java_package,
  $ldap_accountbase       = undef,
  $ldap_groupbase         = undef,
  $ldap_password          = undef,
  $ldap_server            = undef,
  $ldap_sslverify         = undef,
  $ldap_timeout           = undef,
  $ldap_username          = undef,
  $manage_service         = true,
  $mysql_java_connector   = $gerrit::params::mysql_java_connector,
  $mysql_java_package     = $gerrit::params::mysql_java_package,
  $user                   = 'gerrit',
  $smtp_server            = 'localhost',
  $smtp_user              = undef,
  $smtp_port              = undef,
  $smtp_encryption        = undef,
  $smtp_pass              = undef,
  $smtp_from              = undef,
) inherits gerrit::params {

  # check if $source is an URL
  if $source =~ /http(s)?:\/\/.*/ {
    $local_source_path = regsubst($target, '[ _a-z0-9.-]+(\/)?$', '/')
    $local_source = "${local_source}/gerrit.war"
    exec{"fetch_gerrit_source":
      command => "curl --insecure --create-dirs --output ${local_source} ${source}",
      creates =>  $local_source,
    }
  } else {
    $local_source = $source
  }

  if $install_user {
    user {
      $user:
        managehome => true,
        home       => $target,
    } -> Exec ['install_gerrit']
  }

  if $install_java {
    package{
      $java_package:
        ensure => installed,
    } -> Exec ['install_gerrit']
  }
  
  if $manage_db {
    if $db_type == 'mysql' {
      class{ 'gerrit::db::mysql':
        db_root_password  => $database_root_password,
        db_user           => $database_username,
        db_user_password  => $database_password,
        db_name           => $database_name,
        require => Exec['install_gerrit'],
        before  => [Exec['reload_gerrit'], Service['gerrit']],
        notify  => [Exec['reload_gerrit'], Service['gerrit']],
      }
    } else {
      fail("Unsupported DB Type")
    }
  }

  if $install_java_mysql {
    package{
      $mysql_java_package:
        ensure  => installed,
        require => Exec ['install_gerrit'],
    }
  }

  if $install_git {
    package{
      $git_package:
        ensure => installed,
    } -> Exec ['install_gerrit']
  }

  file{$install_path:
    ensure  =>  directory,
    owner   =>  $gerrit::user,
  }
  exec {
    'install_gerrit':
      command =>  "java -jar ${local_source} init -d ${target} --batch > /tmp/gerrit_install.out 2>&1 ",
      creates =>  "${target}/bin/gerrit.sh",
      user    =>  $user,
      path    =>  $::path,
      require =>  File[$install_path],
  }

  exec {
    'reload_gerrit':
      command     => "/usr/bin/java -jar ${target}/bin/gerrit.war init -d ${target} --batch",
      refreshonly => true,
      user        => $user,
      path        => $::path,
      notify      => [Service['gerrit'], Exec['clone_allprojects']],
  }

  if $manage_service {
    service {
      'gerrit':
        ensure    => running,
        start     => "${target}/bin/gerrit.sh start",
        stop      => "${target}/bin/gerrit.sh stop",
        hasstatus => false,
        pattern   => 'GerritCodeReview',
        provider  => 'base',
        require   => Exec ['install_gerrit'],
    }
  }

  #Add verify label

  exec{'clone_allprojects':
    command     =>  "git clone ${target}/git/All-Projects.git /tmp/All-Projects",
    creates     =>  "/tmp/All-Projects",
    refreshonly =>  true,
    path        => $::path,
    notify      =>  Exec['fetch_origin_allprojects'],
  }
  exec{'fetch_origin_allprojects':
    command     =>  "git fetch origin refs/meta/config:refs/meta/config",
    cwd         =>  "/tmp/All-Projects/",
    refreshonly =>  true,
    path        => $::path,
    notify      =>  Exec['checkout_config_allprojects'],
  }
  exec{'checkout_config_allprojects':
    command     =>  "git checkout refs/meta/config -b refs/meta/config",
    cwd         =>  "/tmp/All-Projects/",
    refreshonly =>  true,
    path        => $::path,
    notify      =>  Exec['insert_verify_allprojects'],
  }
  # This is a horrible horrible hack to allow variable overloading. 
  exec{'insert_verify_allprojects':
    command =>  "echo -en '[label \"Verified\"]\nfunction = MaxWithBlock\nvalue = -1 Fails\nvalue =  0 No score\nvalue = +1 Verified\n' >> project.config",
    cwd         =>  "/tmp/All-Projects/",
    refreshonly =>  true,
    path        => $::path,
    notify      =>  Exec['commit_verify'],
    unless      =>  'grep -q "\[label \"Verified\"\]" project.config',
  }
  exec{'commit_verify':
    command =>  'git commit -am "Add label \'Verified\' and its config"',
    cwd         =>  "/tmp/All-Projects/",
    refreshonly =>  true,
    path        => $::path,
    notify      =>  Exec['push_verify'],
  }
  exec{'push_verify':
    command =>  'git push origin HEAD:refs/meta/config',
    cwd         =>  "/tmp/All-Projects/",
    refreshonly =>  true,
    path        => $::path,
  }



#####################CONFIG#################################


  Gerrit_config{
    require => Exec['install_gerrit'],
    before  => [Exec['reload_gerrit'], Service['gerrit']],
    notify  => [Exec['reload_gerrit'], Service['gerrit']],
  }
  Gerrit_secure_config{
    require => Exec['install_gerrit'],
    before  => [Exec['reload_gerrit'], Service['gerrit']],
    notify  => [Exec['reload_gerrit'], Service['gerrit']]
  }
  Gerrit::Multi_value_config{
    require => Exec['install_gerrit'],
    before  => [Exec['reload_gerrit'], Service['gerrit']],
    notify  => [Exec['reload_gerrit'], Service['gerrit']]
  }
  gerrit_config {'database/type':
      ensure => present,
      value  => $database_backend,
  }

  gerrit_config {'database/database':
      ensure  => present,
      value   => $database_name,
  }

  if $database_username {
    gerrit_config {'database/username':
        ensure  => present,
        value   => $database_username,
    }
  }

  if $database_password {
    gerrit_secure_config {'database/password':
        ensure  => present,
        value   => $database_password,
    }
  }

  if $database_hostname {
    gerrit_config {'database/hostname':
        ensure  => present,
        value   => $database_hostname,
    }
  }

  gerrit_config {'auth/type':
      ensure  => present,
      value   => $auth_type,
  }

  gerrit_config {'gerrit/canonicalWebUrl':
      ensure  => present,
      value   => $canonicalweburl,
  }
  
  # This needs work.. in gerrit the vars can be define multiple times within the same seciton. Setting to a single value atm so I can proceed. NOTE: This can be done with file_line with explicity matches and 'after's.
  #$download_scheme_array = split($download_scheme, ',')
  $download_scheme_array = 'http'
  
  gerrit::multi_value_config{$download_scheme_array:
      section      => 'download',
      setting      => 'scheme',
      ensure       => absent,
      config_type  => 'gerrit_config',
  }

  # Configure Email
  gerrit_config {'sendemail/smtpServer':
    ensure  =>  present,
    value   =>  $smtp_server
  }

  if $smtp_user {
    gerrit_config {'sendemail/smtpUser':
      ensure  =>  present,
      value   =>  $smtp_user
    }
  }
  if $smtp_port {
    gerrit_config {'sendemail/smtpServerPort':
      ensure  =>  present,
      value   =>  $smtp_port
    }
  }
  if $smtp_encryption {
    gerrit_config {'sendemail/smtpEncryption':
      ensure  =>  present,
      value   =>  $smtp_encryption,
    }
  }
  if $smtp_pass {
    gerrit_config {'sendemail/smtpPass':
      ensure  =>  present,
      value   =>  $smtp_pass
    }
  }
  if $smtp_from {
    $real_smtp_from = $smtp_from
  } else {
    $real_smtp_from = '${user} (Code Review) <registered@user.email>'
  }
  gerrit_config {'sendemail/from':
    ensure  =>  present,
    value   =>  $real_smtp_from,
  }


  # Gitweb
  if $install_gitweb {
    package {
      $gitweb_package:
        ensure => installed
    }
  }

  if $configure_gitweb {
    gerrit_config {'gitweb/cgi':
        ensure  => present,
        value   => $gitweb_cgi_path,
    }
  }

  if $ldap_server {
    gerrit_config {'ldap/server':
        ensure  => present,
        value   => $ldap_server,
    }
  }

  if $ldap_accountbase {
    gerrit_config {'ldap/accountBase':
        ensure  => present,
        value   => $ldap_accountbase,
    }
  }

  if $ldap_groupbase {
    gerrit_config {'ldap/groupBase':
        ensure  => present,
        value   => $ldap_groupbase,
    }
  }

  if $ldap_username {
    gerrit_config {'ldap/username':
        ensure  => present,
        value   => $ldap_username,
    }
  }

  if $ldap_password {
    gerrit_secure_config {'ldap/password':
        ensure  => present,
        value   => $ldap_password,
        file    => "${target}/etc/secure.config",
    }
  }

  if $ldap_sslverify {
    gerrit_config {'ldap/sslVerify':
        ensure  => present,
        value   => $ldap_sslverify,
    }
  }

  if $ldap_timeout {
    gerrit_config {'ldap/readTimeout':
        ensure  => present,
        value   => $ldap_timeout,
    }
  }
}
