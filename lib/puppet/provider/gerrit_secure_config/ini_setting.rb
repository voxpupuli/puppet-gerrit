Puppet::Type.type(:gerrit_secure_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def separator
    '='
  end

  def self.file_path
    '/opt/gerrit/etc/secure.config'
  end

  # this needs to be removed. This has been replaced with the class method
  def file_path
    self.class.file_path
  end

end
