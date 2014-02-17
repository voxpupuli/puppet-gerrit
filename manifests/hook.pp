define gerrit::hook(
  $repository,
  $ensure   = 'present',
  $source   = undef,
  $content  = undef,
){

  file{
    "${gerrit::target}/git/${repository}.git/hooks/$name":
      ensure   => $ensure,
      source   => $source,
      content  => $template,
      owner    => $gerrit::user,
      mode     => 0700,
      require  => Exec['install_gerrit'],
  }

}
