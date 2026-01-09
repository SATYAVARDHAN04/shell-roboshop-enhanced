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
app_name=shipping

source ./common.sh
check_root
Create_user

dnf install maven -y &>> $LOG_FILE
Validate $? "Installing maven module"

read -s -p "Enter the mysql root password: " mysqlpasswd

mkdir -p /app 
Validate $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>> $LOG_FILE
Validate $? "Shipping code downloading"

cd /app 
rm -rf /app/*
unzip /tmp/shipping.zip &>> $LOG_FILE
Validate $? "moving to app directory and unziping it"

cd /app 
mvn clean package &>> $LOG_FILE
Validate $? "Installing the required Dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE
Validate $? "Moving to jar file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
Validate $? "Copying shipping service"

systemctl daemon-reload &>> $LOG_FILE
Validate $? "Realoding shipping service"

systemctl enable shipping &>> $LOG_FILE
Validate $? "shipping enabled"

systemctl start shipping &>> $LOG_FILE
Validate $? "shipping server started" 

dnf install mysql -y &>> $LOG_FILE
Validate $? "Installing Mysql client"

mysql -h mysql.satyology.site -uroot -p$mysqlpasswd -e 'cities'
if [ $? -ne 0 ] 
then 
	mysql -h mysql.satyology.site -uroot -p$mysqlpasswd < /app/db/schema.sql &>> $LOG_FILE
	Validate $? "Loading Schema data"

	mysql -h mysql.satyology.site -uroot -p$mysqlpasswd < /app/db/app-user.sql &>> $LOG_FILE
	Validate $? "Loading User data"

	mysql -h mysql.satyology.site -uroot -p$mysqlpasswd < /app/db/master-data.sql &>> $LOG_FILE
	Validate $? "Loading countries and states data"
else
	echo "cities database already exists"
fi

systemctl restart shipping &>> $LOG_FILE
Validate $? "Restarting shipping"
