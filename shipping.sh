#!/bin/bash

R="\e[31m"
G="\e[32m"
B="\e[33m"
Y="\e[34m"
N="\e[0m"
LOG_FOLDER="/var/log/roboshop"
LOG_FILE="$LOG_FOLDER"/$0.log
MYSQL_HOST=mysql.cloudmine.co.in
SCRIPT_DIR=$PWD


USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
echo "$R Please run the script using root user $N" | tee -a $LOG_FILE
exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE()
{
if [ $1 -ne 0 ]; then
echo "$2 failed." | tee -a  $LOG_FILE
else
echo "$2 success" | tee -a  $LOG_FILE
fi
}

dnf install maven -y &>> $LOG_FILE
VALIDATE $? "Maven installation is"


id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Roboshop user creation is"
else
echo "Roboshp user already exists. Skipping...!!!"
fi

mkdir -p /app
VALIDATE $? "Directory creation is"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading shipping code"

cp /tmp/shipping.zip /app
VALIDATE $? "Copying shipping file to app is"

unzip shipping.zip &>>$LOG_FILE
VALIDATE $? "Uzip shipping code"

mvn clean package &>>$LOG_FILE
mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Creation of shipping Service is"

systemctl daemon-reload
systemctl enable shipping  &>>$LOG_FILE
systemctl start shipping
VALIDATE $? "Starting and enabling shipping"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installatio of mysql-client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE

systemctl restart shipping
VALIDATE $? "Restarting and enabling shipping"