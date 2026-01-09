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

if [ $USERID -ne 0 ]
then 
	echo -e "${red}Error:${reset} Please run with root access...." | tee -a $LOG_FILE
	exit 1
else
	echo -e "${green}Running with root access!!! ${reset}" | tee -a $LOG_FILE
fi

read -s -p "Enter the rabbitmq password: " RABBITMQ_PASSWORD

Validate() {
	if [ $1 -eq 0 ]
	then 
		echo -e "${green}$2 is done successfully${reset}" | tee -a $LOG_FILE
	else
		echo -e "${red}Error: $2 failed${reset}" | tee -a $LOG_FILE
		exit 1
	fi
}

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