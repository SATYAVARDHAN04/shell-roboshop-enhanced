#! /bin/bash

USERID=$(id -u)
red="\e[31m"
green="\e[32m"
reset="\e[0m"
LOGS_FOLDER="/var/logs/roboshop-log"
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p ${LOGS_FOLDER}

if [ $USERID -ne 0 ]
then 
	echo -e "${red}Error:${reset} Please run with root access...." | tee -a $LOG_FILE
	exit 1
else
	echo -e "${green}Running with root access ${reset}" | tee -a $LOG_FILE
fi

Validate() {
	if [ $1 -eq 0 ]
	then 
		echo -e "${green}$2 is done successfully${reset}" | tee -a $LOG_FILE
	else
		echo -e "${red}Error: $2 failed${reset}" | tee -a $LOG_FILE
		exit 1
	fi
}

cp mongodb.repo /etc/yum.repos.d/mongodb.repo &>> $LOG_FILE
Validate $? "Copying of repo folder"

dnf install mongodb-org -y &>> $LOG_FILE
Validate $? "mongodb installation"

systemctl enable mongod &>> $LOG_FILE
Validate $? "mongodb enabled"

systemctl start mongod &>> $LOG_FILE
Validate $? "mongodb server started" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
Validate $? "Configuration changed"

systemctl restart mongod &>> $LOG_FILE
Validate $? "mongodb server restarted"
