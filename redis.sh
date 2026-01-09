#! /bin/bash
app_name=redis

source ./common.sh
check_root

dnf module disable redis -y &>> $LOG_FILE
Validate $? "Disabiling Redis"

dnf module enable redis:7 -y &>> $LOG_FILE
Validate $? "Enabling Redis module"

dnf install redis -y  &>> $LOG_FILE
Validate $? "Installing redis module"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
Validate $? "Changing the local host"

sed -i '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
Validate $? "Changing the local host"

systemctl enable redis  &>> $LOG_FILE
Validate $? "redis enabled"

systemctl start redis  &>> $LOG_FILE
Validate $? "Redis server started" 