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

dnf module disable nodejs -y &>> $LOG_FILE
Validate $? "Disabiling Nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
Validate $? "Enabling Node js module"

dnf install nodejs -y &>> $LOG_FILE
Validate $? "Installing Node js module"

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

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
Validate $? "Catalogue code downloading"

cd /app 
rm -rf /app/*
unzip /tmp/catalogue.zip &>> $LOG_FILE
Validate $? "moving to app directory and unziping it"

cd /app 
npm install &>> $LOG_FILE
Validate $? "Installing the required Dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
Validate $? "Copying Catalogue service"

systemctl daemon-reload &>> $LOG_FILE
Validate $? "Realoding catalogue service"

systemctl enable catalogue &>> $LOG_FILE
Validate $? "catalogue enabled"

systemctl start catalogue &>> $LOG_FILE
Validate $? "catalogue server started" 

cp $SCRIPT_DIR/mongodb.repo /etc/yum.repos.d/mongo.repo
Validate $? "mongodb repo copied"

dnf install mongodb-mongosh -y &>> $LOG_FILE
Validate $? "Installing Mongodb client"

STATUS=$(mongosh --host mongodb.satyology.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.satyology.site </app/db/master-data.js &>>$LOG_FILE
    Validate $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... SKIPPING"
fi