# Usage.

## Splunk server.

Served through nginx with SSL client auth.

    include service_splunk

### Vars

 - service\_splunk\_ssl\_depth
  - Default: 2
  - Permitted depth from CA.
 - service\_splunk\_ssl\_ca
  - CA to restrict requests. Filename without extension.
 - service\_splunk\_ssl\_var
  - Default: emailAddress
  - Which OID to compare from the client's certificate.
 - service\_splunk\_ssl\_users
  - Permitted OID values.

### Deps

 - app\_layman
  - The Splunk package isn't available in the general Portage repos. We source it from an internal repos.
 - os\_gentoo::optpath
  - Splunk likes to install into `/opt`. We want this relocated onto a different partition.
 - service\_nginx
  - Splunk's free license doesn't support authentication. We frontend it with SSL client auth.
