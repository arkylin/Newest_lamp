FROM fedora:rawhide

LABEL maintainer="Kylin --www.xyz.blue"

ADD develop.sh /develop.sh
RUN mkdir -p /develop && mv /develop.sh /develop && chmod 777 /develop/develop.sh && /develop/develop.sh

CMD ["/usr/sbin/init"]