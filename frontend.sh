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

Validate() {
	if [ $1 -eq 0 ]
	then 
		echo -e "${green}$2 is done successfully${reset}" | tee -a $LOG_FILE
	else
		echo -e "${red}Error: $2 failed${reset}" | tee -a $LOG_FILE
		exit 1
	fi
}

dnf module disable nginx -y &>> $LOG_FILE
Validate $? "Disabiling nginx"

dnf module enable nginx:1.24 -y &>> $LOG_FILE
Validate $? "Enabling nginx module"

dnf install nginx -y &>> $LOG_FILE
Validate $? "Installing nginx"

systemctl enable nginx  &>> $LOG_FILE
Validate $? "Enabling nginx"

systemctl start nginx  &>> $LOG_FILE
Validate $? "starting nginx service"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
Validate $? "Remove the default nginx content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE
Validate $? "Downloading the code for nginx"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>> $LOG_FILE
Validate $? "Unziping the code"

rm -rf /etc/nginx/nginx.conf &>> $LOG_FILE
Validate $? "Remove the default nginx file content"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>> $LOG_FILE
Validate $? "Copying the nginx configuration file"

systemctl restart nginx &>> $LOG_FILE
Validate $? "Restarting the nginx server"