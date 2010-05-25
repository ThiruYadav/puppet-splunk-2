define service_syslog::client::apache_vhost (
    $vhost_access_log,
    $vhost_error_log
) {
    include service_syslog::client::apache

    file { "/etc/syslog-ng/extra.d/20.apache_vhost-${name}":
        content => template("service_syslog/extra.d-client/20.apache_vhost.erb"),
        notify  => Exec["syslog-ng-reload"],
        require => [
            Class["service_apache::base"],
            File["/etc/syslog-ng/extra.d/10.apache"]
        ],
    }
}
