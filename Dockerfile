FROM centos:8
ARG PROJECTS_ROOT_DIR=/opt/WWW/container.ite-ng.ru
ARG PHP_VERS=7.4

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN dnf update -y

ONBUILD ARG MODE=''
COPY ./files/container_configure.sh /usr/bin/container_configure.sh
COPY ./files/test_configure.sh	    /usr/bin/test_configure.sh
COPY ./files/supervisor.conf 	    /tmp/supervisor.conf
COPY ./files/exim.conf 		    /tmp/exim.conf
COPY ./files/init.container 	    /usr/local/bin/init.container
COPY ./files/reconfig 		    /usr/local/bin/reconfig
COPY ./files/restart 		    /usr/local/bin/restart
COPY ./files/restart.nginx 	    /usr/local/bin/restart.nginx
COPY ./files/restart.httpd 	    /usr/local/bin/restart.httpd
COPY ./files/restart.phpd 	    /usr/local/bin/restart.phpd
COPY ./files/auto.deploy 	    /usr/local/bin/auto.deploy
WORKDIR /usr/bin
RUN chmod u+x container_configure.sh && ./container_configure.sh
COPY ./files/install/		    /root/install/

RUN chmod u+x test_configure.sh
ARG UPDATE=
RUN if [ ! -z "${UPDATE}" ]; then secure=$(curl -L https://raw.githubusercontent.com/evrinoma/configuration/main/serialized) && echo $secure > /etc/sysconfig/secure ; fi





#RUN yum install -y nginx
#RUN rm -y /usr/bin/container_configure.sh
EXPOSE 22 80
WORKDIR ${PROJECTS_ROOT_DIR}
#CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["/usr/bin/supervisord"]
