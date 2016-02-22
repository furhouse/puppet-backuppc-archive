# == Class: backuppc::server::validate
#
# Handles param validation.
#
# === Parameters
#
# === Variables
#
#
class backuppc::server::validate {
  anchor{'backuppc::server::validate::begin':}

  if empty($backuppc::backuppc_password) {
    fail("Please provide a password for the backuppc user.\
 This is used to login to the web based administration site.")
  }
  validate_bool($backuppc::service_enable)

  validate_re($backuppc::ensure, '^(present|absent)$',
  'ensure parameter must have a value of: present or absent')

  validate_re($backuppc::max_backups, '^[1-9]([0-9]*)?$',
  'Max_backups parameter should be a number')

  validate_re($backuppc::max_user_backups, '^[1-9]([0-9]*)?$',
  'Max_user_backups parameter should be a number')

  validate_re($backuppc::max_pending_cmds, '^[1-9]([0-9]*)?$',
  'Max_pending_cmds parameter should be a number')

  validate_re($backuppc::max_backup_pc_nightly_jobs, '^[1-9]([0-9]*)?$',
  'Max_backup_pc_nightly_jobs parameter should be a number')

  validate_re($backuppc::df_max_usage_pct, '^[1-9]([0-9]*)?$',
  'Df_max_usage_pct parameter should be a number')

  validate_re($backuppc::max_old_log_files, '^[1-9]([0-9]*)?$',
  'Max_old_log_files parameter should be a number')

  validate_re($backuppc::backup_pc_nightly_period, '^[1-9]([0-9]*)?$',
  'Backup_pc_nightly_period parameter should be a number')

  validate_re($backuppc::trash_clean_sleep_sec,  '^[1-9]([0-9]*)?$',
  'Trash_clean_sleep_sec parameter should be a number')

  validate_re($backuppc::full_period, '^[0-9]([0-9]*)?(\.[0-9]{1,2})?$',
  'Full_period parameter should be a number')

  validate_re($backuppc::incr_period, '^[0-9]([0-9]*)?(\.[0-9]{1,2})?$',
  'Incr_period parameter should be a number')

  # can be an array of numbers so not a valid test!
  #validate_re($full_keep_cnt, '^[1-9]([0-9]*)?$',
  #'Full_keep_cnt parameter should be a number')

  validate_re($backuppc::full_age_max, '^[1-9]([0-9]*)?$',
  'Full_age_max parameter should be a number')

  validate_re($backuppc::incr_keep_cnt, '^[1-9]([0-9]*)?$',
  'Incr_keep_cnt parameter should be a number')

  validate_re($backuppc::incr_age_max, '^[1-9]([0-9]*)?$',
  'Incr_age_max parameter should be a number')

  validate_re($backuppc::partial_age_max, '^[1-9]([0-9]*)?$',
  'Partial_age_max parameter should be a number')

  validate_re($backuppc::restore_info_keep_cnt, '^[1-9]([0-9]*)?$',
  'Restore_info_keep_cnt parameter should be a number')

  validate_re($backuppc::archive_info_keep_cnt, '^[1-9]([0-9]*)?$',
  'Restore_info_keep_cnt parameter should be a number')

  validate_re($backuppc::blackout_good_cnt, '^[1-9]([0-9]*)?$',
  'Blackout_good_cnt parameter should be a number')

  validate_re(
  $backuppc::email_notify_min_days, '^[0-9]([0-9]*)?(\.[0-9]{1,2})?$',
  'Email_notify_min_days parameter should be a number')

  validate_re($backuppc::email_notify_old_backup_days, '^[1-9]([0-9]*)?$',
  'Blackout_good_cnt parameter should be a number')

  validate_array($backuppc::wakeup_schedule)
  validate_array($backuppc::dhcp_address_ranges)
  validate_array($backuppc::incr_levels)
  validate_array($backuppc::blackout_periods)

  validate_hash($backuppc::email_headers)

  validate_string($backuppc::apache_allow_from)

  anchor{'backuppc::server::validate::end':}
}