# andschwa-mumble

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup - The basics of getting started with andschwa-mumble](#setup)
    * [What andschwa-mumble affects](#what-andschwa-mumble-affects)
    * [Beginning with andschwa-mumble](#beginning-with-andschwa-mumble)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module installs the Mumble VoIP server, murmurd.

It is in alpha development and tested on Ubuntu 12.04.

## Module Description

This module is intended for Ubuntu. It adds either the snapshot or
release Mumble PPA, then installs mumble-server, configures it through
a template, and starts the service.

## Setup

### What andschwa-mumble affects

* Packages
    * `mumble-server`
	* `libicu-dev`
* PPAs
    * `ppa:mumble/release`
	* `ppa:mumble/snapshot`
* Services
    * `mumble-server`
* Files
    * `/etc/mumble-server.ini`
* User
    * `mumble-server`
* Group
    * `mumble-server`

### Beginning with andschwa-mumble

The simplest use of this module is:

    include mumble

### Usage

This module has one class, `mumble`, with the following
parameters:

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

Note that the mumble-server package by default sets up a user and
group named 'mumble-server', and so will be created additionally if
the user and group are changed here.

More information about the configuraiton file's settings can be found
in the [Wiki](http://mumble.sourceforge.net/Murmur.ini).

The `snapshot` parameter enables the use of the snapshot PPA, which as
of this writing, seems to fix the bug where libicui-dev was needed but
not a dependency.

The `server_password` parameter sets the supervisor account's password
by executing `murmurd -supw password`, it is not a template
configuration, and thus can be set manually as well.

## Limitations

This module currently only supports Ubuntu. It is working on my
Vagrant box, Ubuntu 12.04.4 LTS with Puppet 3.4.1, and as such it's
development is on hold.

## Development

Fork on
[GitHub](https://github.com/andschwa/puppet-mumble), make
a Pull Request.
