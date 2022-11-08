#!/bin/bash

# mysqld creates log files without read permissions for others,
# create them beforehand so we can give permissions to the agent.
touch /var/log/mysql/$HOSTNAME-error.log
touch /var/log/mysql/$HOSTNAME-slow.log

chown mysql:mysql /var/log/mysql/*.log
chmod a+wx /var/log/mysql
chmod a+r -R /var/log/mysql


# Write "test.cnf" config
cat << EOF > /etc/mysql/conf.d/test.cnf
[mysqld]
bind-address = 0.0.0.0
log-error = /var/log/mysql/$HOSTNAME-error.log
EOF

# Write "slow-log.cnf" config (/var/lib/mysql/<hostname>-slow.log, but in the shared log directory).
cat << EOF > /etc/mysql/conf.d/slow-log.cnf
[mysqld]
slow-query-log=ON
slow-query-log-file=/var/log/mysql/$HOSTNAME-slow.log
long-query-time=0
EOF

exec bash /entrypoint.sh mysqld
