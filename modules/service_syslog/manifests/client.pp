import "defines/client/*"

class service_syslog::client inherits service_syslog::base {
    $syslog_server  = extlookup("service_syslog_server", "lg.${domain}")
    $syslog_port    = extlookup("service_syslog_port", "5140")

    # TODO: We might want to revert this once all machines are at >3.0.5
    #       due to program_override() bug.
    gentoo_keywords { "syslog-ng":
        ensure  => present,
        package => "<app-admin/syslog-ng-3.1",
    }
    Package["syslog-ng"] {
        require => Gentoo_keywords["syslog-ng"],
    }
    File["/etc/syslog-ng/syslog-ng.conf"] {
        source  => "puppet:///modules/service_syslog/syslog-ng.conf",
    }
    Service["syslog-ng"] {
        require +> File["/etc/ssl/syslog-ng/ca.crt"],
    }
    file {
        "/etc/ssl/syslog-ng":
            ensure  => directory,
            recurse => true,
            purge   => true,
            force   => true;
        "/etc/syslog-ng/extra.d":
            ensure  => directory,
            recurse => true,
            purge   => true,
            force   => true,
            require => File["/etc/syslog-ng/syslog-ng.conf"];
        "/etc/syslog-ng/extra.d/00.global":
            content => template("service_syslog/extra.d-client/00.global.erb"),
            notify  => Exec["syslog-ng-reload"];
    }
    # Realise the server's CA and hash files.
    File <<| tag == 'service_syslog::server' |>>
}
