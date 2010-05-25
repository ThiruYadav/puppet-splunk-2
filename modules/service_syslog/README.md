# Usage.

## Default standalone node.

    include service_syslog

## Centralised syslog server.

    include service_syslog::server

### Vars

 - service\_syslog\_server
  - Public facing hostname that the server will be presented on.
  - Default: `lg.$domain`
 - service\_syslog\_port
  - Port that the server will listen on.
  - Default: `5140`

### Deps

 - app_logrotate
  - Archive logs received from clients to ensure they don't grow too large.

## Clustered syslog node.

    include service_syslog::client

### Vars

 - service\_syslog\_server
  - Server hostname to connect to.
  - Default: `lg.$domain`
 - service\_syslog\_port
  - Server port to connect to.
  - Default: `5140`

### Exim

    include service_syslog::client::exim

### Apache

    service_syslog::client::apache_vhost { "frontend.site0.example.com":
        access_log  => "/usr/local/apache_logs/frontend.site0.example.com-access_log",
        error_log   => "/usr/local/apache_logs/frontend.site0.example.com-error_log",
    }

# Quirks.

 - `program_override()` is broken in syslog-ng 3.0.4
