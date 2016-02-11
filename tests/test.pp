class { 'backuppc':
  backuppc_password => 'test1234',
  full_keep_cnt     => '[4,2,1]',
  full_age_max      => '110',
}

# backup backuppc
#class { 'backuppc::client':
#  backuppc_hostname => $::fqdn,
#  client_hostname   => 'localhost',
#  xfer_method       => 'tar',
#  tar_share_name    => ['/home', '/etc',
#  '/var/log','/var/lib/libvirt/images/virt-backup'],
#  #tar_client_cmd    => '/usr/bin/sudo $tarPath -c -v -f - -C $shareName --totals',
#  #tar_incr_args     => '--newer=$incrDate $fileList',
#}

class { 'backuppc::client':
  backuppc_hostname => 'localhost',
  client_hostname   => 'localhost',
  tar_share_name    => ['/home', '/etc',
  '/var/log'],
}

### testing the kvm integration
class{ 'libvirt': }
class { 'backuppc::client::kvm':
  require => Class['libvirt']
}