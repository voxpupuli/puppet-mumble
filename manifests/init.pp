# @summary This class manages mumble on Debian based systems.
#
# @example Install mumble and configure an entrance password
#   class { 'mumble':
#     password => 'Fo0b@rr',
#   }
#
# @param package_name
#   the name of the package to install
#
# @param autostart
#   start server at boot.
#
# @param ppa
#   use Ubuntu PPA instead default APT repos.
#
# @param snapshot
#   (PPA only) use snapshot over release.
#
# @param libicu_fix
#   install libicu-dev to fix dependency.
#
# @param server_password
#   supervisor account password (mumble admin).
#
# @param version
#   configure the version of mumble to install.
#
# @param register_name
#   muble server name. (This parameter affect mumble-server.ini through a template.
#   For more info, see http://mumble.sourceforge.net/Murmur.ini)
#
# @param password
#   general entrance password.
#
# @param port
#   port to bind TCP and UDP sockets to.
#
# @param host
#   IP or hostname to bind to. (If this is left blank (default), Murmur will bind to all available addresses).
#
# @param user
#   username used to start mumble.
#
# @param group
#   mumble server group
#
# @param binary_path
#   path to server binary
#
# @param bandwidth
#   maximum bandwidth (in bits per second) clients are allowed).
#
# @param users
#   maximum number of concurrent clients allowed.
#
# @param text_length_limit
#   maximum length of text messages in characters. 0 for no limit.
#
# @param autoban_attempts
#   how many login attempts do we tolerate from one IP? (0 to disable).
#
# @param autoban_time_frame
#   time interval (0 to disable).
#
# @param autoban_time
#   bantime duration in seconds (0 to disable).
#
# @param database_path
#   path to database
#
# @param log_path
#   path to logfile
#
# @param allow_html
#   allow clients to use HTML in messages, user comments and channel descriptions?
#
# @param log_days
#   log entries in an internal database (set to 0 to keep forever, or -1 to disable logging to the DB).
#
# @param ssl_cert
#   ssl certificate.
#
# @param ssl_key
#   key file.
#
# @param welcome_text
#   a welcome formated text.
#
# @param config_path
#   path to the config file
#
class mumble (
  String[1] $package_name = 'mumble-server',
  Boolean $autostart = true,
  Boolean $ppa = false,
  Boolean $snapshot = false,
  Boolean $libicu_fix = false,
  String[1] $version = installed,
  String[1] $register_name = 'Mumble Server',
  Stdlib::Port $port = 64738,
  String[1] $user = 'mumble-server',
  String[1] $group = 'mumble-server',
  Stdlib::AbsolutePath $binary_path = '/usr/sbin/murmurd',
  Integer $bandwidth = 72000,
  Integer $users = 100,
  Integer $text_length_limit = 5000,
  Integer $autoban_attempts = 10,
  Integer $autoban_time_frame = 120,
  Integer $autoban_time = 300,
  Stdlib::AbsolutePath $database_path = '/var/lib/mumble-server/mumble-server.sqlite',
  Stdlib::AbsolutePath $log_path = '/var/log/mumble-server/mumble-server.log',
  Boolean $allow_html = true,
  Integer $log_days = 31,
  Optional[String] $host = undef,
  Optional[String] $password = undef,
  Optional[String] $server_password = undef,
  Optional[Stdlib::AbsolutePath] $ssl_cert = undef,
  Optional[Stdlib::AbsolutePath] $ssl_key = undef,
  String $welcome_text = '<br />Welcome to this server running <b>Murmur</b>.<br />Enjoy your stay!<br />',
  Stdlib::AbsolutePath $config_path = '/etc/mumble-server.ini',
) {
  case $facts['os']['name'] {
    'Debian','Ubuntu': {
      if $ppa {
        apt::ppa { 'ppa:mumble/snapshot':
          before => Package[$package_name],
        }
        apt::ppa { 'ppa:mumble/release':
          before => Package[$package_name],
        }
      }
      # Missing dependency for 12.04 with PPA
      if $libicu_fix {
        package { 'libicu-dev':
          before => Package['mumble-server'],
        }
      }
    }
    default: {
      fail("${facts['os']['name']} is not yet supported.")
    }
  }

  package { 'mumble-server':
    ensure => $version,
  }

  group { $group:
    require => Package[$package_name],
  }

  user { $user:
    gid     => $group,
    require => [Group[$group], Package[$package_name]],
  }

  file { $config_path:
    owner   => $user,
    group   => $group,
    replace => true,
    content => epp('mumble/mumble-server.epp', {
      'log_path'           => $log_path,
      'welcome_text'       => $welcome_text,
      'port'               => $port,
      'host'               => $host,
      'password'           => $password,
      'bandwidth'          => $bandwidth,
      'users'              => $users,
      'text_length_limit'  => $text_length_limit,
      'allow_html'         => $allow_html,
      'log_days'           => $log_days,
      'register_name'      => $register_name,
      'ssl_cert'           => $ssl_cert,
      'ssl_key'            => $ssl_key,
      'user'               => $user,
      'autoban_attempts'   => $autoban_attempts,
      'autoban_time_frame' => $autoban_time_frame,
      'autoban_time'       => $autoban_time,
    }),
    require => Package[$package_name],
  }

  service { 'mumble-server':
    ensure    => running,
    enable    => $autostart,
    subscribe => File[$config_path],
  }

  if $server_password != undef {
    exec { 'mumble_set_password':
      command  => "${binary_path} -supw ${shell_escape($server_password)} 2>&1 | /bin/grep 'Superuser password set on server' && /usr/bin/touch /etc/mumble-server-puppet", # lint:ignore:140chars
      creates  => '/etc/mumble-server-puppet',
      require  => Service['mumble-server'],
      provider => 'shell',
    }
  }
}
