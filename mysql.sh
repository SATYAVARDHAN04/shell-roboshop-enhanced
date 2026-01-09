#! /bin/bash
app_name=mysql

source ./common.sh
check_root

read -s -p "Enter the mysql root password: " mysqlpasswd

dnf install mysql-server -y  &>> $LOG_FILE
Validate $? "Installing mysql server module"

systemctl enable mysqld &>> $LOG_FILE
Validate $? "mysql enabled"

systemctl start mysqld  &>> $LOG_FILE
Validate $? "Mysql server started" 

mysql_secure_installation --set-root-pass $mysqlpasswd &>> $LOG_FILE
Validate $? "Mysql secure installation" 