# == Class: backuppc::server::install
#
# This module manages installing backuppc
#
# === Parameters
#
# === Variables
#
#
class backuppc::server::install {
  anchor{'backuppc::server::install::begin':}

  # Include preseeding for debian packages
  if $::osfamily == 'Debian' {
    file{'/var/cache/debconf/backuppc.seeds':
      ensure  => $backuppc::ensure,
      source  => 'puppet:///modules/backuppc/backuppc.preseed',
      require => Anchor['backuppc::server::install::begin'],
    }

    package{$backuppc::required_packages:
      ensure  => installed,
      require => File['/var/cache/debconf/backuppc.seeds'],
      before  => Package[$backuppc::package],
    }
  }

  # BackupPC package and service configuration
  package { $backuppc::package:
    ensure  => $backuppc::ensure,
    require => Anchor['backuppc::server::install::begin'],
  }

  anchor{'backuppc::server::install::end':
    require => Package[$backuppc::package],
  }
}