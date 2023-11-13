#!/bin/bash

case "${PHP_VERS}" in 
	'7.4')
	xDebPkgName=xdebug-2.9.8
	composerInstall () {
		wget https://getcomposer.org/composer-1.phar -O /usr/local/bin/composer %% chmod 755 /usr/local/bin/composer
	}
	;;
	'8.0')
	xDebPkgName=xdebug-3.1.5
	composerIntstall () {
		curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
	}
	;;
	*) 
	echo 'Unexpected PHP version';
	exit 1
esac

dnf -y install 'dnf-command(download)'

dnf download --repofrompath=centos,http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os --disablerepo=*  \
        --enablerepo=centos centos-stream-release centos-stream-repos centos-gpg-keys

rpm -ivh --nodeps --replacefiles *.rpm && \ 
        rm *.rpm && \ 
        rmp -e redhat-release && \ 
        dnf --setopt=tsflags=nodocs --setopt=install_weak_deps=false -y distro-sync && \ 
        dnf remove -y subscription-manager dnf-plugin-subscription-manager && \ 
        dnf clean all && \ 
        rm -f /etc/yum.repos.d/ubi.repo


dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm

dnf module enable php:remi-${PHP_VERS} -y

dnf install -y nano
dnf install -y wget
dnf install -y mc
dnf install -y httpd
dnf install -y nginx
dnf install -y supervisor
dnf install -y iproute 
dnf install -y gcc 
dnf install -y make 
dnf install -y glibc-langpack-en 
dnf install -y git 
dnf install -y passwd
dnf install -y openssh-server 
dnf install -y telnet 
dnf install -y exim.x86_64 
dnf install -y mailx 
dnf install -y bzip2 
dnf install -y unzip 
dnf install -y procps 
dnf install -y patch 
dnf install -y glibc-gconv-extra


dnf install -y php php-dom php-simplexml php-ssh2 php-xml php-xmlreader php-curl php-date php-exif php-filter php-ftp php-gd php-hash
dnf install -y php-iconv php-json php-libxml php-pecl-imagick php-mbstring php-mysqlnd php-openssl php-pcre php-posix php-sockets php-spl
dnf install -y php-tokenizer php-zlib php-pear php-pdo php-session php-ldap php-xhprof php-ast php-cli php-dba php-dbg php-ffi php-fpm php-gmp
dnf install -y php-lz4 php-geos php-imap php-intl php-odbc php-pggi php-snmp php-soap php-tidy php-zstd php-devel php-pdlib php-pgsql php-pinba
dnf install -y php-bcmath php-brotli php-common php-pspell php-snappy php-sodium php-xmlrpc php-enchant php-libvirt php-opcache php-pecl-apcu-bc
dnf install -y php-pecl-memcache php-pecl-redis5 php-pecl-zip php-smbclient php-pecl-gearman

wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo && dnf -y install yarn npm

dnf -y autoremove && dnf clean metadata && dnf clean all

xDebDir=/opt/xdebug
mkdir -p "${xDebDir}"
wget -P "${xDebDir}" "https://pecl.php.net/get/${xDebPkgName}.tgz" --no-check-certificate && tar -xvf "${xDebDir}/${xDebPkgName}.tgz" -C "${xDebDir}"
cd "${xDebDir}/${xDebPkgName}" && /usr/bin/phpize && ./configure --enable-xdebug 
cd "${xDebDir}/${xDebPkgName}" && make && make install
rm -rf "${xDebDir}"

wget https://getcomposer.org/composer-1.phar -O /usr/local/bin/composer && chmod 755 /usr/local/bin/composer

ln -s ${PROJECTS_ROOT_DIR}/conf/.composer /root/.composer
ln -s ${PROJECTS_ROOT_DIR}/history /root/.bash_history

git config --global user.email "evrinoma@gmail.com" && git config --global user.name "Nikolay Nikolaev"

ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa && echo 1234 | passwd --stdin root

