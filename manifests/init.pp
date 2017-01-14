# Class: mumble
#
# This class manages mumble on Debian based systems.
#
# @example Install mumble and configure an entrance password
#   class { 'mumble':
#     password => 'Fo0b@rr',
#   }
#
# @param autostart start server at boot.
#   Default value: true
# @param ppa use Ubuntu PPA instead default APT repos.
#   Default value: false
# @param snapshot (PPA only) use snapshot over release.
#   Default value: false
# @param libicu_fix install libicu-dev to fix dependency.
#   Default value: false
# @param server_password supervisor account password (mumble admin).
#   Default value: undef
# @param version configure the version of mumble to install.
#   Default value: installed
# @param register_name muble server name. (This parameter affect mumble-server.ini through a template. For more info, see http://mumble.sourceforge.net/Murmur.ini)
#   Default value: 'Mumble Server'
# @param password general entrance password.
#   Default value: ''
# @param port port to bind TCP and UDP sockets to.
#   Default value: '64738'
# @param host IP or hostname to bind to. (If this is left blank (default), Murmur will bind to all available addresses).
#   Default value: ''
# @param user username used to start mumble.
#   Default value: 'mumble-server'
# @param group mumble server group
#   Default value: 'mumble-server'
# @param bandwidth maximum bandwidth (in bits per second) clients are allowed).
#   Default value: '72000'
# @param users maximum number of concurrent clients allowed.
#   Default value: '100'
# @param text_length_limit maximum length of text messages in characters. 0 for no limit.
#   Default value: '5000'
# @param autoban_attempts how many login attempts do we tolerate from one IP? (0 to disable).
#   Default value: '10'
# @param autoban_time_frame time interval (0 to disable).
#   Default value: '120'
# @param autoban_time bantime duration in seconds (0 to disable).
#   Default value: '300'
# @param database_path path to database.
#   Default value: '/var/lib/mumble-server/mumble-server.sqlite'
#   Allowed values: absolute path
# @param log_path path to logfile
#   Default value: '/var/log/mumble-server/mumble-server.log',
#   Allowed values: absolute path
# @param allow_html allow clients to use HTML in messages, user comments and channel descriptions?
#   Default value: 'true'
# @param log_days log entries in an internal database (set to 0 to keep forever, or -1 to disable logging to the DB).
#   Default value: '31'
# @param ssl_cert ssl certificate.
#   Default value: ''
# @param ssl_key key file.
#   Default value: ''
# @param welcome_text a welcome formated text.
#   Default value: '<br />Welcome to this server running <b>Murmur</b>.<br />Enjoy your stay!<br />'
#
class mumble(
  $autostart          = true,      # Start server at boot
  $ppa                = false,     # Use PPA
  $snapshot           = false,     # PPA only: use snapshot over release
  $libicu_fix         = false,     # install libicu-dev to fix dependency
  $server_password    = undef,     # Supervisor account password
  $version            = installed, # Version of mumble to install

  # The following parameters affect mumble-server.ini through a template
  # For more info, see http://mumble.sourceforge.net/Murmur.ini
  $register_name      = 'Mumble Server',
  $password           = '',    # General entrance password
  $port               = 64738,
  $host               = '',
  $user               = 'mumble-server',
  $group              = 'mumble-server',
  $bandwidth          = 72000,
  $users              = 100,
  $text_length_limit  = 5000,
  $autoban_attempts   = 10,
  $autoban_time_frame = 120,
  $autoban_time       = 300,
  $database_path      = '/var/lib/mumble-server/mumble-server.sqlite',
  $log_path           = '/var/log/mumble-server/mumble-server.log',
  $allow_html         = true,
  $log_days           = 31,
  $ssl_cert           = '',
  $ssl_key            = '',
  $welcome_text       = '<br />Welcome to this server running <b>Murmur</b>.<br />Enjoy your stay!<br />',
  ) {

  case $::operatingsystem {
    'Debian','Ubuntu': {
      if $ppa {
        apt::ppa { 'ppa:mumble/snapshot':
          # ensure => $snapshot ? { true => 'present', false => 'absent' },
          before => Package['mumble-server'],
        }
        apt::ppa { 'ppa:mumble/release':
          # ensure => $snapshot ? { false => 'present', true => 'absent' },
          before => Package['mumble-server'],
        }
      }
      else {
        # apt::ppa { ['ppa:mumble/snapshot', 'ppa:mumble/release']:
        #   ensure => 'absent'
        # }
      }
      # Missing dependency for 12.04 with PPA
      if $libicu_fix {
        package { 'libicu-dev':
          before => Package['mumble-server'],
        }
      }
    }
    default: {
      fail("${::operatingsystem} is not yet supported.")
    }
  }

  package { 'mumble-server':
    ensure => $version,
  }

  group { $group:
    require => Package['mumble-server'],
  }

  user { $user:
    gid     => $group,
    require => [Group[$group], Package['mumble-server']],
  }

  file { '/etc/mumble-server.ini' :
    owner   => $user,
    group   => $group,
    replace => true,
    content => template('mumble/mumble-server.erb'),
    require => Package['mumble-server'],
  }

  service { 'mumble-server':
    ensure    => running,
    enable    => $autostart,
    subscribe => File['/etc/mumble-server.ini'],
  }

  if $server_password != undef {
    exec { 'mumble_set_password':
      command => "/usr/sbin/murmurd -supw ${server_password}",
      require => Service['mumble-server'],
    }
  }
}
