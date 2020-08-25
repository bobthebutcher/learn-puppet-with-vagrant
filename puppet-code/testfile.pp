file { "/tmp/testfile.txt":
  ensure  => "present",
  owner   => "vagrant",
  group   => "vagrant",
  mode    => "0644",
  content => "blah blah blah",
}
