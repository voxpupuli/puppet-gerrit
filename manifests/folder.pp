# @summary Define to create directories inside gerrit target path
#
# @param name
#   The folder name
# @param ensure
#   Manage the state of this directory inside gerrit target path
define gerrit::folder (
  $ensure   = 'directory',
) {
  file {
    "${gerrit::target}/${name}":
      ensure  => $ensure,
      owner   => $gerrit::user,
      group   => $gerrit::user,
      mode    => '0755',
      require => Exec['install_gerrit'],
  }
}
