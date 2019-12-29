#/bin/bash
dnf clean all
dnf makecache
pkgList="nghttp2 libnghttp2 libnghttp2-devel java jemalloc jemalloc-devel openssh-server python python-devel python2 python2-devel chrony oniguruma-devel rpcgen go htop libicu icu deltarpm gcc gcc-c++ make cmake autoconf libjpeg libjpeg-devel libjpeg-turbo libjpeg-turbo-devel libpng libpng-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel krb5-devel libc-client libc-client-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio numactl numactl-libs readline-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel libxslt-devel libicu-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre pcre-devel libmcrypt libmcrypt-devel mhash mhash-devel mcrypt zip unzip sqlite-devel sysstat patch bc expect expat-devel oniguruma oniguruma-devel libtirpc-devel nss nss-devel rsync rsyslog git lsof lrzsz psmisc wget which libatomic tmux"
for Package in ${pkgList}; do
    dnf -y install ${Package}
    done
dnf -y update bash openssl glibc
sed -i "s@^#Port 22@Port 22122@" /etc/ssh/sshd_config
sed -i "s@^#PermitRootLogin.*@PermitRootLogin yes@" /etc/ssh/sshd_config
systemctl enable sshd && systemctl enable chronyd

mkdir /develop && cd /develop
wget https://raw.githubusercontent.com/arkylin/open_shell/master/options.conf

. /options.conf

mkdir -p ${app_dir} ${source_dir} ${data_dir} ${apache_install_dir} ${php74_install_dir}

#进入源码目录

#安装apr
wget ${Mirror_source}/apache//apr/apr-${apr_version}.tar.gz
if [ -e "${source_dir}/apr-${apr_version}.tar.gz" ]; then
    echo "Apr download successfully! "
    tar xzf ${source_dir}/apr-${apr_version}.tar.gz
    cd ${source_dir}/apr-${apr_version}
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
#结束安装apr

#安装apr-util
if [ -e "${source_dir}/apr-${apr_version}.tar.gz" ]; then
    echo "Apr download successfully! "
    wget ${Mirror_source}/apache//apr/apr-util-${apr_util_version}.tar.gz
    tar xzf ${source_dir}/apr-util-${apr_util_version}.tar.gz
    cd ${source_dir}/apr-util-${apr_util_version}
    ./configure --prefix=${apr_install_dir} --with-apr=${apr_install_dir} ${apr-util_additional}
    make -j ${THREAD} && make install
    cd ${source_dir}
    rm -rf ${source_dir}/apr-util-${apr_util_ver}
  else
    echo "Apr download Failed! "
  fi
if [ -e "${apr_install_dir}/bin/apu-1-config" ]; then
    echo "Apr installed successfully! "
    echo "Apr installed successfully! "
    echo "Apr installed successfully! "
  else
    echo "Apr installed Failed! "
    echo "Apr installed Failed! "
    echo "Apr installed Failed! "
  fi




