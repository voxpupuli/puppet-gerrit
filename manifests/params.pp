# == Class: gerrit::params
#
# Only used internally to support multiple operating systems
#
# === Authors
#
# Aimon Bustardo <aimon.bustardo@nexusis.com>
# Julien Pivotto <roidelapluie@inuits.eu>
#
class gerrit::params{


  case $::operatingsystem {
    /(?i:centos|redhat|scientific|oel|amazon|fedora)/: {
      $git_package          = "git"
      $gitweb_cgi_path      = "/var/www/git/gitweb.cgi"
      $gitweb_package       = "gitweb"
      $java_package         = "java-1.6.0-openjdk"
      $mysql_java_connector = "/usr/share/java/mysql-connector-java.jar"
      $mysql_java_package   = "mysql-connector-java"
    }
    default: {
      fail "Operatingsystem ${::operatingsystem} is not supported."
    }
  }

}
