# == Class: backuppc
#
# This module manages backuppc
#
# === Parameters
#
# [*ensure*]
# Present or absent
#
# [*service_enable*]
# Boolean. Will enable service at boot
# and ensure a running service.
#
# [*xfer_method*]
#   Options: rsync or tar
#   Default: tar
#
# [*tar_client_cmd*]
#   The client command for tar.
#   Default: '$sshPath -q -x -n -l backup $host env LC_ALL=C sudo $tarPath -c
#             -v -f - -C $shareName+ --totals',
#
# [*tar_client_restore_cmd*]
#   Default: '$sshPath -q -x -l backup $host env LC_ALL=C sudo $tarPath -x -p
#             --numeric-owner --same-owner -v -f - -C $shareName+'
#
# [*wakup_schedule*]
# Times at which we wake up, check all the PCs,
# and schedule necessary backups. Times are measured
# in hours since midnight. Can be fractional if
# necessary (eg: 4.25 means 4:15am).
#
# [*max_backups*]
# Maximum number of simultaneous backups to run. If
# there are no user backup requests then this is the
# maximum number of simultaneous backups.
#
# [*max_user_backups*]
# Additional number of simultaneous backups that users
# can run. As many as $Conf{MaxBackups} + $Conf{MaxUserBackups}
# requests can run at the same time.
#
# [*max_pending_cmds*]
# Maximum number of pending link commands. New backups will only
# be started if there are no more than $Conf{MaxPendingCmds} plus
# $Conf{MaxBackups} number of pending link commands, plus running
# jobs. This limit is to make sure BackupPC doesn't fall too far
# behind in running BackupPC_link commands.
#
# [*max_backup_pc_nightly_jobs*]
# How many BackupPC_nightly processes to run in parallel. Each night,
# at the first wakeup listed in $Conf{WakeupSchedule}, BackupPC_nightly
# is run. Its job is to remove unneeded files in the pool, ie: files that
# only have one link. To avoid race conditions, BackupPC_nightly and
# BackupPC_link cannot run at the same time. Starting in v3.0.0,
# BackupPC_nightly can run concurrently with backups (BackupPC_dump).
#
# [*backup_pc_nightly_period*]
# How many days (runs) it takes BackupPC_nightly to traverse the entire pool.
# Normally this is 1, which means every night it runs, it does traverse the
# entire pool removing unused pool files.
#
# [*max_old_log_files*]
# Maximum number of log files we keep around in log directory. These files are
# aged nightly. A setting of 14 means the log directory will contain about
# 2 weeks of old log files, in particular at most the files LOG, LOG.0,
# LOG.1, ... LOG.13 (except today's LOG, these files will have a .z extension
# if compression is on).
#
# [*df_max_usage_pct*]
# Maximum threshold for disk utilization on the __TOPDIR__ filesystem.
# If the output from $Conf{DfPath} reports a percentage larger than this number
# then no new regularly
# scheduled backups will be run. However, user requested backups
# (which are usually
# incremental and tend to be small) are still performed, independent of disk
# usage. Also, currently running backups will not be terminated when the disk
# usage exceeds this number.
#
# [*trash_clean_sleep_sec*]
# How long BackupPC_trashClean sleeps in seconds between each check of the
# trash directory.
#
# [*dhcp_address_ranges*]
# List of DHCP address ranges we search looking for PCs to backup. This is an
# array of hashes for each class C address range. This is only needed if hosts
# in the conf/hosts file have the dhcp flag set.
#
# [*full_period*]
# Minimum period in days between full backups. A full dump will only be done
# if at least this much time has elapsed since the last full dump, and at least
# $Conf{IncrPeriod} days has elapsed since the last successful dump.
#
# [*full_keep_cnt*]
# Number of full backups to keep.
#
# [*full_age_max*]
# Very old full backups are removed after $Conf{FullAgeMax} days. However,
# we keep at least $Conf{FullKeepCntMin} full backups no matter how old they
# are.
#
# [*incr_period*]
# Minimum period in days between incremental backups (a user requested
# incremental backup will be done anytime on demand).
#
# [*incr_keep_cnt*]
# Number of incremental backups to keep.
#
# [*incr_age_max*]
# Very old incremental backups are removed after $Conf{IncrAgeMax} days.
# However, we keep at least $Conf{IncrKeepCntMin} incremental backups no matter
# how old they are.
#
# [*incr_levels*]
# A full backup has level 0. A new incremental of level N will backup all files
# that have changed since the most recent backup of a lower level.
#
# [*partial_age_max*]
# A failed full backup is saved as a partial backup. The rsync XferMethod can
# take advantage of the partial full when the next backup is run. This parameter
# sets the age of the partial full in days: if the partial backup is older than
# this number of days, then rsync will ignore (not use) the partial full when
# the next backup is run. If you set this to a negative value then no partials
# will be saved. If you set this to 0, partials will be saved, but will not be
# used by the next backup.
#
# [*incr_fill*]
# Boolean. Whether incremental backups are filled. "Filling" means that the
# most recent fulli (or filled) dump is merged into the new incremental dump
# using hardlinks. This makes an incremental dump look like a full dump.
#
# [*restore_info_keep_cnt*]
# Number of restore logs to keep. BackupPC remembers information about each
# restore request. This number per client will be kept around before the oldest
# ones are pruned.
#
# [*archive_info_keep_cnt*]
# Number of archive logs to keep. BackupPC remembers information about each
# archive request. This number per archive client will be kept around before
# the oldest ones are pruned.
#
# [*blackout_good_cnt*]
# PCs that are always or often on the network can be backed up after hours,
# to reduce PC, network and server load during working hours. For each PC a
# count of consecutive good pings is maintained. Once a PC has at least
# $Conf{BlackoutGoodCnt} consecutive good pings it is subject to "blackout" and
# not backed up during hours and days specified by $Conf{BlackoutPeriods}.
#
# [*blackout_zero_files_is_fatal*]
# Boolean. A backup of a share that has zero files is considered fatal.
# This is used to catch miscellaneous Xfer errors that result in no files being
# backed up. If you have shares that might be empty (and therefore an empty
# backup is valid) you should set this to false.
#
# [*email_notify_min_days*]
# Minimum period between consecutive emails to a single user. This tries to
# keep annoying email to users to a reasonable level.
#
# [*email_from_user_name*]
# Name to use as the "from" name for email.
#
# [*email_admin_user_name*]
# Destination address to an administrative user who will receive a nightly
# email with warnings and errors.
#
# [*email_notify_old_backup_days*]
# How old the most recent backup has to be before notifying user. When there
# have been no backups in this number of days the user is sent an email.
#
# [*email_headers*]
# Additional email headers.
#
# [*cmd_queue_nice*]
#   Nice level at which CmdQueue commands (eg: BackupPC_link and
#   BackupPC_nightly) are run at.
#   Default: '10'
#
# [*apache_configuration*]
#   Boolean. Whether to install the apache configuration file that creates an
#   alias for the /backuppc url. Disable this if you intend to install backuppc
#   as a virtual host yourself.
#   Uses the puppetlaps/apache module for managing apache.  It also forces
#   SSL (https) redirecting port 80 traffic to port 443.
#   Default: true
#
# [*ssl_cert*]
#   If apache_configuration set, than this is the full path to the apache
#   cert file.
#   Default: '/etc/ssl/certs/ssl-cert-snakeoil.pem'
#
# [*ssl_key*]
#   If apache_configuration set, than this is the full path to the apache
#   key file.
#   Default: '/etc/ssl/private/ssl-cert-snakeoil.key'
#
# [*ssl_chain*]
#   If apache_configuration set, than this is the full path tot he chain file.
#   Default: undef
#
# [*apache_allow_from*]
# A space seperated list of hostnames, ip addresses and networks that
# are permitted to access the backuppc interface.
#
# [*backuppc_password*]
# Password for the backuppc user used to access the web interface.
#
# [*topdir*]
# Overwrite package default location for backuppc.
# NOTE: THIS REQUIRES MANUAL INTERVENTION.  You MUST copy the contents of
# /var/lib/backuppc to the new topdir.  THIS REQUIRES AN IMPROVEMENT.
#
# === Examples
#
#  See tests folder.
#
# === Authors
#
# Scott Barr <gsbarr@gmail.com>
#
class backuppc (
  $ensure                       = 'present',
  $service_enable               = true,
  $xfer_method                  = 'tar',
  $tar_client_cmd               = '$sshPath -q -x -n -l backup $host env LC_ALL=C sudo $tarPath -c -v -f - -C $shareName+ --totals',
  $tar_client_restore_cmd       = '$sshPath -q -x -l backup $host env LC_ALL=C sudo $tarPath -x -p --numeric-owner --same-owner -v -f - -C $shareName+',
  $wakeup_schedule              =
    [
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
      14, 15, 16, 17, 18, 19, 20, 21, 22, 23
    ],
  $max_backups                  = 4,
  $max_user_backups             = 4,
  $max_pending_cmds             = 15,
  $max_backup_pc_nightly_jobs   = 2,
  $backup_pc_nightly_period     = 1,
  $max_old_log_files            = 14,
  $df_max_usage_pct             = 95,
  $trash_clean_sleep_sec        = 300,
  $dhcp_address_ranges          = [],
  $full_period                  = '6.97',
  $full_keep_cnt                = 1,
  $full_age_max                 = 90,
  $incr_period                  = '0.97',
  $incr_keep_cnt                = 6,
  $incr_age_max                 = 30,
  $incr_levels                  = [1],
  $incr_fill                    = false,
  $partial_age_max              = 3,
  $restore_info_keep_cnt        = 10,
  $archive_info_keep_cnt        = 10,
  $blackout_good_cnt            = 7,
  $blackout_periods             = [
    {
      hourBegin =>  7.0,
      hourEnd   => 19.5,
      weekDays  => [1, 2, 3, 4, 5],
    }],
  $blackout_zero_files_is_fatal = true,
  $email_notify_min_days        = 2.5,
  $email_from_user_name         = 'backuppc',
  $email_admin_user_name        = 'backuppc',
  $email_notify_old_backup_days = 7,
  $email_headers                =
  { 'MIME-Version' => 1.0,
    'Content-Type' => 'text/plain; charset="iso-8859-1"',
  },
  $cmd_queue_nice               = '10',
  $apache_configuration         = true,
  $apache_allow_from            = 'all',
  $ssl_cert                     = $backuppc::params::ssl_cert,
  $ssl_key                      = $backuppc::params::ssl_key,
  $ssl_chain                    = $backuppc::params::ssl_chain,
  $backuppc_password            = '',
  $topdir                       = $backuppc::params::topdir
) inherits backuppc::params {

  if empty($backuppc_password) {
    fail("Please provide a password for the backuppc user.\
 This is used to login to the web based administration site.")
  }
  validate_bool($service_enable)

  validate_re($ensure, '^(present|absent)$',
  'ensure parameter must have a value of: present or absent')

  validate_re($max_backups, '^[1-9]([0-9]*)?$',
  'Max_backups parameter should be a number')

  validate_re($max_user_backups, '^[1-9]([0-9]*)?$',
  'Max_user_backups parameter should be a number')

  validate_re($max_pending_cmds, '^[1-9]([0-9]*)?$',
  'Max_pending_cmds parameter should be a number')

  validate_re($max_backup_pc_nightly_jobs, '^[1-9]([0-9]*)?$',
  'Max_backup_pc_nightly_jobs parameter should be a number')

  validate_re($df_max_usage_pct, '^[1-9]([0-9]*)?$',
  'Df_max_usage_pct parameter should be a number')

  validate_re($max_old_log_files, '^[1-9]([0-9]*)?$',
  'Max_old_log_files parameter should be a number')

  validate_re($backup_pc_nightly_period, '^[1-9]([0-9]*)?$',
  'Backup_pc_nightly_period parameter should be a number')

  validate_re($trash_clean_sleep_sec,  '^[1-9]([0-9]*)?$',
  'Trash_clean_sleep_sec parameter should be a number')

  validate_re($full_period, '^[0-9]([0-9]*)?(\.[0-9]{1,2})?$',
  'Full_period parameter should be a number')

  validate_re($incr_period, '^[0-9]([0-9]*)?(\.[0-9]{1,2})?$',
  'Incr_period parameter should be a number')

  # can be an array of numbers so not a valid test!
  #validate_re($full_keep_cnt, '^[1-9]([0-9]*)?$',
  #'Full_keep_cnt parameter should be a number')

  validate_re($full_age_max, '^[1-9]([0-9]*)?$',
  'Full_age_max parameter should be a number')

  validate_re($incr_keep_cnt, '^[1-9]([0-9]*)?$',
  'Incr_keep_cnt parameter should be a number')

  validate_re($incr_age_max, '^[1-9]([0-9]*)?$',
  'Incr_age_max parameter should be a number')

  validate_re($partial_age_max, '^[1-9]([0-9]*)?$',
  'Partial_age_max parameter should be a number')

  validate_re($restore_info_keep_cnt, '^[1-9]([0-9]*)?$',
  'Restore_info_keep_cnt parameter should be a number')

  validate_re($archive_info_keep_cnt, '^[1-9]([0-9]*)?$',
  'Restore_info_keep_cnt parameter should be a number')

  validate_re($blackout_good_cnt, '^[1-9]([0-9]*)?$',
  'Blackout_good_cnt parameter should be a number')

  validate_re($email_notify_min_days, '^[0-9]([0-9]*)?(\.[0-9]{1,2})?$',
  'Email_notify_min_days parameter should be a number')

  validate_re($email_notify_old_backup_days, '^[1-9]([0-9]*)?$',
  'Blackout_good_cnt parameter should be a number')

  validate_array($wakeup_schedule)
  validate_array($dhcp_address_ranges)
  validate_array($incr_levels)
  validate_array($blackout_periods)

  validate_hash($email_headers)

  validate_string($apache_allow_from)

  $real_incr_fill = bool2num($incr_fill)
  $real_bzfif     = bool2num($blackout_zero_files_is_fatal)

  # Set up dependencies
  Package[$package] -> File[$config] -> Service[$service]

  # Include preseeding for debian packages
  if $::osfamily == 'Debian' {
    file{'/var/cache/debconf/backuppc.seeds':
      ensure => $ensure,
      source => 'puppet:///modules/backuppc/backuppc.preseed',
    }
    package{$required_packages:
      ensure  => installed,
      require => File['/var/cache/debconf/backuppc.seeds'],
      before  => Package[$package],
    }
  }

  # BackupPC package and service configuration
  package { $package:
    ensure  => $ensure,
  }

  service { $service:
    ensure    => $service_enable,
    enable    => $service_enable,
    hasstatus => false,
    pattern   => 'BackupPC'
  }

  file { $config:
    ensure  => $ensure,
    owner   => 'backuppc',
    group   => $group_apache,
    mode    => '0644',
    content => template('backuppc/config.pl.erb'),
  }

  file { $config_directory:
    ensure  => $ensure,
    owner   => 'backuppc',
    group   => $group_apache,
    require => Package[$package],
  }

  file { "${config_directory}/pc":
    ensure  => link,
    target  => $config_directory,
    require => Package[$package],
  }

  file { [$topdir, "${topdir}/.ssh"]:
    ensure  => 'directory',
    recurse => true,
    owner   => 'backuppc',
    group   => $group_apache,
    mode    => '0644',
    ignore => '*.sock',
  }

  # Workaround for client exported resources that are
  # on a different osfamily. Maintain a symlink to alternative
  # config directory targets.
  case $osfamily {
    'Debian': {
      file { '/etc/BackupPC':
        ensure => link,
        target => $config_directory,
      }
    }
    'RedHat': {
      file { '/etc/backuppc':
        ensure => link,
        target => $config_directory,
      }
    }
    default: {
      notify { "If you've added support for ${::operatingsystem} you'll need\
 to extend this case statement to.":
      }
    }
  }

  exec { 'backuppc-ssh-keygen':
    command =>
    "ssh-keygen -f ${topdir}/.ssh/id_rsa -C 'BackupPC on ${::fqdn}' -N ''",
    user    => 'backuppc',
    unless  => "test -f ${topdir}/.ssh/id_rsa",
    path    => ['/usr/bin','/bin'],
    require => [
        Package[$package],
        File["${topdir}/.ssh"],
    ],
  }

  # BackupPC apache configuration
  if $apache_configuration {
    class{'backuppc::server::apache':
      require => Package[$package],
      before  => Backuppc::Server::User['backuppc'],
    }
  }
  # Create the default admin account
  backuppc::server::user { 'backuppc':
    password => $backuppc_password
  }

  # Export backuppc's authorized key to all clients
  # TODO don't rely on facter to obtain the ssh key.
  if ! empty($backuppc_pubkey_rsa) {
    @@ssh_authorized_key { "backuppc_${::fqdn}":
      ensure  => present,
      key     => $backuppc_pubkey_rsa,
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
    }
  }

  # Hosts
  File <<| tag == "backuppc_config_${::fqdn}" |>> {
    group   => $group_apache,
    notify  => Service[$service],
    require => File["${config_directory}/pc"],
  }
  File_line <<| tag == "backuppc_hosts_${::fqdn}" |>> {
    require => Package[$package],
  }

  # Ensure readable file permissions on
  # the known hosts file.
  file { '/etc/ssh/ssh_known_hosts':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  Sshkey <<| tag == "backuppc_sshkeys_${::fqdn}" |>>
}
