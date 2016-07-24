mi-poop-zotonic
===============

Please refer to https://github.com/joyent/mibe for use of this repo.

Use with base-64 image from Joyent; tested with 15.3.0.

When built, this image provides a Zotonic service. HAProxy is used to listen on port 80 (and 443 for SSL).

At least 1024MB of memory is recommended, more for larger websites. 

This image requires a delegated dataset to store persistent data (PostgreSQL and Zotonic user sites/modules).

Metadata
---------
The following customer_metadata is used:

* system:ssh_disabled - Whether or not to disable the ssh daemon (default: false)
* system:timezone - What timezone to use (no default)
* haproxy:enable_ssl - Whether or not to enable HTTPS (default: true)
* zotonic:password - The global admin password for Zotonix (default: automatically generated)
* zotonic:timezone - The timezone set in Zotonic (default: system:timezone, UTC if not set)

Services
--------
When running, the following services are exposed to the network on both IPv4 and IPv6:

* 80, 443: Zotonic through HAProxy (80 redirects to 443 if ssl is enabled)
* 22: SSH (if not disabled)

Data
----

Persistent data is stored in /srv which is a delegated dataset. It has the following subdirectories:

* zotonic/sites: zotonic site directories (user_sites_dir)
* zotonic/modules: zotonic module directories (user_modules_dir)
* ssl: certificates for HAProxy
* postgresql/data: data directory for PostgreSQL.

If SSL is enabled, a certificate for the zone host name is generated and stored in /srv/ssl/haproxy.pem if that file
does not yet exist. To add your own cert, either drop another .pem file (containing key + certs) in that directory or
replace the haproxy.pem file with your own (if the hostname would be identical) and restart haproxy.

Example JSON
------------

    {
      "brand": "joyent",
      "image_uuid": "",
      "alias": "zotonic",
      "hostname": "zotonic",
      "max_physical_memory": 1024,
      "cpu_shares": 100,
      "quota": 10,
      "delegate_dataset": "true",
      "nics": [
	{
	  "nic_tag": "admin",
	  "ips": ["1.2.3.4/24", "2001::1/64"],
	  "gateways": ["1.2.3.1"],
	  "primary": "true"
	}
      ],
      "resolvers": [
	"8.8.8.8",
	"8.8.4.4"
      ],
      "customer_metadata": {
	"system:ssh_disabled": "true",
	"system:timezone": "Europe/Amsterdam",
	"haproxy:enable_ssl": "true"
      }
    }
