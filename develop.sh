#/bin/bash
Other_files_for_lamp="https://raw.githubusercontent.com/arkylin/other_files_for_lamp/master"
pkgList="diffutils nghttp2 libnghttp2 libnghttp2-devel java jemalloc jemalloc-devel openssh-server python python-devel python2 python2-devel oniguruma-devel rpcgen go htop libicu icu deltarpm gcc gcc-c++ make cmake autoconf libjpeg libjpeg-devel libjpeg-turbo libjpeg-turbo-devel libpng libpng-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel krb5-devel libc-client libc-client-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio numactl numactl-libs readline-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel libxslt-devel libicu-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre pcre-devel libmcrypt libmcrypt-devel mhash mhash-devel mcrypt zip unzip sqlite-devel sysstat patch bc expect expat-devel oniguruma oniguruma-devel libtirpc-devel nss nss-devel rsync rsyslog git lsof lrzsz psmisc wget which libatomic tmux"
for Package in ${pkgList}; do
    dnf -y install ${Package}
    done
dnf -y update bash openssl glibc
sed -i "s@^#Port 22@Port ${ssh_port}@" /etc/ssh/sshd_config
sed -i "s@^#PermitRootLogin.*@PermitRootLogin yes@" /etc/ssh/sshd_config
systemctl enable sshd

cd /develop
wget ${Other_files_for_lamp}/options.conf

. /develop/options.conf

mkdir -p ${app_dir} ${source_dir} ${data_dir} ${apache_install_dir} ${apache_config_dir} ${php74_install_dir}

#进入源码目录
cd ${source_dir}

#安装 apr
wget ${Mirror_source}/apache//apr/apr-${apr_version}.tar.gz
if [ -e "${source_dir}/apr-${apr_version}.tar.gz" ]; then
    echo "Apr download successfully! "
    tar xzf ${source_dir}/apr-${apr_version}.tar.gz
    cd ${source_dir}/apr-${apr_version}
    rm -rf ${source_dir}/apr-${apr_version}/configure
    wget ${Other_files_for_lamp}/apr-${apr_version}/configure
    chmod +x configure
    ./configure --prefix=${apr_install_dir}
    make -j ${THREAD} && make install
    cd ${source_dir}
    rm -rf ${source_dir}/apr-${apr_version} ${source_dir}/apr-${apr_version}.tar.gz
  else
    echo "Apr download Failed! "
  fi
if [ -e "${apr_install_dir}/bin/apr-1-config" ]; then
    echo "Apr installed successfully! "
    echo "Apr installed successfully! "
    echo "Apr installed successfully! "
  else
    echo "Apr installed Failed! "
    echo "Apr installed Failed! "
    echo "Apr installed Failed! "
  fi
#结束安装 apr

#安装 apr-util
wget ${Mirror_source}/apache//apr/apr-util-${apr_util_version}.tar.gz
if [ -e "${source_dir}/apr-util-${apr_util_version}.tar.gz" ]; then
    echo "Apr download successfully! "
    tar xzf ${source_dir}/apr-util-${apr_util_version}.tar.gz
    cd ${source_dir}/apr-util-${apr_util_version}
    ./configure --prefix=${apr_install_dir} --with-apr=${apr_install_dir} ${apr_util_additional}
    make -j ${THREAD} && make install
    cd ${source_dir}
    rm -rf ${source_dir}/apr-util-${apr_util_version} ${source_dir}/apr-util-${apr_util_version}.tar.gz
  else
    echo "Apr-util download Failed! "
  fi
if [ -e "${apr_install_dir}/bin/apu-1-config" ]; then
    echo "Apr-util installed successfully! "
    echo "Apr-util installed successfully! "
    echo "Apr-util installed successfully! "
  else
    echo "Apr-util installed Failed! "
    echo "Apr-util installed Failed! "
    echo "Apr-util installed Failed! "
  fi
#结束安装 apr-util

# 安装 Apache
wget ${Mirror_source}/apache//httpd/httpd-${Apache_version}.tar.gz
if [ -e "${source_dir}/httpd-${Apache_version}.tar.gz" ]; then
    echo "Apr download successfully! "
    tar xzf ${source_dir}/httpd-${Apache_version}.tar.gz
    cd ${source_dir}/httpd-${Apache_version}
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

    #logrotate apache log
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
    mkdir ${apache_install_dir}/conf/vhost
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
Include conf/vhost/*.conf
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
    echo "Apache download Failed! "
  fi
if [ -e "${apache_install_dir}/bin/httpd" ]; then
    echo "Apache installed successfully! "
    echo "Apache installed successfully! "
    echo "Apache installed successfully! "
  else
    echo "Apache installed Failed! "
    echo "Apache installed Failed! "
    echo "Apache installed Failed! "
  fi
#结束安装 Apache