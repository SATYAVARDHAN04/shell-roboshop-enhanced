#! /bin/bash
USERID=$(id -u)
red="\e[31m"
green="\e[32m"
reset="\e[0m"
LOGS_FOLDER="/var/logs/roboshop-log"
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p ${LOGS_FOLDER}

check_root(){
	if [ $USERID -ne 0 ]
	then 
		echo -e "${red}Error:${reset} Please run with root access...." | tee -a $LOG_FILE
		exit 1
	else
		echo -e "${green}Running with root access ${reset}" | tee -a $LOG_FILE
	fi
}

Validate() {
	if [ $1 -eq 0 ]
	then 
		echo -e "${green}$2 is done successfully${reset}" | tee -a $LOG_FILE
	else
		echo -e "${red}Error: $2 failed${reset}" | tee -a $LOG_FILE
		exit 1
	fi
}

Node_js_installation(){
	dnf module disable nodejs -y &>> $LOG_FILE
	Validate $? "Disabiling Nodejs"

	dnf module enable nodejs:20 -y &>> $LOG_FILE
	Validate $? "Enabling Node js module"

	dnf install nodejs -y &>> $LOG_FILE
	Validate $? "Installing Node js module"

	npm install &>> $LOG_FILE
	Validate $? "Installing the required Dependencies"
}

Create_user(){
	id roboshop &>> $LOG_FILE
	if [ $? -ne 0 ]
	then
		useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
		Validate $? "Creating roboshop system user"
	else
		echo "roboshop user already created"
	fi
}

Code_dependencies(){
	mkdir -p /app 
	Validate $? "Creating app directory"

	curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>> $LOG_FILE
	Validate $? "$app_name code downloading"

	cd /app 
	rm -rf /app/*
	unzip /tmp/$app_name.zip &>> $LOG_FILE
	Validate $? "moving to app directory and unziping it"

	cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
	Validate $? "Copying $app_name service"
}

Systemctl_commands(){
	systemctl daemon-reload &>> $LOG_FILE
	Validate $? "Realoding $app_name service"

	systemctl enable $app_name &>> $LOG_FILE
	Validate $? "$app_name enabled"

	systemctl start $app_name &>> $LOG_FILE
	Validate $? "$app_name server started" 

}

maven_installation(){
	dnf install maven -y &>> $LOG_FILE
	Validate $? "Installing maven module"

	cd /app 
	mvn clean package &>> $LOG_FILE
	Validate $? "Installing the required Dependencies"

	mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE
	Validate $? "Moving to jar file"
}

python_installation(){
	dnf install python3 gcc python3-devel -y &>> $LOG_FILE
Validate $? "Installing python module"

cd /app 
pip3 install -r requirements.txt &>> $LOG_FILE
Validate $? "Installing the required Dependencies"

}


