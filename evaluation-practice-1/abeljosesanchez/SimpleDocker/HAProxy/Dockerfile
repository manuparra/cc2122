FROM haproxy
ADD haproxy.cfg /usr/local/etc/haproxy
USER root
RUN chown haproxy:haproxy /var/run
USER haproxy:haproxy
