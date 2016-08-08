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
# [*httpd_protocol*]
#   The protocol used by gerrit.
#   Options : http, https, proxy-http, proxy-https
#
# [*httpd_hostname*]
#   The hostname on wich gerrit will be reachable. Default any.
#
# [*httpd_port*]
#   The port on wich gerrit will be reachable
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
# [*ldap_accountpattern*]
#   The query pattern to use when searching for a user account.
#   format like "(&(objectClass=inetOrgPerson)(cn=${username}))"
#
# [*ldap_accountemailaddress*]
#   The name of an attribute on the user account object which contains the
#   user's Internet email address
#   format like "mail"
#
# [*ldap_accountfullname*]
#   The name of an attribute on the user account object which contains the
#   user's fullname
#   format like "displayName"
#
# [*ldap_accountfullname*]
#   The name of an attribute on the user account object which contains the
#   groups the user is part of
#   format like "memberOf"
#
# [*ldap_accountsshusername*]
#   The Name of an attribute on the user account object which contains the
#   initial value for the user's SSH username field in Gerrit
#   format like "cn"
#
# [*ldap_groupbase*]
#   The base dn for the groups
#
# [*ldap_groupname*]
#   Name of the attribute on the group object which contains the value to
#   use as the group name in Gerrit
#
# [*ldap_grouppattern*]
#   Query pattern used when searching for an LDAP group to connect to a
#   Gerrit group.
#
# [*ldap_groupmemberpattern*]
#   Query pattern to use when searching for the groups that a user account
#   is currently a member of
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
# [*extra_folders*]
#   Extra folder to create on gerrit home directory
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
  $auth_type                = 'OPENID',
  $canonicalweburl          = 'http://127.0.0.1:8080/',
  $httpd_protocol           = 'http',
  $httpd_hostname           = '*',
  $httpd_port               = 8080,
  $configure_gitweb         = true,
  $database_backend         = 'h2',
  $database_hostname        = undef,
  $database_name            = 'db/ReviewDB',
  $database_password        = undef,
  $database_username        = undef,
  $download_scheme          = ['ssh', 'anon_http', 'http'],
  $git_package              = $gerrit::params::git_package,
  $gitweb_cgi_path          = $gerrit::params::gitweb_cgi_path,
  $gitweb_package           = $gerrit::params::gitweb_package,
  $install_git              = true,
  $install_gitweb           = true,
  $install_java             = true,
  $install_java_mysql       = true,
  $install_user             = true,
  $java_package             = $gerrit::params::java_package,
  $ldap_accountbase         = undef,
  $ldap_accountpattern      = undef,
  $ldap_accountemailaddress = undef,
  $ldap_accountfullname     = undef,
  $ldap_accountmemberfield  = undef,
  $ldap_accountsshusername  = undef,
  $ldap_groupbase           = undef,
  $ldap_groupname           = undef,
  $ldap_grouppattern        = undef,
  $ldap_groupmemberpattern  = undef,
  $ldap_password            = undef,
  $ldap_server              = undef,
  $ldap_sslverify           = undef,
  $ldap_timeout             = undef,
  $ldap_username            = undef,
  $manage_service           = true,
  $mysql_java_connector     = $gerrit::params::mysql_java_connector,
  $mysql_java_package       = $gerrit::params::mysql_java_package,
  $user                     = 'gerrit',
  $extra_folders            = ['hooks', 'plugins'],
) inherits gerrit::params {

  if $install_user {
    user {
      $user:
        managehome => true,
        home       => $target,
    } -> Exec['install_gerrit']
  }

  if $install_java {
    package{
      $java_package:
        ensure => installed,
    } -> Exec['install_gerrit']
  }

  if $install_java_mysql {
    package{
      $mysql_java_package:
        ensure  => installed,
        require => Exec['install_gerrit'],
    } ->
    file {
      "${target}/lib/mysql-connector-java.jar" :
        ensure => link,
        target => $mysql_java_connector,
    }
  }

  if $install_git {
    package{
      $git_package:
        ensure => installed,
    } -> Exec['install_gerrit']
  }

  exec {
    'install_gerrit':
      command => "java -jar ${source} init -d ${target}",
      creates => "${target}/bin/gerrit.sh",
      user    => $user,
      path    => $::path,
  }

  exec {
    'reload_gerrit':
      command     => "java -jar ${target}/bin/gerrit.war init -d ${target}",
      refreshonly => true,
      user        => $user,
      path        => $::path,
      notify      => Service['gerrit'],
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
        require   => Exec['install_gerrit'],
    }
  }

  gerrit::folder { $extra_folders : }

  Gerrit::Config {
    file    => "${target}/etc/gerrit.config",
  }

  gerrit::config {
    'httpd.listenUrl':
      ensure => present,
      value  => "${httpd_protocol}://${httpd_hostname}:${httpd_port}",
  }

  gerrit::config {
    'database.type':
      ensure => present,
      value  => $database_backend,
  }

  gerrit::config {
    'database.database':
      ensure => present,
      value  => $database_name,
  }

  if $database_username {
    gerrit::config {
      'database.username':
        ensure => present,
        value  => $database_username,
    }
  }

  if $database_password {
    gerrit::config {
      'database.password':
        ensure => present,
        value  => $database_password,
        file   => "${target}/etc/secure.config",
    }
  }

  if $database_hostname {
    gerrit::config {
      'database.hostname':
        ensure => present,
        value  => $database_hostname,
    }
  }

  gerrit::config {
    'auth.type':
      ensure => present,
      value  => $auth_type,
  }

  gerrit::config {
    'gerrit.canonicalWebUrl':
      ensure => present,
      value  => $canonicalweburl,
  }

  gerrit::config {
    'download.scheme':
      ensure => present,
      value  => $download_scheme,
  }

  if $install_gitweb {
    package {
      $gitweb_package:
        ensure => installed,
    }
  }

  if $configure_gitweb {
    gerrit::config {
      'gitweb.cgi':
        ensure => present,
        value  => $gitweb_cgi_path,
    }
  }

  if $ldap_server {
    gerrit::config {
      'ldap.server':
        ensure => present,
        value  => $ldap_server,
    }
  }

  if $ldap_accountbase {
    gerrit::config {
      'ldap.accountBase':
        ensure => present,
        value  => $ldap_accountbase,
    }
  }

  if $ldap_accountpattern {
    gerrit::config {
      'ldap.accountPattern':
        ensure => present,
        value  => $ldap_accountpattern,
    }
  }

  if $ldap_accountfullname{
    gerrit::config {
      'ldap.accountFullName':
        ensure => present,
        value  => $ldap_accountfullname,
    }
  }


  if $ldap_accountmemberfield{
    gerrit::config {
      'ldap.accountMemberField':
        ensure => present,
        value  => $ldap_accountmemberfield,
    }
  }


  if $ldap_accountemailaddress{
    gerrit::config {
      'ldap.accountEmailAddress':
        ensure => present,
        value  => $ldap_accountemailaddress,
    }
  }

  if $ldap_accountsshusername {
    gerrit::config {
      'ldap.accountSshUserName':
        ensure => present,
        value  => $ldap_accountsshusername,
    }
  }

  if $ldap_groupbase {
    gerrit::config {
      'ldap.groupBase':
        ensure => present,
        value  => $ldap_groupbase,
    }
  }

  if $ldap_groupname {
    gerrit::config {
      'ldap.groupName':
        ensure => present,
        value  => $ldap_groupname,
    }
  }

  if $ldap_grouppattern {
    gerrit::config {
      'ldap.groupPattern':
        ensure => present,
        value  => $ldap_grouppattern,
    }
  }

  if $ldap_groupmemberpattern {
    gerrit::config {
      'ldap.groupMemberPattern':
        ensure => present,
        value  => $ldap_groupmemberpattern,
    }
  }

  if $ldap_username {
    gerrit::config {
      'ldap.username':
        ensure => present,
        value  => $ldap_username,
    }
  }

  if $ldap_password {
    gerrit::config {
      'ldap.password':
        ensure => present,
        value  => $ldap_password,
        file   => "${target}/etc/secure.config",
    }
  }

  if $ldap_sslverify {
    gerrit::config {
      'ldap.sslVerify':
        ensure => present,
        value  => $ldap_sslverify,
    }
  }

  if $ldap_timeout {
    gerrit::config {
      'ldap.readTimeout':
        ensure => present,
        value  => $ldap_timeout,
    }
  }

}
