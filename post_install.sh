#!/bin/sh
mkdir /usr/local/aw
cd /usr/local/aw
echo "downloading package"
fetch http://p5-downloads.s3.amazonaws.com/awpst745-freebsd12.tgz
echo "unpacking tar"
tar -xvf /usr/local/aw/awpst*-freebsd12.tgz -C /usr/local/aw/
echo "deleting tgz"
rm /usr/local/aw/awpst*-freebsd12.tgz
echo "setting uuid"
fetch http://p5-downloads.s3.amazonaws.com/set_uuid.sh
chmod +x ./set_uuid.sh
./set_uuid.sh
echo "starting server"
/usr/local/aw/start-server
echo "Archiware P5 now installed" > /root/PLUGIN_INFO
