# = Class: vim
#
# This is the main vim class
#
#
# == Parameters
#
# Standard class parameters
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, vim class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $vim_myclass
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, vim main config file will have the param: source => $source
#   Can be defined also by the (top scope) variable $vim_source
#
# [*source_dir*]
#   If defined, the whole vim configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#   Can be defined also by the (top scope) variable $vim_source_dir
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#   Can be defined also by the (top scope) variable $vim_source_dir_purge
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, vim main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   Can be defined also by the (top scope) variable $vim_template
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $vim_options
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $vim_absent
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $vim_audit_only
#   and $audit_only
#
# Default class params - As defined in vim::params.
#
# [*package*]
#   The name of vim package
#
# [*config_dir*]
#   Main configuration directory. Used by puppi
#
# [*config_file*]
#   Main configuration file path
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top scope level on in a ENC) and "include vim"
# - Declare vim as a parametrized class:
#   class { 'minimal':
#     template => 'site/vim/vim.conf.erb',
#   }
#
# See README for more available parameters or just explore the code below.
#
#
class vim (
  $my_class            = params_lookup( 'my_class' ),
  $source              = params_lookup( 'source' ),
  $source_dir          = params_lookup( 'source_dir' ),
  $source_dir_purge    = params_lookup( 'source_dir_purge' ),
  $template            = params_lookup( 'template' ),
  $options             = params_lookup( 'options' ),
  $version             = params_lookup( 'version' ),
  $absent              = params_lookup( 'absent' ),
  $audit_only          = params_lookup( 'audit_only' , 'global' ),
  $package             = params_lookup( 'package' ),
  $config_dir          = params_lookup( 'config_dir' ),
  $config_file         = params_lookup( 'config_file' )
  ) inherits vim::params {

  ### Internal variables setting
  # Configurations directly retrieved from vim::params
  $config_file_mode=$vim::params::config_file_mode
  $config_file_owner=$vim::params::config_file_owner
  $config_file_group=$vim::params::config_file_group

  # Sanitize of booleans
  $bool_source_dir_purge=any2bool($source_dir_purge)
  $bool_absent=any2bool($absent)
  $bool_audit_only=any2bool($audit_only)

  # Logic management according to parameters provided by users
  $manage_package = $vim::bool_absent ? {
    true  => 'absent',
    false => $vim::version,
  }
  $manage_file = $vim::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }
  $manage_audit = $vim::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }
  $manage_file_replace = $vim::bool_audit_only ? {
    true  => false,
    false => true,
  }
  $manage_file_source = $vim::source ? {
    ''        => undef,
    default   => $vim::source,
  }
  $manage_file_content = $vim::template ? {
    ''        => undef,
    default   => template($vim::template),
  }

  ### Resources managed by the module
  package { $vim::package:
    ensure => $vim::manage_package,
  }

  file { 'vim.conf':
    ensure  => $vim::manage_file,
    path    => $vim::config_file,
    mode    => $vim::config_file_mode,
    owner   => $vim::config_file_owner,
    group   => $vim::config_file_group,
    require => Package[$vim::package],
    source  => $vim::manage_file_source,
    content => $vim::manage_file_content,
    replace => $vim::manage_file_replace,
    audit   => $vim::manage_audit,
  }

  # The whole vim configuration directory is managed only
  # if $vim::source_dir is provided
  if $vim::source_dir and $vim::config_dir != '' {
    file { 'vim.dir':
      ensure  => directory,
      path    => $vim::config_dir,
      require => Package[$vim::package],
      source  => $vim::source_dir,
      recurse => true,
      purge   => $vim::bool_source_dir_purge,
      replace => $vim::manage_file_replace,
      audit   => $vim::manage_audit,
    }
  }


  ### Include custom class if $my_class is set
  if $vim::my_class {
    include $vim::my_class
  }

}
