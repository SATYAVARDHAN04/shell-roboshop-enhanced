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
app_name=rabbitmq

source ./common.sh
check_root

read -s -p "Enter the rabbitmq password: " RABBITMQ_PASSWORD

dnf install maven -y &>> $LOG_FILE
Validate $? "Installing maven module"

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
Validate $? "Copying rabbitmq repository"

dnf install rabbitmq-server -y &>> $LOG_FILE
Validate $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>> $LOG_FILE
Validate $? "rabbitmq server enabled"

systemctl start rabbitmq-server &>> $LOG_FILE
Validate $? "rabbitmq server started" 

rabbitmqctl add_user roboshop $RABBITMQ_PASSWORD &>> $LOG_FILE
Validate $? "Adding roboshop user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
Validate $? "Changing rabbitmq user permission"