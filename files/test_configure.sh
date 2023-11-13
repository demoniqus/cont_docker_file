#!/bin/bash

xDebDir=/opt/xdebug
xDebPkgName=xdebug-2.9.8
mkdir "${xDebDir}"
#echo "XDEBUG TEMPORARY DIRECTORY IS CREATED"
wget -P "${xDebDir}" "https://pecl.php.net/get/${xDebPkgName}.tgz" --no-check-certificate && tar -xvf "${xDebDir}/${xDebPkgName}.tgz" -C "${xDebDir}"
echo "XDEBUG FILES ARE RECIEVED AND UNPACKED"
cd "${xDebDir}/${xDebPkgName}" && /usr/bin/phpize && ./configure --enable-xdebug 
echo "CURRENT DIRECTORY ID $(pwd)"
cd "${xDebDir}/${xDebPkgName}" && exec  bash;
#ls -Al
echo "RUN MAKE"
make 
echo "MAKE IS OK"
make install 
echo "MAKE INSTALL IS OK"
cd / && exec bash
 rm -rf "${xDebDir}"
