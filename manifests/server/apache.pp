# == Class: backuppc::server::apache
#
# This module manages apache.
#
# === Parameters
#
# === Variables
#
# [*docroot*]
#   The docroot for the vhost.
#
class backuppc::server::apache {

  anchor{'backuppc::server::apache::begin':}

  # == variables ==
  $docroot = $backuppc::cgi_directory

  class { '::apache':
    default_vhost => false,
    require       => Anchor['backuppc::server::apache::begin'],
  }

  class{'apache::mod::rewrite' :}
  class{'apache::mod::wsgi'    :}
  class{'apache::mod::ssl'     :}

  apache::vhost { 'backuppc':
    servername => $::fqdn,
    port       => '80',
    docroot    => $docroot,
    rewrites   => [
      {
        comment      => 'redirect to https',
        rewrite_cond => ['%{HTTPS} off'],
        rewrite_rule => ['(.*) https://%{HTTP_HOST}:443%{REQUEST_URI}'],
      },
    ],
  }

  apache::vhost{'backuppc-ssl':
    servername      => $::fqdn,
    ip              => '*',
    port            => '443',
    docroot         => $docroot,
    default_vhost   => true,
    ssl             => true,
    ssl_cert        => $backuppc::ssl_cert,
    ssl_key         => $backuppc::ssl_key,
    ssl_chain       => $backuppc::ssl_chain,
    error_log_file  => 'backuppc_error.log',
    access_log_file => 'access.log',
    docroot_owner   => 'www-data',
    docroot_group   => 'www-data',
    directories     => [
      {
        path           => $docroot,
        allow_override => ['None'],
        #options        => ['ExecCGI', 'FollowSymlinks'],
        options        => ['+ExecCGI', '-MultiViews', '+FollowSymLinks'],
        addhandlers    => [ {
                            handler    => 'cgi-script',
                            extensions => ['.cgi']
                            }
                          ],
        directoryindex => 'index.cgi',
        auth_user_file => $backuppc::htpasswd_apache,
        auth_type      => 'Basic',
        auth_name      => 'BackupPC',
        auth_require   => 'valid-user',
      },
    ],
    aliases         => [
      {
        alias => '/backuppc',
        path  => $backuppc::cgi_directory
      }
    ],
  }
  anchor{'backuppc::server::apache::end':
    require => Class['::apache'],
  }
}
