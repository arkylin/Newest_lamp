#/bin/bash
cd /develop
dnf install wget -y
wget https://raw.githubusercontent.com/arkylin/open_shell/master/options.conf

. /develop/options.conf

mkdir -p ${app_dir} ${source_dir} ${data_dir} ${apache_install_dir} ${php74_install_dir}

ls
ls
ls /