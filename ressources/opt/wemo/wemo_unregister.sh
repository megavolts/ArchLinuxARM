#!/bin/sh
. /etc/profile
if [ "$1" = "" ];
then echo
echo "no client id specified, for example:  ./wemo_unregister.sh b0e826a96401f9d0"
echo
exit
else
java -cp WemoServer.jar mpp.wemo.server.Headless -p 4033 -remove $1 -log
fi
