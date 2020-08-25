package { "ntp":
  ensure => "present",
}

file { "/etc/ntp.conf":
  ensure => "present",
  content => "server ntp.apple.com iburst\n",
}

service { "ntpd":
  ensure => "running",
}
