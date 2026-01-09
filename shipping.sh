#! /bin/bash
app_name=shipping

source ./common.sh
check_root
Create_user
Code_dependencies
maven_installation
Systemctl_commands

read -s -p "Enter the mysql root password: " mysqlpasswd

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
