#!/bin/sh
echo "unpacking tar"
tar -xvf /usr/local/aw/awpst*_freebsd12.tgz -C /usr/local/aw/
echo "deleting tgz"
rm /usr/local/aw/awpst*_freebsd12.tgz
echo "starting server"
/usr/local/aw/start-server
echo "Archiware P5 now installed" > /root/PLUGIN_INFO
