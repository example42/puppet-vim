# = Define: vim::userconfig
#
# This define creates a vimrc file on a user directory
#
#
# == Parameters
#
# [*user*]
#   Name of the user for which the vimrc file is provided.
#   If not set, it uses $name
#
# [*install_pathogen*]
#   Set to true to automatically install vim-pathogen in order to be able
#   to easily add bundles. Default: false
#   Note: If you enable it, a default .vimrc file is created with the
#   call pathogen#infect() and few other configs
#   Place the above call in you vimrc files in you want to provide custom
#   versions.
#
# [*source*]
#   Sets the content of source parameter for configuration file
#
# [*source_dir*]
#   If defined, the whole user vim configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#
# [*template*]
#   Sets the path to the template to use as content for the configuration file
#   Note source and template parameters are mutually exclusive: don't use both
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $vim_options
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $vim_absent
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#
# [*config_file*]
#   Configration configuration file path. Default /home/$user/.vimrc
#
# == Examples
#
#   vim::userconfig { 'al':
#     source => "puppet:///modules/example42/vim/vimrc-al", 
#   }
#
#
define vim::userconfig (
  $user                = '',
  $install_pathogen    = false,
  $source              = '',
  $source_dir          = '',
  $source_dir_purge    = false,
  $template            = '',
  $options             = '',
  $absent              = false,
  $audit_only          = false,
  $config_file         = ''
  ) {

  # Sanitize of booleans
  $bool_install_pathogen=any2bool($install_pathogen)
  $bool_source_dir_purge=any2bool($source_dir_purge)
  $bool_absent=any2bool($absent)
  $bool_audit_only=any2bool($audit_only)

  # Logic management according to parameters provided by users
  $real_user = $user ? {
    ''        => $name,
    default   => $user,
  }
  $manage_file = $bool_absent ? {
    true    => 'absent',
    default => 'present',
  }
  $manage_audit = $bool_audit_only ? {
    true  => 'all',
    false => undef,
  }
  $manage_file_replace = $bool_audit_only ? {
    true  => false,
    false => true,
  }
  $manage_file_source = $source ? {
    ''        => $bool_install_pathogen ? {
      false => undef,
      true  => 'puppet:///modules/vim/vimrc-pathogen',
    },
    default   => $source,
  }
  $manage_file_content = $template ? {
    ''        => undef,
    default   => template($vim::template),
  }
  $manage_source_dir = $source_dir ? {
    ''        => undef,
    default   => $source_dir,
  }
  $manage_path = $config_file ? {
    ''        => "/home/$real_user/.vimrc",
    default   => $config_file,
  }
  $manage_path_dir = $vim::config_dir ? {
    ''        => "/home/$real_user/.vim",
    default   => $vim::config_dir,
  }

  ### Resources managed by the define
  file { "${real_user}-vimrc":
    ensure  => $manage_file,
    path    => $manage_path,
    mode    => $vim::config_file_mode,
    owner   => $real_user,
    group   => $real_user,
    require => Package[$vim::package],
    source  => $manage_file_source,
    content => $manage_file_content,
    replace => $manage_file_replace,
    audit   => $manage_audit,
  }

  if $source_dir
  or $bool_install_pathogen {
    file { "${real_user}-vim.dir":
      ensure  => directory,
      path    => $manage_path_dir,
      require => Package[$vim::package],
      source  => $manage_source_dir,
      recurse => true,
      purge   => $bool_source_dir_purge,
      replace => $manage_file_replace,
      audit   => $manage_audit,
    }
  }

  if $bool_install_pathogen {
    file { "${real_user}-vim.autoload":
      ensure  => directory,
      path    => "${manage_path_dir}/autoload",
      require => Class['vim'],
    }
    file { "${real_user}-vim.pathogen":
      ensure  => $vim::manage_file,
      path    => "${manage_path_dir}/autoload/pathogen.vim",
      mode    => $vim::config_file_mode,
      owner   => $vim::config_file_owner,
      group   => $vim::config_file_group,
      require => File["${real_user}-vim.autoload"],
      source  => 'puppet:///modules/vim/pathogen.vim',
      replace => $vim::manage_file_replace,
      audit   => $vim::manage_audit,
    }
  }

}
