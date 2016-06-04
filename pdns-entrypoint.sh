#!/bin/bash

#Check if this entrypoint has been run before. 
if [ ! -f /backendconf.done ]; then
	#Create the Database on Linked Container
	mysql -h ${MYSQL_PORT_3306_TCP_ADDR} -P ${MYSQL_PORT_3306_TCP_PORT} -uroot -p${MYSQL_ENV_MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${PDNS_DATABASE}"

	#Grant Remote Permissions
	mysql -h ${MYSQL_PORT_3306_TCP_ADDR} -P ${MYSQL_PORT_3306_TCP_PORT} -uroot -p${MYSQL_ENV_MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${PDNS_DATABASE}.* To '${PDNS_USER}'@'localhost' IDENTIFIED BY '${PDNS_PASSWORD}'"
	mysql -h ${MYSQL_PORT_3306_TCP_ADDR} -P ${MYSQL_PORT_3306_TCP_PORT} -uroot -p${MYSQL_ENV_MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${PDNS_DATABASE}.* To '${PDNS_USER}'@'%' IDENTIFIED BY '${PDNS_PASSWORD}'"
	
	#Set Up Table Structure
	mysql -h ${MYSQL_PORT_3306_TCP_ADDR} -P ${MYSQL_PORT_3306_TCP_PORT} -u${PDNS_USER} -p${PDNS_PASSWORD} ${PDNS_DATABASE} < /tmp/pdns-init.sql

	#Replace Config Values
	sed -i "s/(mysql.host)/${MYSQL_PORT_3306_TCP_ADDR}/g" /etc/powerdns/pdns.d/pdns.mysql.conf
	sed -i "s/(mysql.port)/${MYSQL_PORT_3306_TCP_PORT}/g" /etc/powerdns/pdns.d/pdns.mysql.conf
	sed -i "s/(db.name)/${PDNS_DATABASE}/g" /etc/powerdns/pdns.d/pdns.mysql.conf
	sed -i "s/(mysql.user)/${PDNS_USER}/g" /etc/powerdns/pdns.d/pdns.mysql.conf
	sed -i "s/(mysql.password)/${PDNS_PASSWORD}/g" /etc/powerdns/pdns.d/pdns.mysql.conf

	touch /backendconf.done
fi

exec /usr/sbin/pdns_server --daemon=no --launch=gmysql "$@"
