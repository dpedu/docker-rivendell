#!/bin/bash

sleep 5

/etc/init.d/apache2 start

sleep 5

# Wait for mysql to come online
while [ "`ps aux | grep mysqld_safe | grep -v grep | wc -l`" -eq 0 ] ; do
    sleep 1
done

# Create rivendell database if it doesn't exist
DBS=`echo "show databases ; " | mysql -u root -proot | grep Rivendell | wc -l`
if [ $DBS -eq 0 ] ; then
    # Assume this is a first run and do some other stuff
    chmod 777 /var/run/rivendell/
    chown -R rduser /var/snd
    # Create default database
    DISPLAY=:0 rdadmin --check-db --mysql-admin-user=root --mysql-admin-password=root --mysql-admin-hostname=127.0.0.1 --mysql-admin-dbname=Rivendell
fi

rdadmin --check-db

# Apache is trouble
/etc/init.d/apache2 restart

sleep 5

# Start gui apps

su -c "DISPLAY=:0 rdairplay &" rduser
su -c "DISPLAY=:0 jamin &" rduser

sleep 10

# Disconnect jamin from system audio
su -c "jack_disconnect jamin:out_L system:playback_1" rduser
su -c "jack_disconnect jamin:out_R system:playback_2" rduser

# Connect rivendell to jamin

su -c "jack_connect rivendell_0:playout_0R jamin:in_R" rduser
su -c "jack_connect rivendell_0:playout_0L jamin:in_L" rduser

