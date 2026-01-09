#! /bin/bash
app_name=catalogue

source ./common.sh
check_root
Code_dependencies
Node_js_installation
Create_user
Systemctl_commands

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