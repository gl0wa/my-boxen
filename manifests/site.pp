require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  # include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  # if $::root_encrypted == 'no' {
  #   fail('Please enable full disk encryption and try again')
  # }

  # node versions
  include nodejs::v0_8
  include nodejs::v0_10

  # default ruby versions
  include ruby::1_8_7
  include ruby::1_9_3
  include ruby::2_0_0

  #personal:
  include openssl
  include phantomjs
  phantomjs::version { '1.9.0': }
  include pkgconfig
  include xquartz

  include mysql
  mysql::db { 'mydb': }

  include android::sdk
  include android::ndk
  include android::tools
  include android::platform_tools
  android::build_tools { '18.1.1': }
  android::extra { 'extra-google-google_play_services': }
  include android::doc
  include android::studio
  include redis
  include dropbox
  # include skype
  include memcached
  include elasticsearch
  include heroku
  include virtualbox
  include flux
  include sequel_pro
  include vlc
  include utorrent
  include skitch
  include pgadmin3
  include gimp
  include sublime_text_2
  include spotify
  include cloudapp
  include imagemagick
  include wunderlist
  include caffeine
  include firefox
  include gitx::l
  include googledrive
  include handbrake
  include licecap
  include mplayerx
  include postgresapp
  include textmate
  include tunnelblick

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
