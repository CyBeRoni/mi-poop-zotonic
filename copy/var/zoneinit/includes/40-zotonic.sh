#!/bin/sh

z_passwd=$(mdata-get zotonic:password || openssl rand -base64 12)
z_timezone=$(mdata-get zotonic:timezone || mdata-get system:timezone || echo "UTC")

mkdir /var/log/zotonic
chown zotonic:zotonic /var/log/zotonic

cat <<EOF > /opt/local/etc/zotonic/zotonic.config
[{zotonic,
  [
	{user_sites_dir, "/srv/zotonic/sites"},
	{user_modules_dir, "/srv/zotonic/modules"},
	{timezone, "${z_timezone}"},
	{dbcreate, false},
	{dbinstall, false},
	{listen_ip, "127.0.0.1"},
	{listen_port, 8000},
	{password, "${z_passwd}"},
	{template_modified_check, false},
	{filewatcher_enabled, false}, % No fswatch or inotify
	{filewatcher_scanner_enabled, false}
  ]
 }
].
EOF

svccfg -s svc:/pkgsrc/epmd setenv ERL_EPMD_ADDRESS 127.0.0.1
svcadm refresh svc:/pkgsrc/epmd
svcadm enable svc:/pkgsrc/epmd

svccfg import /opt/local/lib/svc/manifest/zotonic.xml
svcadm enable svc:/application/zotonic:default
