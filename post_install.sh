#!/bin/sh
mkdir /usr/local/aw
cd /usr/local/aw
echo "downloading package"
fetch https://p5-downloads.s3.amazonaws.com/awpst612-freebsd12.tgz
echo "unpacking tar"
tar -xvf /usr/local/aw/awpst*-freebsd12.tgz -C /usr/local/aw/
echo "deleting tgz"
rm /usr/local/aw/awpst*-freebsd12.tgz
echo "starting server"
/usr/local/aw/start-server
echo "Archiware P5 now installed" > /root/PLUGIN_INFO
