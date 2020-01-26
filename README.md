此项目旨在创建一个通用的lamp安装脚本，来使那些“特别想用新版本，但又不会自己编译安装或者不想自己花时间去弄”的人得到方便</br>

后续可能也可能会推出一些其他环境来弄或者一些有意思的软件</br>

安装脚本</br>

***
mkdir /data
***

***
docker run -itd --name super --hostname super.xyz.blue --net host --privileged=true -v /data:/data arkylin/newest_lamp:latest /sbin/init
***

注：-V 冒号":"前面的目录是宿主机目录，后面的目录是容器内目录。</br>

请关注我的博客 https://www.xyz.blue