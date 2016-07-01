FROM ubuntu:16.04
MAINTAINER Mandus Momberg <mandus@momberg.me>

ENV PDNS_DATABASE="pdns_backend" PDNS_USER="pdns_admin" PDNS_PASSWORD="pdns_admin_password"

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y pdns-server pdns-backend-mysql
RUN rm /etc/powerdns/pdns.d/*

ADD pdns-init.sql /tmp/
ADD pdns.d/* /etc/powerdns/pdns.d/

ADD pdns-entrypoint.sh /
ENTRYPOINT ["/pdns-entrypoint.sh"]

EXPOSE 53
EXPOSE 53/udp
