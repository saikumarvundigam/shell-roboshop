#!/bin/bash

R="\e[31m"
G="\e[32m"
B="\e[33m"
Y="\e[34m"
N="\e[0m"
LOG_FOLDER="/var/log/roboshop"
LOG_FILE="$LOG_FOLDER"/$0.log
MONGODB_HOST=mongo.cloudmine.co.in
SCRIPT_DIR=/home/ec2-user/shell-roboshop


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


dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disablinig NodeJS default version"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling of Node JS 20 version is"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "NODE JS installation is"


id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Roboshop user creation is"
else
echo "Roboshp user already exists. Skipping...!!!"
fi

mkdir -p /app
VALIDATE $? "Directory creation is"

# cd /app
# VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading cart code"

unzip /tmp/cart.zip -d /app &>>LOG_FILE
VALIDATE $? "Uzip cart code"

npm install  &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Creation of Service is"

systemctl daemon-reload
systemctl enable cart  &>>$LOG_FILE
systemctl start cart
VALIDATE $? "Starting and enabling cart"