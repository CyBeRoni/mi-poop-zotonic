#!/bin/sh

test -d /srv/ssl || mkdir /srv/ssl

enable_ssl=$(mdata-get haproxy:enable_ssl || echo "true")

if [ "x$enable_ssl" = "xtrue" ]; then
	/usr/sbin/svccfg -s svc:/pkgsrc/haproxy setprop application/config_file = /opt/local/etc/haproxy_https.cfg
	
	# Generate an SSL cert for the hostname so haproxy will start
	domain=$(mdata-get sdc:hostname).$(mdata-get sdc:dns_domain)
	subj="/commonName=$domain"
	
	if [ ! -f /srv/ssl/haproxy.pem ]; then
		pushd /tmp
		openssl genrsa -out key 2048
		openssl req -new -subj "$subj" -key key -out req
		openssl x509 -req -days 730 -in req -signkey key -out cert
		cat key cert > /srv/ssl/haproxy.pem
		popd
	fi

else
	/usr/sbin/svccfg -s svc:/pkgsrc/haproxy setprop application/config_file = /opt/local/etc/haproxy_http.cfg
fi

mkdir -p /var/lib/haproxy/dev

/usr/sbin/svcadm refresh svc:/pkgsrc/haproxy
/usr/sbin/svcadm enable svc:/pkgsrc/haproxy:default

# Log rotation for haproxy
logadm -C 10 -p 1d -a 'kill -HUP `cat /var/run/*syslog*.pid`' -w haproxy /var/log/haproxy/*.log
