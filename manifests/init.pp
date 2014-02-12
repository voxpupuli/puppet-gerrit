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
# [*user*]
#   the user used to install gerrit
#
# [*git_package*]
#   the name of the git package
#
# [*java_package*]
#   the name of the java package
#
# [*create_user*]
#   boolean. should this module create the user.
#
# [*install_java*]
#   boolean. should this module install java.
#
# [*install_java_mysql*]
#   boolean. should this module install java mysql connector.
#
# [*install_git*]
#   boolean. should this module install git.
#
# [*manage_service*]
#   boolean. should this module launch the service
#
# [*database_backend*]
#   database backend. currently mysql and h2 are supported
#
# [*database_name*]
#   database name (h2 and mysql)
#
# [*database_username*]
#   database username (mysql)
#
# [*database_password*]
#   database name (mysql)
#
# [*database_host*]
#   database name (mysql)
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
  $user                 = 'gerrit',
  $java_package         = $gerrit::params::java_package,
  $git_package          = $gerrit::params::git_package,
  $mysql_java_package   = $gerrit::params::mysql_java_package,
  $mysql_java_connector = $gerrit::params::mysql_java_connector,
  $install_user         = true,
  $install_java         = true,
  $install_java_mysql   = true,
  $install_git          = true,
  $manage_service       = true,
  $database_backend     = 'h2',
  $database_name        = 'db/ReviewDB',
  $database_username    = undef,
  $database_password    = undef,
  $database_host        = undef,
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
    'database_backend':
      ensure  => present,
      section => 'database',
      setting => 'type',
      value   => $database_backend,
  } ~> Exec['reload_gerrit']

  ini_setting {
    'database':
      ensure  => present,
      section => 'database',
      setting => 'database',
      value   => $database_name,
  } ~> Exec['reload_gerrit']

  if $database_username {
    ini_setting {
      'database_username':
        ensure  => present,
        section => 'database',
        setting => 'username',
        value   => $database_username,
    } ~> Exec['reload_gerrit']
  }

  if $database_password {
    ini_setting {
      'database_password':
        ensure  => present,
        section => 'database',
        setting => 'password',
        value   => $database_password,
        path    => "${target}/etc/secure.config",
    } ~> Exec['reload_gerrit']
  }

  if $database_host {
    ini_setting {
      'database_host':
        ensure  => present,
        section => 'database',
        setting => 'host',
        value   => $database_host,
    } ~> Exec['reload_gerrit']
  }

}
