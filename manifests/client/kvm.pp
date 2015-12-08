# == Class: backuppc::client::kvm
#
# Configures backups for KVM
#
# === Parameters
#
# [*backup_directory*]
#   The directory that the vm images will be backed up to.
#   Default: /var/lib/libvirt/images/virt-backup
#
# [*concurrent_mode*]
#   There are two modes to run kvm backups.
#
#   The standard mode is where all vms are shutdown at the same time,
#   images are dumped, and then all vms are started again.  This mode requires
#   the least amount of time.
#
#   Concurrent mode is where vms are shutdown sequentially, images dumped,
#   and then started again.  This means that during the backup process
#   there is minimum impact to the uptime of running vms.  Although this mode
#   takes longer to perform.
#
#   Default: false
#
# [*schedule_hour*]
#   Uses the cron resource to schedule the running
#   See: https://docs.puppetlabs.com/references/latest/type.html#cron
#   Default: '3'  # 3 am
#
# [*schedule_weekday*]
#   Uses cron.  This is the weekend parameter.
#   Default: '6'  # Saturday
#
#
class backuppc::client::kvm (
  $backup_directory = '/var/lib/libvirt/images/virt-backup',
  $concurrent_mode  = false,
  $schedule_hour    = '3',
  $schedule_weekday = '6',
  ) {
  anchor {'backuppc::client::kvm::begin': }

  # === variables === #
  $command = '/usr/local/bin/kvm-clone-dump.bash'

  # build command arguments
  if $concurrent_mode {
    $arg1 = '-o'
  }else{
    $arg1 = '-d'
  }

  $command_args = "${arg1} -d=${backup_directory}"

  # download the backup script.
  file {$command:
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/backuppc/kvm-clone-dump.bash',
    require => Anchor['backuppc::client::kvm::begin'],
  }

  # make sure the directory exists
  file {$backup_directory:
    ensure  => directory,
    require => File[$command],
  }

  # set a cron job for running the backup scripts
  # currenty set to
  cron {'kvm_backups':
    command => "${command} ${command_args}",
    hour    => $schedule_hour,
    weekday => $schedule_weekday,
    require => File[$backup_directory],
  }

  anchor {'backuppc::client::kvm::end':
    require => Cron['kvm_backups'],
  }
}