class mumble(
  $autostart          = true,  # Start server at boot
  $snapshot           = false, # Use snapshot over release PPA
  $server_password    = '',    # Supervisor account password

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

  case $operatingsystem {
    'Ubuntu': {
      if $mumble::snapshot {
        apt::ppa { 'ppa:mumble/snapshot':
          before => Package['mumble-server']
        }
      }
      else {
        apt::ppa { 'ppa:mumble/release':
          before => Package['mumble-server']
        }

        package { 'libicu-dev':
          ensure => present,
        }
      }
    }
    default: {
      fail("${operatingsystem} is not yet supported.")
    }
  }

  package { [ 'mumble-server' ]: 
    ensure => latest,
  }

  group { $mumble::group:
    ensure => present,
  }

  user { $mumble::user:
    ensure  => present,
    gid     => $mumble::group,
    require => Group[$mumble::group],
  }

  file { '/etc/mumble-server.ini' :
    owner   => $mumble::user,
    group   => $mumble::group,
    replace => true,
    content => template('mumble/mumble-server.erb'),
    require => Package['mumble-server']
  }

  service { 'mumble-server':
    ensure    => 'running',
    enable    => $mumble::autostart,
    subscribe => File['/etc/mumble-server.ini'],
  }

  if $password != '' {
    exec { 'mumble_set_password':
      command => '/usr/sbin/murmurd -supw ${password}',
      require => Service['mumble-server']
    }
  }
}
