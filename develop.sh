#/bin/bash
Other_files_for_lamp="https://raw.githubusercontent.com/arkylin/Newest_lamp/master"
pkgList="passwd nano java jemalloc jemalloc-devel openssh-server python python-devel python2 python2-devel oniguruma-devel rpcgen go htop libicu icu deltarpm gcc gcc-c++ make cmake autoconf libjpeg libjpeg-devel libjpeg-turbo libjpeg-turbo-devel libpng libpng-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel krb5-devel libc-client libc-client-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio numactl numactl-libs readline-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel libxslt-devel libicu-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre pcre-devel libmcrypt libmcrypt-devel mhash mhash-devel mcrypt zip unzip sqlite-devel sysstat patch bc expect expat-devel oniguruma oniguruma-devel libtirpc-devel nss nss-devel rsync rsyslog git lsof lrzsz psmisc wget which libatomic tmux"
Apache_pkg="jansson jansson-devel diffutils nghttp2 libnghttp2 libnghttp2-devel"
PHP_pkg="curl curl-devel freetype freetype-devel argon2 libargon2 libargon2-devel libsodium libsodium-devel mhash mhash-devel gettext gettext-devel"
pkgList="${pkgList} ${Apache_pkg} ${PHP_pkg}"

for Package in ${pkgList}; do
  dnf -y install ${Package}
  done

dnf -y update bash openssl glibc
sed -i "s@^#Port 22@Port ${ssh_port}@" /etc/ssh/sshd_config
sed -i "s@^#PermitRootLogin.*@PermitRootLogin yes@" /etc/ssh/sshd_config
systemctl enable sshd
if [ ${Password} != "" ]; then
  echo "${Password}" | passwd root --stdin > /dev/null 2>&1
fi

cd /develop
wget ${Other_files_for_lamp}/options.conf

. /develop/options.conf

mkdir -p ${app_dir} ${source_dir} ${data_dir}

# 进入源码目录
cd ${source_dir}

if [ ${apr_install_dir} = "" ]; then
  apr_install_dir=${app_dir}/apr-${apr_version}
fi
if [ ${apache_install_dir} = "" ]; then
  apache_install_dir=${app_dir}/httpd-${Apache_version}
fi
if [ ${libiconv_install_dir} = "" ]; then
  libiconv_install_dir=${app_dir}/libiconv-${PHP_libiconv_version}
fi
if [ ${php_install_dir} = "" ]; then
  php_install_dir=${app_dir}/php-${PHP_main_version}
fi

# 添加用户
useradd -M -s /sbin/nologin ${run_user}

Install_Apr() {
  # 开始安装 Apr
  wget ${Mirror_source}/apache//apr/apr-${apr_version}.tar.gz

  if [ -e "${source_dir}/apr-${apr_version}.tar.gz" ]; then
    echo "Apr-${apr_version} download successfully! "
    echo "Apr-${apr_version} download successfully! "
    echo "Apr-${apr_version} download successfully! "
    tar xzf ${source_dir}/apr-${apr_version}.tar.gz
    cd ${source_dir}/apr-${apr_version}
    rm -rf ${source_dir}/apr-${apr_version}/configure
    wget ${Other_files_for_lamp}/apr-${apr_version}/configure
    chmod +x configure
    mkdir -p ${apr_install_dir}
    ./configure --prefix=${apr_install_dir}
    make -j ${THREAD} && make install
    cd ${source_dir}
    rm -rf ${source_dir}/apr-${apr_version} ${source_dir}/apr-${apr_version}.tar.gz
  else
    echo "Apr-${apr_version} download Failed! "
    echo "Apr-${apr_version} download Failed! "
    echo "Apr-${apr_version} download Failed! "
  fi

  if [ -e "${apr_install_dir}/bin/apr-1-config" ]; then
    echo "Apr-${apr_version} installed successfully! "
    echo "Apr-${apr_version} installed successfully! "
    echo "Apr-${apr_version} installed successfully! "
  else
    rm -rf ${apr_install_dir}
    echo "Apr-${apr_version} installed Failed! "
    echo "Apr-${apr_version} installed Failed! "
    echo "Apr-${apr_version} installed Failed! "
  fi
  # 结束安装 Apr
}

