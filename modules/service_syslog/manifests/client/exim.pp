class service_syslog::client::exim inherits service_syslog::client {
    file { "/etc/syslog-ng/extra.d/10.exim":
        source  => "puppet:///modules/service_syslog/extra.d-client/10.exim",
        notify  => Exec["syslog-ng-reload"],
        require => Class["service_exim::base"],
    }
}
