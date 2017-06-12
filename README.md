# rfp-lb
Routes for People deployment dockerized load balancer using HAProxy

This image is based on haproxy. It contains a script which uses Mesos-DNS to discover a service by a name set using an environment variable in the dockerfile. The  gen_haproxy_config.sh is executed inside the container and using the haproxy_template.cfg, generates a custom condiguration. It retrieves all instances with a certain service name. Then, the script extracts the IP/port and adds it to the haproxy conf file.

The following ENV variables can be set:


MESOS_DNS_IP_PORT - the ip/address and port of the Mesos-DNS server

MESOS_DNS_SERVICES - the name of the Marathon/Mesos service that will be queried on Mesos-DNS
