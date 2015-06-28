# Puppet module: vim

## DEPRECATION NOTICE
This module is no more actively maintained and will hardly be updated.

Please find an alternative module from other authors or consider [Tiny Puppet](https://github.com/example42/puppet-tp) as replacement.

If you want to maintain this module, contact [Alessandro Franceschi](https://github.com/alvagante)


This is a Puppet module for vim
It provides only package installation and file configuration.

Based on Example42 layouts by Alessandro Franceschi / Lab42

Official site: http://www.example42.com

Official git repository: http://github.com/example42/puppet-vim

Released under the terms of Apache 2 License.

This module requires the presence of Example42 Puppi module in your modulepath.


## USAGE - Basic management

* Install vim with default settings

        class { 'vim': }

* Install a specific version of vim package

        class { 'vim':
          version => '1.0.1',
        }

* Remove vim resources

        class { 'vim':
          absent => true
        }

* Enable auditing without without making changes on existing vim configuration files

        class { 'vim':
          audit_only => true
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file 

        class { 'vim':
          source => [ "puppet:///modules/example42/vim/vim.conf-${hostname}" , "puppet:///modules/example42/vim/vim.conf" ], 
        }


* Use custom source directory for the whole configuration dir

        class { 'vim':
          source_dir       => 'puppet:///modules/example42/vim/conf/',
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file. Note that template and source arguments are alternative. 

        class { 'vim':
          template => 'example42/vim/vim.conf.erb',
        }

* Automatically include a custom subclass

        class { 'vim':
          my_class => 'example42::my_vim',
        }


[![Build Status](https://travis-ci.org/example42/puppet-vim.png?branch=master)](https://travis-ci.org/example42/puppet-vim)