Install_Apr_util() {
  # 开始安装 Apr-util
  wget ${Mirror_source}/apache//apr/apr-util-${apr_util_version}.tar.gz

  if [ -e "${source_dir}/apr-util-${apr_util_version}.tar.gz" ]; then
    echo "Apr-util-${apr_util_version} download successfully! "
    echo "Apr-util-${apr_util_version} download successfully! "
    echo "Apr-util-${apr_util_version} download successfully! "
    tar xzf ${source_dir}/apr-util-${apr_util_version}.tar.gz
    cd ${source_dir}/apr-util-${apr_util_version}
    ./configure --prefix=${apr_install_dir} --with-apr=${apr_install_dir} ${apr_util_additional}
    make -j ${THREAD} && make install
    cd ${source_dir}
    rm -rf ${source_dir}/apr-util-${apr_util_version} ${source_dir}/apr-util-${apr_util_version}.tar.gz
  else
    echo "Apr-util-${apr_util_version} download Failed! "
    echo "Apr-util-${apr_util_version} download Failed! "
    echo "Apr-util-${apr_util_version} download Failed! "
  fi

  if [ -e "${apr_install_dir}/bin/apu-1-config" ]; then
    echo "Apr-util-${apr_util_version} installed successfully! "
    echo "Apr-util-${apr_util_version} installed successfully! "
    echo "Apr-util-${apr_util_version} installed successfully! "
  else
    rm -rf ${apr_install_dir}
    echo "Apr-util-${apr_util_version} installed Failed! "
    echo "Apr-util-${apr_util_version} installed Failed! "
    echo "Apr-util-${apr_util_version} installed Failed! "
  fi
  # 结束安装 Apr-util
}

