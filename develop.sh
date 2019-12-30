#/bin/bash
pkgList="diffutils nghttp2 libnghttp2 libnghttp2-devel java jemalloc jemalloc-devel openssh-server python python-devel python2 python2-devel oniguruma-devel rpcgen go htop libicu icu deltarpm gcc gcc-c++ make cmake autoconf libjpeg libjpeg-devel libjpeg-turbo libjpeg-turbo-devel libpng libpng-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel krb5-devel libc-client libc-client-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio numactl numactl-libs readline-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel libxslt-devel libicu-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre pcre-devel libmcrypt libmcrypt-devel mhash mhash-devel mcrypt zip unzip sqlite-devel sysstat patch bc expect expat-devel oniguruma oniguruma-devel libtirpc-devel nss nss-devel rsync rsyslog git lsof lrzsz psmisc wget which libatomic tmux"
for Package in ${pkgList}; do
    dnf -y install ${Package}
    done
dnf -y update bash openssl glibc
sed -i "s@^#Port 22@Port ${ssh_port}@" /etc/ssh/sshd_config
sed -i "s@^#PermitRootLogin.*@PermitRootLogin yes@" /etc/ssh/sshd_config
systemctl enable sshd

cd /develop
wget https://raw.githubusercontent.com/arkylin/open_shell/master/options.conf

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
    wget https://raw.githubusercontent.com/arkylin/open_shell/master/apr-${apr_version}/configure
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
wget http://mirrors.tuna.tsinghua.edu.cn/apache//httpd/httpd-${Apache_version}.tar.gz
if [ -e "${source_dir}/httpd-${Apache_version}.tar.gz" ]; then
    echo "Apr download successfully! "
    tar xzf ${source_dir}/httpd-${Apache_version}.tar.gz
    cd ${source_dir}/httpd-${Apache_version}
    ./configure --prefix=${apache_install_dir} --enable-mpms-shared=all --with-pcre --with-apr=${apr_install_dir} --with-apr-util=${apr_install_dir} --enable-headers --enable-mime-magic --enable-deflate --enable-proxy --enable-so --enable-dav --enable-rewrite --enable-remoteip --enable-expires --enable-static-support --enable-suexec --enable-mods-shared=most --enable-nonportable-atomics=yes --enable-ssl --with-ssl --enable-http2 --with-nghttp2 ${Apache_additional}
    make -j ${THREAD} && make install
    cd ${source_dir}
    rm -rf ${source_dir}/httpd-${Apache_version} ${source_dir}/httpd-${Apache_version}.tar.gz
  else
    echo "Apache download Failed! "
  fi
if [ -e "${apr_install_dir}/bin/apu-1-config" ]; then
    echo "Apache installed successfully! "
    echo "Apache installed successfully! "
    echo "Apache installed successfully! "
  else
    echo "Apache installed Failed! "
    echo "Apache installed Failed! "
    echo "Apache installed Failed! "
  fi
#结束安装 Apache