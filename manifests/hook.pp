# @summary Define to create gerrit hook
#
# @param name
#   The hook name
# @param ensure
#   Manage the state of this gerrit hook.
# @param source
#   The source of this hook. Can be any value valid for the `file` `source` parameter.
# @param content
#   The content of this hook. Can be any value valid for the `file` `content` parameter.
define gerrit::hook (
  $ensure   = 'present',
  $source   = undef,
  $content  = undef,
) {
  file {
    "${gerrit::target}/hooks/${name}":
      ensure  => $ensure,
      source  => $source,
      content => $content,
      owner   => $gerrit::user,
      group   => $gerrit::user,
      mode    => '0700',
      require => [Exec['install_gerrit'], Gerrit::Folder['hooks']],
  }
}
