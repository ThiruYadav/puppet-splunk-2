class service_splunk {
    $splunk_ssl_depth   = extlookup("service_splunk_ssl_depth", "2")
    $splunk_ssl_ca      = extlookup("service_splunk_ssl_ca")
    $splunk_ssl_var     = extlookup("service_splunk_ssl_var", "emailAddress")
    $splunk_ssl_users   = extlookup("service_splunk_ssl_users")

    include app_layman
    include os_gentoo::optpath
    include service_nginx

    package { "splunk":
        category    => "net-analyzer",
        require     => [
            Class["app_layman"],
            Class["os_gentoo::optpath"]
        ],
    }
    file {
        "/etc/ssl/nginx/${fqdn}.key":
            ensure  => undef,
            mode    => 600;
        "/etc/nginx/vhosts.d/${fqdn}.conf":
            content => template("service_splunk/nginx/nginx_vhost.conf.erb"),
            require => File["/etc/nginx/vhosts.d"],
            notify  => Service["nginx"];
    }
    file {
        "/opt/splunk/etc/system/local/web.conf":
            source  => "puppet:///modules/service_splunk/local/web.conf",
            require => Package["splunk"];
        "/opt/splunk/etc/system/local/inputs.conf":
            content => template("service_splunk/local/inputs.conf.erb"),
            require => Package["splunk"];
        "/opt/splunk/etc/system/local/props.conf":
            source  => "puppet:///modules/service_splunk/local/props.conf",
            require => Package["splunk"];
        "/opt/splunk/etc/system/local/transforms.conf":
            source  => "puppet:///modules/service_splunk/local/transforms.conf",
            require => Package["splunk"];
    }
    service { "splunkd":
        subscribe   => File[
            "/opt/splunk/etc/system/local/web.conf",
            "/opt/splunk/etc/system/local/inputs.conf",
            "/opt/splunk/etc/system/local/props.conf",
            "/opt/splunk/etc/system/local/transforms.conf"
        ],
        require     => Package["splunk"],
    }
}
