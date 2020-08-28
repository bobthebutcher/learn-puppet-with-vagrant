# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nginx::service
class nginx::service (
  $service_name  = $nginx::params::service_name,
) inherits nginx::params {
  service { 'nginx_service':
    ensure     => $nginx::service_ensure,
    name       => $service_name,
    enable     => $nginx::service_enable,
    hasrestart => $nginx::service_restart,
  }
}