Install_Apache() {
  # 开始安装 Apache
  wget ${Mirror_source}/apache//httpd/httpd-${Apache_version}.tar.gz

  if [ -e "${source_dir}/httpd-${Apache_version}.tar.gz" ]; then
    echo "Apache-${Apache_version} download successfully! "
    echo "Apache-${Apache_version} download successfully! "
    echo "Apache-${Apache_version} download successfully! "
    tar xzf ${source_dir}/httpd-${Apache_version}.tar.gz
    cd ${source_dir}/httpd-${Apache_version}
    mkdir -p ${apache_install_dir} ${apache_config_dir} ${wwwroot_dir} ${wwwroot_dir}/default ${wwwlogs_dir}
    ./configure --prefix=${apache_install_dir} --enable-mpms-shared=all --with-pcre --with-apr=${apr_install_dir} --with-apr-util=${apr_install_dir} --enable-headers --enable-mime-magic --enable-deflate --enable-proxy --enable-so --enable-dav --enable-rewrite --enable-remoteip --enable-expires --enable-static-support --enable-suexec --enable-mods-shared=most --enable-nonportable-atomics=yes --enable-ssl --with-ssl --enable-http2 --with-nghttp2 ${Apache_additional}
    make -j ${THREAD} && make install
    cd ${source_dir}
    rm -rf ${source_dir}/httpd-${Apache_version} ${source_dir}/httpd-${Apache_version}.tar.gz
    [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=${apache_install_dir}/bin:\$PATH" >> /etc/profile
    [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep ${apache_install_dir} /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${apache_install_dir}/bin:\1@" /etc/profile
    . /etc/profile
    cd ${Startup_dir}
    wget ${Other_files_for_lamp}/init.d/httpd.service
    cd ${source_dir}
    sed -i "s@/usr/local/apache@${apache_install_dir}@g" ${Startup_dir}/httpd.service
    systemctl enable httpd

    # config
    sed -i "s@^User daemon@User ${run_user}@" ${apache_install_dir}/conf/httpd.conf
    sed -i "s@^Group daemon@Group ${run_user}@" ${apache_install_dir}/conf/httpd.conf
    sed -i 's/^#ServerName www.example.com:80/ServerName 127.0.0.1:88/' ${apache_install_dir}/conf/httpd.conf
    sed -i 's@^Listen.*@Listen 127.0.0.1:88@' ${apache_install_dir}/conf/httpd.conf
    TMP_PORT=88
    sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" ${apache_install_dir}/conf/httpd.conf
    sed -i "s@#AddHandler cgi-script .cgi@AddHandler cgi-script .cgi .pl@" ${apache_install_dir}/conf/httpd.conf
    sed -ri 's@^#(LoadModule.*mod_proxy.so)@\1@' ${apache_install_dir}/conf/httpd.conf
    sed -ri 's@^#(LoadModule.*mod_proxy_fcgi.so)@\1@' ${apache_install_dir}/conf/httpd.conf
    sed -ri 's@^#(LoadModule.*mod_suexec.so)@\1@' ${apache_install_dir}/conf/httpd.conf
    sed -ri 's@^#(LoadModule.*mod_vhost_alias.so)@\1@' ${apache_install_dir}/conf/httpd.conf
    sed -ri 's@^#(LoadModule.*mod_rewrite.so)@\1@' ${apache_install_dir}/conf/httpd.conf
    sed -ri 's@^#(LoadModule.*mod_deflate.so)@\1@' ${apache_install_dir}/conf/httpd.conf
    sed -ri 's@^#(LoadModule.*mod_expires.so)@\1@' ${apache_install_dir}/conf/httpd.conf
    sed -ri 's@^#(LoadModule.*mod_ssl.so)@\1@' ${apache_install_dir}/conf/httpd.conf
    sed -ri 's@^#(LoadModule.*mod_http2.so)@\1@' ${apache_install_dir}/conf/httpd.conf
    sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' ${apache_install_dir}/conf/httpd.conf
    sed -i "s@^DocumentRoot.*@DocumentRoot \"${wwwroot_dir}/default\"@" ${apache_install_dir}/conf/httpd.conf
    sed -i "s@^<Directory \"${apache_install_dir}/htdocs\">@<Directory \"${wwwroot_dir}/default\">@" ${apache_install_dir}/conf/httpd.conf
    sed -i "s@^#Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf@" ${apache_install_dir}/conf/httpd.conf

    # logrotate apache log
    cat > /etc/logrotate.d/apache << EOF
${wwwlogs_dir}/*apache.log {
  daily
  rotate 5
  missingok
  dateext
  compress
  notifempty
  sharedscripts
  postrotate
    [ -e /var/run/httpd.pid ] && kill -USR1 \`cat /var/run/httpd.pid\`
  endscript
}
EOF

    mkdir -p ${apache_install_dir}/conf/vhost
    Apache_fcgi=$(echo -e "<Files ~ (\\.user.ini|\\.htaccess|\\.git|\\.svn|\\.project|LICENSE|README.md)\$>\n    Order allow,deny\n    Deny from all\n  </Files>\n  <FilesMatch \\.php\$>\n    SetHandler \"proxy:unix:/dev/shm/php-cgi.sock|fcgi://localhost\"\n  </FilesMatch>")

    cat > ${apache_install_dir}/conf/vhost/0.conf << EOF
<VirtualHost *:$TMP_PORT>
  ServerAdmin admin@example.com
  DocumentRoot "${wwwroot_dir}/default"
  ServerName 127.0.0.1
  ErrorLog "${wwwlogs_dir}/error_apache.log"
  CustomLog "${wwwlogs_dir}/access_apache.log" common
  <Files ~ (\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)\$>
    Order allow,deny
    Deny from all
  </Files>
  ${Apache_fcgi}
<Directory "${wwwroot_dir}/default">
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  Require all granted
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
<Location /server-status>
  SetHandler server-status
  Order Deny,Allow
  Deny from all
  Allow from 127.0.0.1
</Location>
</VirtualHost>
EOF

    cat >> ${apache_install_dir}/conf/httpd.conf <<EOF
<IfModule mod_headers.c>
  AddOutputFilterByType DEFLATE text/html text/plain text/css text/xml text/javascript
  <FilesMatch "\.(js|css|html|htm|png|jpg|swf|pdf|shtml|xml|flv|gif|ico|jpeg)\$">
    RequestHeader edit "If-None-Match" "^(.*)-gzip(.*)\$" "\$1\$2"
    Header edit "ETag" "^(.*)-gzip(.*)\$" "\$1\$2"
  </FilesMatch>
  DeflateCompressionLevel 6
  SetOutputFilter DEFLATE
</IfModule>

ProtocolsHonorOrder On
PidFile /var/run/httpd.pid
ServerTokens ProductOnly
ServerSignature Off
Include ${apache_config_dir}/*.conf
EOF

    cat > ${apache_install_dir}/conf/extra/httpd-remoteip.conf << EOF
LoadModule remoteip_module modules/mod_remoteip.so
RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 127.0.0.1
EOF

    sed -i "s@Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf\nInclude conf/extra/httpd-remoteip.conf@" ${apache_install_dir}/conf/httpd.conf
    sed -i "s@LogFormat \"%h %l@LogFormat \"%h %a %l@g" ${apache_install_dir}/conf/httpd.conf
    ldconfig
  else
      echo "Apache-${Apache_version} download Failed! "
      echo "Apache-${Apache_version} download Failed! "
      echo "Apache-${Apache_version} download Failed! "
  fi

  if [ -e "${apache_install_dir}/bin/httpd" ]; then
    echo "Apache-${Apache_version} installed successfully! "
    echo "Apache-${Apache_version} installed successfully! "
    echo "Apache-${Apache_version} installed successfully! "
  else
    rm -rf ${apache_install_dir}
    echo "Apache-${Apache_version} installed Failed! "
    echo "Apache-${Apache_version} installed Failed! "
    echo "Apache-${Apache_version} installed Failed! "
  fi
  # 结束安装 Apache
}

Install_PHP() {
  # 开始安装 PHP
  wget ${PHP_source}/php-${PHP_main_version}.tar.gz
  wget ${PHP_libiconv}/libiconv-${PHP_libiconv_version}.tar.gz

  if [ -e "${source_dir}/php-${PHP_main_version}.tar.gz" ]; then
    echo "PHP-${PHP_main_version} download successfully! "
    echo "PHP-${PHP_main_version} download successfully! "
    echo "PHP-${PHP_main_version} download successfully! "

    # libiconv
    if [ -e "${source_dir}/libiconv-${PHP_libiconv_version}.tar.gz" ]; then
      echo "libiconv-${PHP_libiconv_version} download successfully! "
      echo "libiconv-${PHP_libiconv_version} download successfully! "
      echo "libiconv-${PHP_libiconv_version} download successfully! "
      tar xzf libiconv-${PHP_libiconv_version}.tar.gz
      cd libiconv-${PHP_libiconv_version}
      mkdir -p ${libiconv_install_dir}
      ./configure --prefix=${libiconv_install_dir}
      make -j ${THREAD} && make install && libtool --finish ${libiconv_install_dir}/lib
      cd ${source_dir}
      rm -rf libiconv-${PHP_libiconv_version}.tar.gz libiconv-${PHP_libiconv_version}
    else
      echo "libiconv-${PHP_libiconv_version} download Failed! "
      echo "libiconv-${PHP_libiconv_version} download Failed! "
      echo "libiconv-${PHP_libiconv_version} download Failed! "
    fi

    if [ -e "${libiconv_install_dir}/lib/libiconv.la" ]; then
      echo "libiconv-${PHP_libiconv_version} installed successfully! "
      echo "libiconv-${PHP_libiconv_version} installed successfully! "
      echo "libiconv-${PHP_libiconv_version} installed successfully! "
    else
      rm -rf ${libiconv_install_dir}
      echo "libiconv-${PHP_libiconv_version} installed Failed! "
      echo "libiconv-${PHP_libiconv_version} installed Failed! "
      echo "libiconv-${PHP_libiconv_version} installed Failed! "
    fi
    
    [ -z "`grep /usr/local/lib /etc/ld.so.conf.d/*.conf`" ] && echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf

    if [ "${OS_BIT}" == '64' ]; then
      [ ! -e "/lib64/libpcre.so.1" ] && ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1
      [ ! -e "/usr/lib/libc-client.so" ] && ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so
    else
      [ ! -e "/lib/libpcre.so.1" ] && ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1
    fi

    ldconfig

    tar xzf ${source_dir}/php-${PHP_main_version}.tar.gz
    cd ${source_dir}/php-${PHP_main_version}
    mkdir -p ${php_install_dir}
    ./configure --prefix=${php_install_dir} --with-config-file-path=${php_install_dir}/etc \
      --with-config-file-scan-dir=${php_install_dir}/etc/php.d \
      --with-fpm-user=${run_user} --with-fpm-group=${run_user} --enable-fpm --disable-fileinfo \
      --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
      --with-iconv-dir=${libiconv_install_dir} --with-freetype --with-jpeg --with-zlib \
      --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
      --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex \
      --enable-mbstring --with-password-argon2 --with-sodium --enable-gd --with-openssl \
      --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --enable-intl --with-xsl \
      --with-gettext --enable-soap --disable-debug ${php_modules_options}
    make -j ${THREAD} && make install
    [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=${php_install_dir}/bin:\$PATH" >> /etc/profile
    [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep ${php_install_dir} /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${php_install_dir}/bin:\1@" /etc/profile
    . /etc/profile
    mkdir -p ${php_install_dir}/etc/php.d
    /bin/cp php.ini-production ${php_install_dir}/etc/php.ini

    sed -i "s@^memory_limit.*@memory_limit = ${PHP_Memory_limit}M@" ${php_install_dir}/etc/php.ini
    sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' ${php_install_dir}/etc/php.ini
    #sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' ${php_install_dir}/etc/php.ini
    sed -i 's@^short_open_tag = Off@short_open_tag = On@' ${php_install_dir}/etc/php.ini
    sed -i 's@^expose_php = On@expose_php = Off@' ${php_install_dir}/etc/php.ini
    sed -i 's@^request_order.*@request_order = "CGP"@' ${php_install_dir}/etc/php.ini
    sed -i "s@^;date.timezone.*@date.timezone = ${timezone}@" ${php_install_dir}/etc/php.ini
    sed -i 's@^post_max_size.*@post_max_size = 100M@' ${php_install_dir}/etc/php.ini
    sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' ${php_install_dir}/etc/php.ini
    sed -i 's@^max_execution_time.*@max_execution_time = 600@' ${php_install_dir}/etc/php.ini
    sed -i 's@^;realpath_cache_size.*@realpath_cache_size = 2M@' ${php_install_dir}/etc/php.ini
    sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' ${php_install_dir}/etc/php.ini
    [ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' ${php_install_dir}/etc/php.ini
    sed -i "s@^;curl.cainfo.*@curl.cainfo = \"${openssl_install_dir}/cert.pem\"@" ${php_install_dir}/etc/php.ini
    sed -i "s@^;openssl.cafile.*@openssl.cafile = \"${openssl_install_dir}/cert.pem\"@" ${php_install_dir}/etc/php.ini
    sed -i "s@^;openssl.capath.*@openssl.capath = \"${openssl_install_dir}/cert.pem\"@" ${php_install_dir}/etc/php.ini

    cat > ${php_install_dir}/etc/php.d/02-opcache.ini << EOF
[opcache]
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=512M
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=100000
opcache.max_wasted_percentage=5
opcache.use_cwd=1
opcache.validate_timestamps=1
opcache.revalidate_freq=60
;opcache.save_comments=0
opcache.consistency_checks=0
;opcache.optimization_level=0
EOF
    cd ${Startup_dir}
    wget ${Other_files_for_lamp}/init.d/php-fpm.service
    cd ${source_dir}
    sed -i "s@/usr/local/php@${php_install_dir}@g" ${Startup_dir}/php-fpm.service
    systemctl enable php-fpm

    cat > ${php_install_dir}/etc/php-fpm.conf <<EOF
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = warning

emergency_restart_threshold = 30
emergency_restart_interval = 60s
process_control_timeout = 5s
daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[${run_user}]
listen = /dev/shm/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = ${run_user}
listen.group = ${run_user}
listen.mode = 0666
user = ${run_user}
group = ${run_user}

pm = dynamic
pm.max_children = 12
pm.start_servers = 8
pm.min_spare_servers = 6
pm.max_spare_servers = 12
pm.max_requests = 2048
pm.process_idle_timeout = 10s
request_terminate_timeout = 120
request_slowlog_timeout = 0

pm.status_path = /php-fpm_status
slowlog = var/log/slow.log
rlimit_files = 51200
rlimit_core = 0

catch_workers_output = yes
;env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF

    if [ $Mem -le 3000 ]; then
      sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/3/20))@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/3/30))@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/3/40))@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/3/20))@" ${php_install_dir}/etc/php-fpm.conf
    elif [ $Mem -gt 3000 -a $Mem -le 4500 ]; then
      sed -i "s@^pm.max_children.*@pm.max_children = 50@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.start_servers.*@pm.start_servers = 30@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 20@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 50@" ${php_install_dir}/etc/php-fpm.conf
    elif [ $Mem -gt 4500 -a $Mem -le 6500 ]; then
      sed -i "s@^pm.max_children.*@pm.max_children = 60@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.start_servers.*@pm.start_servers = 40@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 30@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 60@" ${php_install_dir}/etc/php-fpm.conf
    elif [ $Mem -gt 6500 -a $Mem -le 8500 ]; then
      sed -i "s@^pm.max_children.*@pm.max_children = 70@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.start_servers.*@pm.start_servers = 50@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 70@" ${php_install_dir}/etc/php-fpm.conf
    elif [ $Mem -gt 8500 ]; then
      sed -i "s@^pm.max_children.*@pm.max_children = 80@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.start_servers.*@pm.start_servers = 60@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@" ${php_install_dir}/etc/php-fpm.conf
    fi

    cd ${source_dir}
    rm -rf ${source_dir}/php-${PHP_main_version}.tar.gz

  else
    echo "PHP-${PHP_main_version} download Failed! "
    echo "PHP-${PHP_main_version} download Failed! "
    echo "PHP-${PHP_main_version} download Failed! "
  fi

  if [ -e "${php_install_dir}/bin/phpize" ]; then
    echo "PHP-${PHP_main_version} installed successfully! "
    echo "PHP-${PHP_main_version} installed successfully! "
    echo "PHP-${PHP_main_version} installed successfully! "
  else
    rm -rf ${php_install_dir}
    echo "PHP-${PHP_main_version} installed Failed! "
    echo "PHP-${PHP_main_version} installed Failed! "
    echo "PHP-${PHP_main_version} installed Failed! "
  fi
  # 结束安装 PHP
}

Install_Mysql() {
  # 开始安装 Mysql
  dnf -y install mysql-server mysql-devel
  systemctl enable mariadb
  # 结束安装 Mysql
}

if [ "${Mysql_install}" == 'true' ]; then
  Install_Apr && Install_Apr_util && Install_Apache && Install_PHP && Install_Mysql
else
  Install_Apr && Install_Apr_util && Install_Apache && Install_PHP
fi