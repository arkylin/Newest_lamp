*Newest_lamp*

此项目旨在创建一个通用的lamp安装脚本，来使那些“特别想用新版本，但又不会自己编译安装或者不想自己花时间去弄”的人得到方便</br>

后续可能也可能会推出一些其他环境来弄或者一些有意思的软件</br>

安装脚本</br>

一、添加目录</br>
```
mkdir -p /data/{ssl,vhost/apache,wwwroot,wwwroot/default,wwwlogs}
```

二、运行</br>
```
docker run -itd --name super --hostname super.xyz.blue --net host --privileged=true -v /data:/data arkylin/newest_lamp:latest /sbin/init
```

注：-V 冒号":"前面的目录是宿主机目录，后面的目录是容器内目录。</br>

Apache配置命令</br>
```
mkdir ${apache_install_dir}/conf/vhost
```
```
domain=super.xyz.blue
```
```
Apache_fcgi=$(echo -e "<Files ~ (\\.user.ini|\\.htaccess|\\.git|\\.svn|\\.project|LICENSE|README.md)\$>\n    Order allow,deny\n    Deny from all\n  </Files>\n  <FilesMatch \\.php\$>\n    SetHandler \"proxy:unix:/dev/shm/php-cgi.sock|fcgi://localhost\"\n  </FilesMatch>")
```
```
Apache_log="CustomLog \"/www/data/wwwlogs/${domain}_apache.log\" common"
```
```
cat > /data/vhost/apache/${domain}.conf << EOF
<VirtualHost *:88>
  ServerAdmin admin@xyz.blue
  DocumentRoot /www/data/wwwroot/${domain}
  ServerName ${domain}
  # ServerAlias xyz.blue
  SSLEngine on
  SSLCertificateFile /data/ssl/my.crt
  SSLCertificateKeyFile /data/ssl/my.key
  ErrorLog /www/data/wwwlogs/${domain}_error_apache.log
  ${Apache_log}
  ${Apache_fcgi}
<Directory /www/data/wwwroot/${domain}>
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

请关注我的博客 https://www.xyz.blue</br>