mkdir -p /run/supervisor
mkdir -p "${PROJECTS_ROOT_DIR}"
#mkdir -p /opt/WWW/container.ite-ng.ru

sed -i -e "s@^files\ =\ supervisord\.d\/\*\.ini@files\ =\ supervisord\.d\/\*\.conf@" /etc/supervisord.conf 
sed -i -e "s@^\[unix_http_server\]@;\[unix_http_server\]@" /etc/supervisord.conf
sed -i -e "s@^file\=\/run\/supervisor\/supervisor.sock@;&@" /etc/supervisord.conf
sed -i -e "s@^;\[inet_http_server\]@\[inet_http_server\]@" /etc/supervisord.conf
sed -i -e "s@^;port=127\.0\.0\.1\:9001@port=127\.0\.0\.1\:9001@" /etc/supervisord.conf
sed -i -e "s@^serverurl=unix\:@;&@" /etc/supervisord.conf
sed -i -e "s@^;serverurl=http:@serverurl=http:@" /etc/supervisord.conf

sed -i -e "s/^\(short_open_tag =\).*$/\1 On/g" /etc/php.ini
sed -i -e "s/\;date\.timezone\ \=/date\.timezone\ \=\ \"Europe\/Moscow\"/g" /etc/php.ini
sed -i -e "s/\;max_input_vars\ \=/max_input_vars\ \=\ 16000 \n\;/g" /etc/php.ini
sed -i -e "s/memory_limit\ \=\ 128M/memory_limit\ \=\ -1/g" /etc/php.ini
sed -i -e "s/max_input_time\ \=\ 60/max_input_time\ \=\ -1/g" /etc/php.ini
sed -i -e "s/max_execution_time\ \=\ 30/max_execution_time\ \=\ 10000/g" /etc/php.ini
sed -i -e "s/post_max_size \=\ 8/post_max_size\ \=\ 8192/g" /etc/php.ini
sed -i -e "s/upload_max_filesize \=\ 2/upload_max_filesize\ \=\ 4096/g" /etc/php.ini
sed -i -e "s/session.gc_maxlifetime\ \=\ 1440/session.gc_maxlifetime\ \=\ 36000/g" /etc/php.ini
sed -i -e "s/expose_php\ \=\ On/expose_php\ \=\ off/" /etc/php.ini

sed -i -e "s/DirectoryIndex \(.\+\)/DirectoryIndex index.php \1/g" /etc/httpd/conf/httpd.conf
sed -i -e "s/IncludeOptional\ conf\.d\/\*\.conf//" /etc/httpd/conf/httpd.conf
echo 'TraceEnable Off' >> /etc/httpd/conf/httpd.conf
echo 'ServerTokens Prod' >> /etc/httpd/conf/httpd.conf
echo 'ServerSignature Off' >> /etc/httpd/conf/httpd.conf
echo 'Header always append X-Frame-Options ite-ng.ru' >> /etc/httpd/conf/httpd.conf
echo 'Header set X-XSS-Protection "1; mode=block"' >> /etc/httpd/conf/httpd.conf
echo 'Header set X-Content-Type-Options nosniff' >> /etc/httpd/conf/httpd.conf
echo 'IncludeOptional conf.d/*.conf' >> /etc/httpd/conf/httpd.conf
echo 'TimeOut 600' >> /etc/httpd/conf/httpd.conf

touch /etc/php.d/xdebug.ini
echo "zend_extension=xdebug.so" >> /etc/php.d/xdebug.ini
echo "xdebug.remote_host = 172.18.74.74" >> /etc/php.d/xdebug.ini
echo "xdebug.remote_enable = 1" >> /etc/php.d/xdebug.ini
echo "xdebug.remote_connect_back=1" >> /etc/php.d/xdebug.ini
echo "xdebug.remote_port = 9000" >> /etc/php.d/xdebug.ini
echo "xdebug.extended_info = 1" >> /etc/php.d/xdebug.ini
echo "xdebug.var_display_max_depth = 16" >> /etc/php.d/xdebug.ini
echo "xdebug.var_display_max_children = 256" >> /etc/php.d/xdebug.ini
echo "xdebug.max_nesting_level = 1024" >> /etc/php.d/xdebug.ini
echo "xdebug.idekey="PHPSTORM"" >> /etc/php.d/xdebug.ini

