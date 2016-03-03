# BackupPC Module

[![Build Status](https://secure.travis-ci.org/wyrie/puppet-backuppc.png?branch=master)](http://travis-ci.org/wyrie/puppet-backuppc)

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Usage](#usage)
4. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)

##Overview

This module will install and configure a BackupPC server and allow you to add other puppet managed nodes as clients/hosts. It
uses exported resources to create the client's configuration file, add it to the hosts file and setup ssh access if needed.

This module started as a fork of https://github.com/codec/puppet-backuppc.

##Module Description

BackupPC has many configuration options and this module should provide you access to most of them. BackupPC's global configuration
file is managed by backuppc::server and is intended to setup useful defaults that can be overridden by the client if needed.

Where BackupPC's configuration file uses camel case for the config variables the module's class parameters would use the same names but
replacing the uppercase characters with lowercase and an underscore prefix.

For xfer methods that require ssh the module can:
* Create a non-privledged account on the client and allow it access to rsync or tar via sudo.
* Install the server's ssh key.
* Add the client's ssh key to the list of known hosts.

By default the account name is 'backup'. You can choose to do the ssh configuration yourself if it doesn't suit your environment (see the client.pp
file for notes on system_account).

The module is designed to work alongside the BackupPC web administration interface, meaning hosts that are configured but not managed by this
module will still work.

## Usage

### Minimal server configuration

```puppet
class { 'backuppc::server':
  backuppc_password => 'somesecret'
}
```
This will do the typical install, configure and service management. The module does not manage apache. It will, if the apache_configuation parameter is true,
install an apache configuration file that creates an alias from the /backuppc url to the backuppc files on the system. Additionally it will create a htpasswd
file with the default backuppc user and the password that you provide for access to the web based administration. You will however need to inform the apache
service that something has changed. Alternatively you can install backuppc as a virtual host or whatever else suits your needs.

### Additional login accounts

```puppet
backuppc::server::user { 'john':
  password => 'mypassword'
}
```
The default path to the htpasswd file is in the [config_directory]/htpasswd. You can add additional login accounts and assign these to hosts (see client examples
for this).

### More server configuration

```puppet
class { 'backuppc::server':
  backuppc_password => 'somesecret'
  wakeup_schedule   => [1, 2, 3, 4, 5, 21, 22, 23],
  max_backups       => 3,
  max_user_backups  => 1,
}
```
Please consult the BackupPC documentation for explanations on configuration options: http://backuppc.sourceforge.net/faq/BackupPC.html

Some configuration options, like xfer_method, is more useful to set when adding a client. Where a configuration parameter is ommited backuppc's default is applied
in the main/global configuration file.

### Client configuration

```puppet
class { 'backuppc::client':
  backuppc_hostname     => 'fqdn.backuppcserver.com',
  rsync_share_name      => ['/home', '/etc'],
  hosts_file_more_users => 'john',
}
```
You'll need to specify the hostname of the node on which you installed backuppc server. This value should be the same as the facter value for fqdn. By default the
xfer_method is rsync and you can specify the paths to backup with the parameter rsync_share_name. With rsync and tar methods the module will create on the client
an system account and allow the server access to it (see the description section in this readme).

### Backuping up the backuppc server itself

```puppet
class { 'backuppc::client':
  backuppc_hostname => $::fqdn,
  xfer_method       => 'tar',
  tar_share_name    => ['/home', '/etc', '/var/log'],
  tar_client_cmd    => '/usr/bin/sudo $tarPath -c -v -f - -C $shareName --totals',
  tar_full_args     => '$fileList',
  tar_incr_arge     => '--newer=$incrDate $fileList',
}
```
Debian by default installs a 'localhost' host, but if you want to managed it with puppet or if you're on Centos/RHEL this example will use the tar method to backup
the paths you sepcify. The example uses sudo which is not configured in the module itself.

##Reference

###Classes

####Public Classes

* backuppc:server: Class used to install backuppc.
* backuppc::client: Configures host for backup through backuppc.

####Private Classes

* backuppc::params: Default values.

## Limitations

* This module has been tested on Debian Wheezy, Squeeze and Centos 6.4.
* Storeconfigs need to be enabled for this module to work.
* There is a TODO for generating and installing the server's ssh key. Currently it relies on a facter value that is only present on the second run of puppet.

## Contributors
* [txaj](https://github.com/txaj)
* [solarkennedy](https://github.com/solarkennedy)

