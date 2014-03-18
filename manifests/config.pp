define gerrit::config(
  $value,
  $ensure = present,
  $file   = "${gerrit::target}/etc/gerrit.config"
){

  exec {
    "config_$name":
      command => "git config -f ${file} \"${name}\" \"${value}\"",
      unless  => "git config -f ${file} \"${name}\"|grep -x \"${value}\"",
      path    => $::path,
      require => Exec['install_gerrit'],
  }

  if $gerrit::manage_service {
    Exec["config_$name"] ~> Exec['reload_gerrit']
  }

}
