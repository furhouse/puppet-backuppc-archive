# == Class: backuppc::server::service
#
# This module manages the backuppc service
#
# === Parameters
#
# === Variables
#
#
class backuppc::server::service {
  anchor{'backuppc::server::service::begin':}

  service { $backuppc::service:
    ensure    => $backuppc::service_enable,
    enable    => $backuppc::service_enable,
    hasstatus => false,
    pattern   => 'BackupPC',
    require   => Anchor['backuppc::server::service::begin'],
  }

  anchor{'backuppc::server::service::end':
    require => Service[$backuppc::service],
  }
}