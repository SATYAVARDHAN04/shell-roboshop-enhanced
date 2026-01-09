#! /bin/bash

app_name=frontend
source ./common.sh
check_root


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