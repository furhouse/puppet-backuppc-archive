# == Class: backuppc::server::config
#
# This module manages the backuppc configuration.
#
# === Parameters
#
# === Variables
#
#
class backuppc::server::config {
  anchor{'backuppc::server::config::begin':}

  file { $backuppc::config_directory:
    ensure  => $backuppc::ensure,
    owner   => 'backuppc',
    require => Anchor['backuppc::server::config::begin'],
  }

  file { $backuppc::config:
    ensure  => $backuppc::ensure,
    owner   => 'backuppc',
    group   => $backuppc::group_apache,
    mode    => '0644',
    content => template('backuppc/config.pl.erb'),
    require => File[$backuppc::config_directory],
  }

  file { "${backuppc::config_directory}/pc":
    ensure  => link,
    target  => $backuppc::config_directory,
    require => File[$backuppc::config],
  }

  file { $backuppc::topdir :
    ensure  => 'directory',
    recurse => true,
    owner   => 'backuppc',
    group   => $backuppc::group_apache,
    mode    => '0644',
    ignore  => '*.sock',
    require => File["${backuppc::config_directory}/pc"],
  }

  ## only do if collect is enabled
  if $backuppc::collect {
    file { "${backuppc::topdir}/.ssh":
      ensure  => 'directory',
      recurse => true,
      owner   => 'backuppc',
      group   => $backuppc::group_apache,
      mode    => '0644',
      ignore  => '*.sock',
      require => File[$backuppc::topdir],
    }

    # Workaround for client exported resources that are
    # on a different osfamily. Maintain a symlink to alternative
    # config directory targets.
    case $::osfamily {
      'Debian': {
        file { '/etc/BackupPC':
          ensure  => link,
          target  => $backuppc::config_directory,
          before  => Exec['backuppc-ssh-keygen'],
          require => File["${backuppc::topdir}/.ssh"],
        }
      }
      'RedHat': {
        file { '/etc/backuppc':
          ensure  => link,
          target  => $backuppc::config_directory,
          before  => Exec['backuppc-ssh-keygen'],
          require => File["${backuppc::topdir}/.ssh"],
        }
      }
      default: {
        notify { "If you've added support for ${::operatingsystem} you'll need\
   to extend this case statement to.":
        }
      }
    }

    exec { 'backuppc-ssh-keygen':
      command => "ssh-keygen -f ${backuppc::topdir}/.ssh/id_rsa -C\
 'BackupPC on ${::fqdn}' -N ''",
      user    => 'backuppc',
      unless  => "test -f ${backuppc::topdir}/.ssh/id_rsa",
      path    => ['/usr/bin','/bin'],
      require => File["${backuppc::topdir}/.ssh"],
    }

    # Create the default admin account
    backuppc::server::user { 'backuppc':
      password => $backuppc::backuppc_password,
      require  => Exec['backuppc-ssh-keygen'],
    }

    # Export backuppcs authorized key to all clients
    if ! empty($backuppc::backuppc_pubkey_rsa) {
      @@ssh_authorized_key { "backuppc_${::fqdn}":
        ensure  => present,
        key     => $backuppc::backuppc_pubkey_rsa,
        name    => "backuppc_${::fqdn}",
        user    => 'backup',
        options => [
          'command="~/backuppc.sh"',
          'no-agent-forwarding',
          'no-port-forwarding',
          'no-pty',
          'no-X11-forwarding',
        ],
        type    => 'ssh-rsa',
        tag     => "backuppc_${::fqdn}",
        require => Backuppc::Server::User['backuppc'],
      }
    }

    # Hosts
    File <<| tag == "backuppc_config_${::fqdn}" |>> {
      group   => $backuppc::group_apache,
      require => Backuppc::Server::User['backuppc'],
    }

    File_line <<| tag == "backuppc_hosts_${::fqdn}" |>> {
      require => Backuppc::Server::User['backuppc'],
    }

    # Ensure readable file permissions on
    # the known hosts file.
    file { '/etc/ssh/ssh_known_hosts':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Backuppc::Server::User['backuppc'],
      before  => Anchor['backuppc::server::config::end'],
    }
    Sshkey <<| tag == "backuppc_sshkeys_${::fqdn}" |>>
  }

  anchor{'backuppc::server::config::end':
    require => File[$backuppc::topdir],
  }
}