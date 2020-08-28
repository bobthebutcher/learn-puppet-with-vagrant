# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nginx::install
class nginx::install (
  $package_name  = $nginx::params::package_name,
) inherits nginx::params {
  package { 'install_nginx':
    ensure => $nginx::package_ensure,
    name   => $package_name,
  }
}
