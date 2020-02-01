# Newest_lamp

此项目旨在创建一个通用的lamp安装脚本，来使那些“特别想用新版本，但又不会自己编译安装或者不想自己花时间去弄”的人得到方便</br>

后续可能也可能会推出一些其他环境来弄或者一些有意思的软件</br>

安装脚本</br>

一、添加目录</br>
```
mkdir -p /data/{ssl,vhost/apache,mysql,wwwroot,wwwroot/default,wwwlogs}
```
```
mkdir -p /data/{ssl,vhost/apache,wwwroot,wwwroot/default,wwwlogs}
```

二、运行</br>
```
docker run -itd --name super --hostname super.xyz.blue --net host --restart always --privileged -v /data:/data -v /data/pgsql:/var/lib/pgsql arkylin/newest_lamp:self-latest /usr/sbin/init
```
```
docker run -itd --name super --hostname super.xyz.blue --net host --restart always --privileged -v /data:/data -v /data/pgsql:/var/lib/pgsql arkylin/workspace:work /usr/sbin/init
```
```
docker run -itd --name super --hostname super.xyz.blue --net host --restart always --privileged -v /data:/data arkylin/newest_lamp:latest /usr/sbin/init
```

三、初始化Mysql
```
mysql_secure_installation
```

注：-V 冒号":"前面的目录是宿主机目录，后面的目录是容器内目录。</br>

Apache配置命令</br>
```
cp -f /app/apache/conf/vhost/0.conf /data/vhost/apache
```
```
mkdir /data/vhost/apache
```
```
domain=super.xyz.blue
```
```
Apache_fcgi=$(echo -e "<Files ~ (\\.user.ini|\\.htaccess|\\.git|\\.svn|\\.project|LICENSE|README.md)\$>\n    Order allow,deny\n    Deny from all\n  </Files>\n  <FilesMatch \\.php\$>\n    SetHandler \"proxy:unix:/dev/shm/php-cgi.sock|fcgi://localhost\"\n  </FilesMatch>")
```
```
Apache_log="CustomLog \"/data/wwwlogs/${domain}_apache.log\" common"
```
```
cat > /data/vhost/apache/${domain}.conf << EOF
<VirtualHost *:88>
  ServerAdmin admin@xyz.blue
  DocumentRoot /data/wwwroot/${domain}
  ServerName ${domain}
  # ServerAlias xyz.blue
  #SSLEngine on
  #SSLCertificateFile /data/ssl/my.crt
  #SSLCertificateKeyFile /data/ssl/my.key
  ErrorLog /data/wwwlogs/${domain}_error_apache.log
  ${Apache_log}
  ${Apache_fcgi}
<Directory /data/wwwroot/${domain}>
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  Require all granted
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF
```
使Apache生效</br>
```
apachectl -t
```
```
apachectl -k graceful
```

USELESS</br>
```
cat >> /root/.bashrc <<EOF
systemctl restart php-fpm
systemctl restart httpd
systemctl restart mariadb
EOF
```

博客配置
```
<VirtualHost *:88>
  ServerAdmin admin@xyz.blue
  DocumentRoot /data/wwwroot/www.xyz.blue
  ServerName www.xyz.blue
  ServerAlias xyz.blue
  #SSLEngine on
  #SSLCertificateFile /data/ssl/my.crt
  #SSLCertificateKeyFile /data/ssl/my.key
  ErrorLog /data/wwwlogs/www.xyz.blue_error_apache.log
  
  <Files ~ (\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)$>
    Order allow,deny
    Deny from all
  </Files>
  <FilesMatch \.php$>
    SetHandler "proxy:unix:/dev/shm/php-cgi.sock|fcgi://localhost"
  </FilesMatch>
<Directory /data/wwwroot/www.xyz.blue>
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  Require all granted
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
```
前端用Caddy
```
/app/caddy/c* start --config /app/caddy/C
```
```
{
http_port 80
https_port 443
experimental_http3
}
xyz.blue www.xyz.blue {
tls /data/ssl/my.crt /data/ssl/my.key
header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"
reverse_proxy 127.0.0.1:88
}
```
分享一个Nextcloud/Owncloud的Caddy 2前端配置文件
```
aaa.com {
tls /data/ssl/my.crt /data/ssl/my.key
header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"
reverse_proxy 127.0.0.1:88 {
header_up Host {http.request.host}
header_up X-Real-IP {http.request.remote.host}
header_up X-Forwarded-For {http.request.remote.host}
header_up X-Forwarded-Port {http.request.port}
header_up X-Forwarded-Proto {http.request.scheme}
}
redir /.well-known/carddav /remote.php/carddav 301
redir /.well-known/caldav /remote.php/caldav 301
}
```

PMA安装指南</br>
下载解压</br>
```
/bin/cp ${wwwroot_dir}/phpMyAdmin/{config.sample.inc.php,config.inc.php}
mkdir ./{upload,save}
sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" config.inc.php
sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" config.inc.php
sed -i "s@host'\].*@host'\] = '127.0.0.1';@" config.inc.php
sed -i "s@blowfish_secret.*;@blowfish_secret\'\] = \'$(cat /dev/urandom | head -1 | base64 | head -c 45)\';@" config.inc.php
mkdir ${wwwroot_dir}/phpMyAdmin/tmp
chmod -R 777 ${wwwroot_dir}/phpMyAdmin/tmp
chown -R www.www ${wwwroot_dir}/phpMyAdmin/
```
Docker内安装Mysql/Mariadb提示"服务器和客户端上指示的 HTTPS 之间不匹配"解决方案见我的博客文章</br>
https://www.xyz.blue/archives/when-installing-mysql-mariadb-in-docker-the-solution-of-mismatch-between-https-indicated-on-server-and-client-will-be-prompted.html

请关注我的博客 https://www.xyz.blue</br>