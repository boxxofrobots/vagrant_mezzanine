#!/bin/bash

# Updating repository

sudo apt-get -y update
sudo apt-get -y upgrade

# Installing Apache

sudo apt-get -y install apache2

# Installing MySQL and it's dependencies, Also, setting up root password for MySQL as it will prompt to enter the password during installation
apt-get --purge -y remove mysql-server mysql-common mysql-client

export MYSQLPASS=$(openssl rand -base64 16|sed 's:[^0-9a-zA-Z]::g')

export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -q -y purge mysql-server

sudo debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password password $MYSQLPASS"
sudo debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password_again password $MYSQLPASS"

# Install compiler tools and python
sudo apt-get -y install mysql-server-5.7 libapache2-mod-wsgi
sudo apt-get -y install build-essential python-dev mysql-client-5.7 libmysqlclient-dev python-mysqldb

sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests

sql="create database mezzanine;\
create user 'mezzanine'@'localhost' identified by '${MYSQLPASS}';\
grant all privileges on mezzanine.* to 'mezzanine'@'localhost';
"

#echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
#echo $sql
#echo "====================================================="

mysql --user=root --password=${MYSQLPASS} <<< ${sql}

   # wget -q http://repo.continuum.io/archive/Anaconda2-4.1.1-Linux-x86_64.sh
    #chmod +x Anaconda2-4.1.1-Linux-x86_64.sh
    #./Anaconda2-4.1.1-Linux-x86_64.sh -b -p /home/vagrant/Anaconda2
    #PYTHONPATH="/home/vagrant/anaconda2/bin:$PATH" 
   
	gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9
	gpg -a --export E084DAB9 | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install -y git bc wget python-pip
    sudo pip install --upgrade pip <<< "y"

	sudo apt-get install -y python-pandas python-urllib3
    sudo apt-get install -y libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libboost-all-dev libhdf5-serial-dev
    sudo apt-get install -y libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler
    sudo apt-get install -y libopenblas-base libopenblas-dev
	sudo pip install numpy jupyter flask bottle <<< "y"
	#Mezzanine install
	pip install mezzanine <<< "y"
	
	sudo cp -f /vagrant/000-default.conf /etc/apache2/sites-available/000-default.conf

	sudo systemctl restart apache2	
	
	#Now configure server and mezannine project
	_SITEIP_=$(wget -q http://169.254.169.254/latest/meta-data/public-ipv4/ -O -)
	_SITENAME_=$(ls -d /vagrant/*/)
	_SITENAME_=${_SITENAME_:0: -1}
	_SITENAME_=${_SITENAME_##*/}
	_SITEURL_=${_SITENAME_/_/.}
	echo "sitename:$_SITENAME_"
	
	echo "${MYSQLPASS}" > /vagrant/mysqlpass.txt
	echo ${_SITEIP_} > /vagrant/ipv4.txt

	mezzanine-project ${_SITENAME_}
	sudo cp -a /vagrant/${_SITENAME_}/flat/ ${_SITENAME_}
	sudo cp -a /vagrant/${_SITENAME_}/static/ ${_SITENAME_}
	sudo cp -a /vagrant/${_SITENAME_}/templates/ ${_SITENAME_}

	cp -a /vagrant/${_SITENAME_}/ .

	cd ${_SITENAME_}
		
	_ALLOWED_="ALLOWED_HOSTS = \['${_SITEIP_}','localhost','${_SITEURL_}'\]"
	sed -i "s:ALLOWED_HOSTS = \[\]:${_ALLOWED_}:g" ${_SITENAME_}/settings.py
	sed -i "s:_DOMAIN_IP_:${_SITEIP_}:g" ${_SITENAME_}/settings.py
	
	sed -i "s/\"ENGINE.*/\"ENGINE\"\: \"django.db.backends.mysql\",/g" ${_SITENAME_}/local_settings.py
	sed -i "s/\"NAME\":.*/\"NAME\"\: \"mezzanine\",/g" ${_SITENAME_}/local_settings.py
	sed -i "s/\"USER\":.*/\"USER\"\: \"root\",/g" ${_SITENAME_}/local_settings.py
	sed -i "s/\"PASSWORD\":.*/\"PASSWORD\"\: \"${MYSQLPASS}\",/g" ${_SITENAME_}/local_settings.py

	sed -i "s:_DOMAIN_NAME_:${_SITENAME_}:g" fabfile.py
	sed -i "s:_DOMAIN_NAME_:${_SITENAME_}:g" manage.py

	#python manage.py createdb --noinput
		echo "$_SITEIP_"
