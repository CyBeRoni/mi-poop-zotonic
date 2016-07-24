#!/bin/bash

# Change the data dir
svccfg -s svc:/pkgsrc/postgresql setprop config/data = /srv/postgresql/data
svcadm refresh svc:/pkgsrc/postgresql:default

# Create the data dir
if [ ! -d /srv/postgresql/data ]; then 
	mkdir -p /srv/postgresql/data
	mkdir /srv/postgresql/log
	chown -R postgres /srv/postgresql

	# Init the datadir
	sudo -u postgres initdb /srv/postgresql/data
fi

# Start the thing
svcadm enable svc:/pkgsrc/postgresql:default
