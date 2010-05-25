# Return the contents of a syslog server's SSL cert.
ssl_cert    = '/etc/ssl/syslog-ng/server.crt'
ssl_hash    = '/etc/ssl/syslog-ng/server.hash'
ssl_key     = '/etc/ssl/syslog-ng/server.key'

Facter.add('syslogsslcert') do
    confine :operatingsystem => :gentoo
    setcode do
        if FileTest.file?(ssl_cert)
            File.readlines(ssl_cert)
        end
    end
end

if Facter.syslogsslcert
    Facter.add('syslogsslhash') do
        confine :operatingsystem => :gentoo
        setcode do
            if FileTest.file?(ssl_hash)
                File.readlines(ssl_hash)[0].chomp
            end
        end
    end
end
