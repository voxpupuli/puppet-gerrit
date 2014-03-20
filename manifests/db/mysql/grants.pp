define gerrit::db::mysql::grants(
  $ensure   =  present,
  $db_user_password,
){
 
  $grants_db_data = split($title, '/')
  $grants_db = $grants_db_data[1]
  $grants_user_data = split($grants_db_data[0], '@')
  $grants_user = $grants_user_data[0]
  $grants_host = $grants_user_data[1]
  

  database_grant { "${grants_user}@${grants_host}/${grants_db}":
    privileges => 'all',
    provider   => 'mysql',
   # require    => Database_user[$grants_user]
  }

}