sed -i -e "s/Options\ Indexes\ MultiViews\ FollowSymlinks/#&/" /etc/httpd/conf.d/autoindex.conf
sed -i -e "s/AllowOverride None/AllowOverride All/" /etc/httpd/conf.d/autoindex.conf
sed -i -e "s/Require\ all\ granted/#&\n/" /etc/httpd/conf.d/autoindex.conf
sed -i -e "s/#Require\ all\ granted/&\nOrder\ deny,allow\nAllow\ from\ 172\.20\.1\.0\/24\ 172\.18\.0\.0\/16\ 127\.0\.0\.1/" /etc/httpd/conf.d/autoindex.conf

mv -v /etc/exim/exim.conf{,.bak}
mv -v /usr/sbin/sendmail{,.bak}
cp /usr/sbin/exim /usr/sbin/sendmail
chmod 4755 /usr/sbin/sendmail
mv /bin/mail{,.bak}
ln -s /bin/mailx /bin/mail

rm -f /var/run/httpd/httpd.pid

mkdir -p /run/php-fpm
touch /run/php-fpm/www.sock

mv /tmp/exim.conf /etc/exim/

npm install -g webpack webpack-cli
dnf install -y gearmand

curl https://packages.microsoft.com/config/rhel/8/prod.repo > /etc/yum.repos.d/mssql-release.repo &&  ACCEPT_EULA=Y yum install msodbcsql18 -y &&  ACCEPT_EULA=Y yum install mssql-tools18 -y

dnf install -y unixODBC-devel php-sqlsrv

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile &&  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc &&  source ~/.bashrc

mv /etc/pki/tls/openssl.cnf{,.bak}
echo "openssl_conf = default_conf" >> /etc/pki/tls/openssl.cnf
echo "[default_conf]" >> /etc/pki/tls/openssl.cnf
echo "ssl_conf = ssl_sect" >> /etc/pki/tls/openssl.cnf
echo "" >> /etc/pki/tls/openssl.cnf
echo "[ssl_sect]" >> /etc/pki/tls/openssl.cnf
echo "system_default = system_default_sect" >> /etc/pki/tls/openssl.cnf
echo "" >> /etc/pki/tls/openssl.cnf
echo "[system_default_sect]" >> /etc/pki/tls/openssl.cnf
echo "CipherString = DEFAULT@SECLEVEL=1" >> /etc/pki/tls/openssl.cnf

setcap 'cap_net_bind_service=+ep' /usr/sbin/httpd &&  chown -R apache.apache /var/log/httpd/

mv /tmp/supervisor.conf /etc/supervisord.d/

chmod 700 /usr/local/bin/init.container

dnf install cronie -y &&  sed -i -e '/pam_loginuid.so/s/^/#/' /etc/pam.d/crond

rm -rf /var/cache/dnf
dnf remove -y nodejs
dnf clean all
curl --silent --location https://rpm.nodesource.com/setup_16.x | bash -  &&  dnf install -y nodejs yarn

chmod +x /usr/local/bin/auto.deploy
chmod +x /usr/local/bin/reconfig
chmod +x /usr/local/bin/restart
chmod +x /usr/local/bin/restart.nginx
chmod +x /usr/local/bin/restart.httpd
chmod +x /usr/local/bin/restart.phpd

touch /etc/nginx/conf.d/vhost.conf
touch /etc/httpd/conf.d/vhost.conf

rm /usr/bin/container_configure.sh


