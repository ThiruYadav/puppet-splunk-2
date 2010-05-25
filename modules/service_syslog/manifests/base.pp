class service_syslog::base {
    package { "syslog-ng":
        ensure      => latest,
        category    => "app-admin",
    }
    file { "/etc/syslog-ng/syslog-ng.conf":
        source      => "puppet:///modules/service_syslog/syslog-ng.conf.dist",
        require     => Package["syslog-ng"],
    }
    service { "syslog-ng":
        subscribe   => Package["syslog-ng"],
    }
    exec { "syslog-ng-reload":
        command     => "/etc/init.d/syslog-ng reload > /dev/null",
        refreshonly => true,
        subscribe   => File["/etc/syslog-ng/syslog-ng.conf"],
        require     => Service["syslog-ng"],
    }
}
