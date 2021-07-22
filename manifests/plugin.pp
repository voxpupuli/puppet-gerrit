# @summary Define to install gerrit plugins
#
# @param name
#   The plugin name
# @param source
#   The source of this plugins. Can be any value valid for the `file` `source` parameter.
# @param ensure
#   Manage the state of this gerrit plugin.
define gerrit::plugin (
  $source,
  $ensure = 'present',
) {
  file {
    "${gerrit::target}/plugins/${name}":
      ensure  => $ensure,
      source  => $source,
      owner   => $gerrit::user,
      group   => $gerrit::user,
      mode    => '0700',
      require => [Exec['install_gerrit'], Gerrit::Folder['plugins']],
  }
}
