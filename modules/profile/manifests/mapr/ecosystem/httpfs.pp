# Class: profile::mapr::ecosystem::httpfs
#
# This module installs/configures MapR httpfs
#

class profile::mapr::ecosystem::httpfs (
) {

  require profile::mapr::configure

  $version = fact('mapr-httpfs:version')
  $file = "/opt/mapr/httpfs/httpfs-$version/etc/hadoop/httpfs-site.xml"
  $hostname = fact('networking.fqdn')

  package { 'mapr-httpfs':
    ensure  => present,
  }
  ->
  profile::hadoop::xmlconf_property {
  	default: file=>$file;
    "httpfs.authentication.type"                     : value =>"kerberos";
    "httpfs.hadoop.authentication.type"              : value =>"kerberos";
    "httpfs.hadoop.authentication.kerberos.principal": value =>"mapr/$hostname";
    "httpfs.hadoop.authentication.kerberos.keytab"   : value =>"/opt/mapr/conf/mapr.keytab";
    "httpfs.authentication.kerberos.name.rules"      : value =>"DEFAULT";
  }
  ->
  file_line { 'httpfs active-active':
    ensure             => 'present',
    path               => '/opt/mapr/conf/conf.d/warden.httpfs.conf',
    line               => 'services=httpfs:3',
    match              => '^services\=httpfs:1',
    append_on_no_match => false,
    notify             => Class['profile::mapr::warden_restart'],
  }


}
