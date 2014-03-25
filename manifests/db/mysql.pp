class gerrit::db::mysql(
  $db_root_password,
  $db_user_password,
  $db_user  = 'gerrit',
  $db_name  = 'gerrit',
) {


  class { 'mysql::server':
    config_hash => {
      'root_password' => $db_root_password,
      'bind_address'  => '0.0.0.0',
      'ssl'           => 'false',
      'ssl_ca'        => undef,
      'ssl_cert'      => undef,
      'ssl_key'       => undef,
    },
    enabled     => true,
  }
  
  mysql::db { $db_name:
    user         => $db_user,
    password     => $db_user_password,
    host         => '127.0.0.1',
    charset      => 'latin1',
    require      => Class['mysql::config'],
  }
  
  #database_user {"$db_user@127.0.0.1":
  #  password_hash => mysql_password($db_user_password),
  #  provider      => 'mysql',
  #  require       =>  Mysql::Db[$db_name],
  #} 

  gerrit::db::mysql::grants{ ["${db_user}@localhost/$db_name.*", "${db_user}@127.0.0.1/${db_name}.*", "${db_user}@${::fqdn}/${db_name}.*"]:
    ensure            => 'present',
    db_user_password  =>  $db_user_password,
    require           =>  Mysql::Db[$db_name],
  }

  #install Lib
  $mysql_java_connector = $gerrit::params::mysql_java_connector
  $mysql_javaj_connector_name = regsubst($mysql_java_connector, '^.*\/([_-a-z0-9.]+$)', '\1', 'I')
  exec{"install_mysql_connector":
    command => "cp ${mysql_java_connector} ${gerrit::install_path}/lib/ && chown ${gerrit::user} ${gerrit::install_path}/lib/*",
    user    =>  'root',
    path    =>  $::path,
    creates =>  "${gerrit::install_path}/lib/${mysql_java_connector_name}",
  }


}
