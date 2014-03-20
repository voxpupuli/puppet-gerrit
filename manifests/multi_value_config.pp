define gerrit::multi_value_config(
  $section,
  $setting,
  $config_type,
  $ensure = present,
){
  $value = $title
  #"$config_type"{"$section/$setting":
  gerrit_config{"$section/$setting":
    value   =>  $value,
    ensure  =>  $ensure,
  }


}
