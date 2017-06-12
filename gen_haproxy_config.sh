#!/bin/bash

add_servers_haproxy() {
  if [ $# -ne 3 ]
  then
      echo "Please provide the full path to the haproxy conf file used by the service, the mesos address/ip and port, and the service record full name to be used with mesos DNS"
      echo "e.g. /usr/local/etc/haproxy/haproxy.cfg http://localhost:8123 _rfp-db-rfp._tcp.marathon.mesos"
  else
    FNAME=$1
    MESOS_DNS_IP_PORT=$2
    SERVICE_RECORD=$3

    DNS_CALL_RESPONSE=`curl "${MESOS_DNS_IP_PORT}/v1/services/${SERVICE_RECORD}"`
    echo "Response from Mesos-DNS:"
    echo "${DNS_CALL_RESPONSE}"
    SERVICE_IPS_TMP=`echo ${DNS_CALL_RESPONSE} | sed 's/,/\n/g' | grep "ip\|port" | awk -F':' '{if (index($1,"ip") != 0) { gsub("\"",""); printf "%s:",$2 } else { gsub("\"|}|]| ",""); printf "%s;",$2 } }'`
    #SERVICE_PORTS_TMP=`echo ${DNS_CALL_RESPONSE} | sed 's/,/\n/g' | grep "port" | awk -F':' '{print $2}' | awk -F'"' '{print $2}'`
   
    echo "IP is: ${SERVICE_IPS_TMP}" 
    #echo "DB port is: ${SERVICE_PORTS_TMP}"
    if [ ! -z "${SERVICE_IPS_TMP}" ]; then
      idx=0
      set -f; IFS=';'
      for IP_PORT_VAL in $SERVICE_IPS_TMP; do
        echo "    server rfp-server${idx} ${IP_PORT_VAL} check" >> ${FNAME}
        idx=$((idx+1))
      done
      set +f; unset IFS
    else
      echo "Unable to determine the server address and port for ${SERVICE_RECORD}"
    fi

  fi
}

if [ $# -ne 4 ]
  then
    echo "The application requires five parameters. Please provide the full path to the haproxy template conf file, the full path to the haproxy conf file used by the service, the mesos address/ip and port, and the service record full name to be used with mesos DNS"
    echo "e.g. /haproxy_template.cfg /usr/local/etc/haproxy/haproxy.cfg http://localhost:8123 _rfp-db-rfp._tcp.marathon.mesos" 

else
  cat $1 > $2
#  cat >> $2 <<- EOM
#frontend localnodes
#    bind *:5432
#    mode tcp
#    default_backend rfp-backend
#
#backend rfp-backend
#    balance roundrobin
#    mode tcp
#EOM

  add_servers_haproxy $2 $3 $4
fi

