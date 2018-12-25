#!/bin/sh

sudo su
apt-get install perl
apt-get install make
apt-get install gcc
apt-get install libswitch-perl
cd ./src/DBI-1.642/
perl Makefile.PL
make
make test
make install
apt-get install libx11-dev
apt-get install libpng-dev libz-dev
apt-get install libjpeg-dev
cd ../Tk-804.033/
perl Makefile.PL
make
make test
make install
apt-get install mysql-server
apt-get install libmysqlclient-dev
cd ../DBD-mysql-4.022/
perl Makefile.PL
make
make test
make install
chmod +x ../PolyPrimer.pl
