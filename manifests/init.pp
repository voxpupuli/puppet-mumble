class mumble(
  $autostart          = true,  # Start server at boot
  $ppa                = false,  # Use PPA
  $snapshot           = false, # PPA only: use snapshot over release
  $server_password    = undef,    # Supervisor account password

  # The following parameters affect mumble-server.ini through a template
  # For more info, see http://mumble.sourceforge.net/Murmur.ini
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
    'Ubuntu': {
      if $ppa {
        apt::ppa { 'ppa:mumble/snapshot':
          # ensure => $snapshot ? { true => 'present', false => 'absent' },
          before => Package['mumble-server'],
        }
        apt::ppa { 'ppa:mumble/release':
          # ensure => $snapshot ? { false => 'present', true => 'absent' },
          before => Package['mumble-server']
        }
      }
      else {
        # apt::ppa { ['ppa:mumble/snapshot', 'ppa:mumble/release']:
        #   ensure => 'absent'
        # }
      }
      # Missing dependency for 12.04 and 14.04 even with PPA
      package { 'libicu-dev':
        ensure => present,
        before => Package['mumble-server']
      }
    }
    default: {
      fail("${::operatingsystem} is not yet supported.")
    }
  }

  package { 'mumble-server':
    ensure => present
  }

  group { $group:
    ensure  => present,
    require => Package['mumble-server']
  }

  user { $user:
    ensure  => present,
    gid     => $group,
    require => [Group[$group], Package['mumble-server']]
  }

  file { '/etc/mumble-server.ini' :
    owner   => $user,
    group   => $group,
    replace => true,
    content => template('mumble/mumble-server.erb'),
    require => Package['mumble-server']
  }

  service { 'mumble-server':
    ensure    => 'running',
    enable    => $autostart,
    subscribe => File['/etc/mumble-server.ini']
  }

  if $server_password != undef {
    exec { 'mumble_set_password':
      command => "/usr/sbin/murmurd -supw ${server_password}",
      require => Service['mumble-server']
    }
  }
}
