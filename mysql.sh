#! /bin/bash

USERID=$(id -u)
red="\e[31m"
green="\e[32m"
reset="\e[0m"
LOGS_FOLDER="/var/logs/roboshop-log"
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p ${LOGS_FOLDER}
app_name=mysql

source ./common.sh
check_root
Validate

read -s -p "Enter the mysql root password: " mysqlpasswd

dnf install mysql-server -y  &>> $LOG_FILE
Validate $? "Installing mysql server module"

systemctl enable mysqld &>> $LOG_FILE
Validate $? "mysql enabled"

systemctl start mysqld  &>> $LOG_FILE
Validate $? "Mysql server started" 

mysql_secure_installation --set-root-pass $mysqlpasswd &>> $LOG_FILE
Validate $? "Mysql secure installation" 