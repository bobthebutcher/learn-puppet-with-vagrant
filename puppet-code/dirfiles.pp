file { "/tmp/testdir/":
  ensure => "directory",
}

file { "/tmp/testdir/testing123.txt":
  ensure => "present",
  content => "blah bleh",
}

