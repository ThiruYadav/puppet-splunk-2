class service_syslog::server inherits service_syslog::base {
    $syslog_server      = extlookup("service_syslog_server", "lg.${domain}")
    $syslog_port        = extlookup("service_syslog_port", "5140")
    $syslog_ssl_dn      = "/C=GB/O=Self Signed/OU=Syslog Server/CN=$syslog_server"
    $syslog_ssl_cert    = "/etc/ssl/syslog-ng/server.crt"
    $syslog_ssl_hash    = "/etc/ssl/syslog-ng/server.hash"
    $syslog_ssl_key     = "/etc/ssl/syslog-ng/server.key"

    include app_logrotate

    # TODO: We might want to revert this once all machines are at >3.0.5
    #       due to program_override() bug.
    gentoo_keywords { "syslog-ng":
        package => "<app-admin/syslog-ng-3.1",
    }
    Package["syslog-ng"] {
        require => Gentoo_keywords["syslog-ng"],
    }
    File["/etc/syslog-ng/syslog-ng.conf"] {
        source  => "puppet:///modules/service_syslog/syslog-ng.conf",
    }
    file {
        "/etc/ssl/syslog-ng":
            ensure  => directory,
            recurse => true,
            purge   => true,
            force   => true;
        "/etc/ssl/syslog-ng/server.key":
            ensure  => undef,
            mode    => 600;
        "/etc/ssl/syslog-ng/server.crt":
            ensure  => undef;
        "/etc/ssl/syslog-ng/server.hash":
            ensure  => undef;
        "/usr/local/syslog":
            ensure  => directory,
            mode    => 700;
        "/etc/logrotate.d/syslog-ng-server":
            source  => "puppet:///modules/service_syslog/logrotate.d/syslog-ng-server",
            require => [
                File["/usr/local/syslog"],
                Class["app_logrotate"]
            ];
    }
    file {
        "/etc/syslog-ng/extra.d":
            ensure  => directory,
            recurse => true,
            purge   => true,
            force   => true,
            require => File["/etc/syslog-ng/syslog-ng.conf"];
        "/etc/syslog-ng/extra.d/00.global":
            content => template("service_syslog/extra.d-server/00.global.erb"),
            notify  => Exec["syslog-ng-reload"];
        "/etc/syslog-ng/extra.d/10.exim":
            source  => "puppet:///modules/service_syslog/extra.d-server/10.exim",
            notify  => Exec["syslog-ng-reload"];
        "/etc/syslog-ng/extra.d/10.apache":
            source  => "puppet:///modules/service_syslog/extra.d-server/10.apache",
            notify  => Exec["syslog-ng-reload"];
    }
    if ! ( $syslogsslcert or $syslogsslhash ) {
        exec {
            "syslog-ng_generate_ssl_cert":
                command => "/usr/bin/openssl req -new -x509 -newkey rsa:2048 -nodes -keyout \"$syslog_ssl_key\" -out \"$syslog_ssl_cert\" -days 7300 -subj \"$syslog_ssl_dn\"",
                notify  => Service["syslog-ng"];
            "syslog-ng_generate_ssl_hash":
                command => "/usr/bin/openssl x509 -noout -hash -in \"$syslog_ssl_cert\" > \"$syslog_ssl_hash\"",
                notify  => Service["syslog-ng"],
                require => Exec["syslog-ng_generate_ssl_cert"];
        }
    } else {
        @@file {
            "/etc/ssl/syslog-ng/ca.crt":
                content => "$syslogsslcert",
                notify  => Service["syslog-ng"];
            "/etc/ssl/syslog-ng/${syslogsslhash}.0":
                ensure  => "ca.crt",
                notify  => Service["syslog-ng"];
        }
    }
}
