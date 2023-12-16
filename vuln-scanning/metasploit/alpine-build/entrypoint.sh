#!/bin/bash

echo "####################################"
echo "### METASPLOIT FRAMEWORK INSTALL ###"
echo "####################################"
echo
echo "============> Account configuration."
echo
echo "Username : "
read USER
adduser --shell /bin/bash -h /home/$USER $USER
echo "###################################################################################"
echo "The user $USER will be automatically added among sudoers with all permissions"
echo "###################################################################################"
echo "$USER	ALL=(ALL:ALL) ALL" >> /etc/sudoers

chown -R $USER /usr/local/bundle/

cat - <<-EOF | su $USER
mkdir /home/$USER/.msf4
mkdir /home/$USER/.bundle
bundle install
EOF

for MSF in $(ls msf*); do
	if ! [ -L /usr/local/bin/$MSF ]; then
		ln -s /opt/metasploit-framework/$MSF /usr/local/bin/$MSF;
	fi
done

echo "####################################"
echo " ===========> Database configuration"
echo "####################################"
echo
echo " DB User : "; read DBUSER
echo " DB Password : "; read DBPASS
echo " DB Name : "; read DBNAME
echo
echo "Echo prompt values: "
echo
echo "DBUser: $DBUSER"
echo "DBPass: $DBPASS"
echo "DBName: $DBNAME"
echo
echo "Shall we proceed? "

read -p "Continue (y/n)?" C
if [ "$C" == "n" ]; then
  exit 1
fi

export PGDATA=/var/lib/postgresql/data
mkdir -p "$PGDATA"
mkdir -p /var/run/postgresql
mkdir -p /var/log/postgresql
chown -R postgres "$PGDATA" /var/run/postgresql /var/log/postgresql

<<comment
if [ -z "$(ls -A "$PGDATA")" ]; then
    su-exec postgres initdb
    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf

    : ${POSTGRES_USER:="$DBUSER"}
    : ${POSTGRES_DB:="$DBNAME"}

    if [ "$POSTGRES_PASSWORD" ]; then
      pass="PASSWORD '$DBPASS'"
      authMethod=md5
    else
      echo "==============================="
      echo "!!! NO PASSWORD SET !!! (Use \$POSTGRES_PASSWORD env var)"
      echo "==============================="
      pass=
      authMethod=trust
    fi
    echo


    if [ "$POSTGRES_DB" != 'postgres' ]; then
      createSql="CREATE DATABASE $POSTGRES_DB;"
      echo $createSql | su-exec postgres postgres --single -jE
      echo
    fi

    if [ "$POSTGRES_USER" != 'postgres' ]; then
      op=CREATE
    else
      op=ALTER
    fi

    userSql="$op USER $POSTGRES_USER WITH SUPERUSER $pass;"
    echo $userSql | su-exec postgres postgres --single -jE
    echo

    su-exec postgres pg_ctl -D "$PGDATA" \
        -o "-c listen_addresses='localhost'" \
        -w start -l /var/log/postgresql/msfdb.log
    echo
    psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"
    echo
    su-exec postgres pg_ctl -D "$PGDATA" -m fast -w stop
    echo
    echo "host all all 0.0.0.0/0 $authMethod" >> "$PGDATA"/pg_hba.conf
    exec "$@"

fi

mkdir -p /run/openrc/exclusive

# Configuration
/etc/init.d/postgresql setup
/etc/init.d/postgresql start
psql -U postgres -c
comment

# reduce to just what is needed to get msf to connect to psql
su-exec postgres initdb
sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf

createSql="CREATE USER $DBUSER WITH PASSWORD '"$DBPASS"' ;"
echo $createSql | su-exec postgres postgres --single -jE
userSql="CREATE DATABASE $DBNAME OWNER $DBUSER;"
echo $userSql | su-exec postgres postgres --single -jE
grantSql="grant ALL ON DATABASE $DBNAME TO $DBUSER;"
echo $grantSql | su-exec postgres postgres --single -jE

su-exec postgres pg_ctl -D "$PGDATA" start -l /var/log/postgresql/msfdb.log

echo "host all all 0.0.0.0/0 md5" >> "$PGDATA"/pg_hba.conf

tee /home/$USER/.msf4/database.yml <<EOF
production:
 adapter: postgresql
 database: $DBNAME
 username: $DBUSER
 password: $DBPASS
 host: localhost
 port: 5432
 pool: 75
 timeout: 5
EOF

#su-exec $USER msfconsole -x "db_connect $DBUSER:$DBPASS@localhost:5432/$DBNAME"
su-exec $USER msfconsole -x "db_status"

exec "$@"
