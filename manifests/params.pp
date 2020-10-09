# @summary It sets variables according to platform.
#
# @api private
class gerrit::params {
  case $facts['os']['name'] {
    /(?i:centos|redhat|scientific|oel|amazon|fedora)/: {
      $git_package          = 'git'
      $gitweb_cgi_path      = '/var/www/git/gitweb.cgi'
      $gitweb_package       = 'gitweb'
      $java_package         = 'java-1.6.0-openjdk'
      $mysql_java_connector = '/usr/share/java/mysql-connector-java.jar'
      $mysql_java_package   = 'mysql-connector-java'
    }
    /(?i:debian|ubuntu)/: {
      $git_package          = 'git'
      $gitweb_cgi_path      = '/usr/share/gitweb/gitweb.cgi'
      $gitweb_package       = 'gitweb'
      $java_package         = 'default-jdk'
      $mysql_java_connector = '/usr/share/java/mysql-connector-java.jar'
      $mysql_java_package   = 'libmysql-java'
    }
    default: {
      fail "Operatingsystem ${facts['os']['name']} is not supported."
    }
  }
}
