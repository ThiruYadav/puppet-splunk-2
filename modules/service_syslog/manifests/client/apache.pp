class service_syslog::client::apache inherits service_syslog::client {
    file { "/etc/syslog-ng/extra.d/10.apache":
        source  => "puppet:///modules/service_syslog/extra.d-client/10.apache",
        notify  => Exec["syslog-ng-reload"],
    }
}
