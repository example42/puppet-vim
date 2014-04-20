# Class: vim::params
#
# This class defines default parameters used by the main module class vim
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to vim class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class vim::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    'Gentoo' => 'app-editors/vim',
    default  => 'vim-common',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/vim',
  }

  $config_file = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint|Gentoo)/ => '/etc/vim/vimrc',
    default                          => '/etc/vimrc',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  # General Settings
  $my_class = ''
  $source = ''
  $source_dir = ''
  $source_dir_purge = false
  $template = ''
  $options = ''
  $version = 'present'
  $absent = false

  $audit_only = false

}
