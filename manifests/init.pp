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
# [*cannonicalweburl*]
#   cannonical web url used in several places by gerrit
#
# [*configure_gitweb*]
#   boolean. should we adapt gerrit configuration to support gitweb
#
# [*database_backend*]
#   database backend. currently mysql and h2 are supported
#
# [*database_host*]
#   database name (mysql)
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
  $auth_type            = 'OPENID',
  $canonicalweburl      = 'http://127.0.0.1:8080/',
  $configure_gitweb     = true,
  $database_backend     = 'h2',
  $database_host        = undef,
  $database_name        = 'db/ReviewDB',
  $database_password    = undef,
  $database_username    = undef,
  $download_scheme      = 'ssh anon_http http',
  $git_package          = $gerrit::params::git_package,
  $gitweb_cgi_path      = $gerrit::params::gitweb_cgi_path,
  $gitweb_package       = $gerrit::params::gitweb_package,
  $install_git          = true,
  $install_gitweb       = true,
  $install_java         = true,
  $install_java_mysql   = true,
  $install_user         = true,
  $java_package         = $gerrit::params::java_package,
  $manage_service       = true,
  $mysql_java_connector = $gerrit::params::mysql_java_connector,
  $mysql_java_package   = $gerrit::params::mysql_java_package,
  $user                 = 'gerrit',
) inherits gerrit::params {

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

  if $install_java_mysql {
    package{
      $mysql_java_package:
        ensure  => installed,
        require => Exec ['install_gerrit'],
    } ->
    file {
      "$target/lib/mysql-connector-java.jar":
        ensure => link,
        target => $mysql_java_connector,
    }
    if $manage_service {
      File["$target/lib/mysql-connector-java.jar"] -> Service['gerrit']
    }
  }

  if $install_git {
    package{
      $git_package:
        ensure => installed,
    } -> Exec ['install_gerrit']
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
        require   => Exec ['install_gerrit'],
    }
  }

  Ini_setting {
    path    => "${target}/etc/gerrit.config",
    notify  => Service['gerrit'],
    require => Exec ['install_gerrit'],
  }

  ini_setting {
    'gerrit_database_backend':
      ensure  => present,
      section => 'database',
      setting => 'type',
      value   => $database_backend,
  } ~> Exec['reload_gerrit']

  ini_setting {
    'gerrit_database':
      ensure  => present,
      section => 'database',
      setting => 'database',
      value   => $database_name,
  } ~> Exec['reload_gerrit']

  if $database_username {
    ini_setting {
      'gerrit_database_username':
        ensure  => present,
        section => 'database',
        setting => 'username',
        value   => $database_username,
    } ~> Exec['reload_gerrit']
  }

  if $database_password {
    ini_setting {
      'gerrit_database_password':
        ensure  => present,
        section => 'database',
        setting => 'password',
        value   => $database_password,
        path    => "${target}/etc/secure.config",
    } ~> Exec['reload_gerrit']
  }

  if $database_host {
    ini_setting {
      'gerrit_database_host':
        ensure  => present,
        section => 'database',
        setting => 'host',
        value   => $database_host,
    } ~> Exec['reload_gerrit']
  }

  ini_setting {
    'gerrit_auth':
      ensure  => present,
      section => 'auth',
      setting => 'type',
      value   => $auth_type,
  } ~> Service['gerrit']

  ini_setting {
    'gerrit_url':
      ensure  => present,
      section => 'gerrit',
      setting => 'canonicalWebUrl',
      value   => $cannonicalweburl,
  } ~> Service['gerrit']

  ini_setting {
    'gerrit_download_scheme':
      ensure  => present,
      section => 'download',
      setting => 'scheme',
      value   => $download_scheme,
  } ~> Service['gerrit']

  if $install_gitweb {
    package {
      $gitweb_package:
        ensure => installed
    }
  }

  if $configure_gitweb {
    ini_setting {
      'gerrit_gitweb':
        ensure  => present,
        section => 'gitweb',
        setting => 'cgi',
        value   => $gitweb_cgi_path,
    } ~> Service['gerrit']
  }

}
