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

dnf install python3 gcc python3-devel -y &>> $LOG_FILE
Validate $? "Installing python module"

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]
then
	useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
	Validate $? "Creating roboshop system user"
else
	echo "roboshop user already created"
fi

mkdir -p /app 
Validate $? "Creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $LOG_FILE
Validate $? "Payment code downloading"

cd /app 
rm -rf /app/*
unzip /tmp/payment.zip &>> $LOG_FILE
Validate $? "moving to app directory and unziping it"

cd /app 
pip3 install -r requirements.txt &>> $LOG_FILE
Validate $? "Installing the required Dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
Validate $? "Copying payment service"

systemctl daemon-reload &>> $LOG_FILE
Validate $? "Realoding payment service"

systemctl enable payment &>> $LOG_FILE
Validate $? "payment enabled"

systemctl start payment &>> $LOG_FILE
Validate $? "payment server started" 