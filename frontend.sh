#!/bin/bash

R="\e[31m"
G="\e[32m"
B="\e[33m"
Y="\e[34m"
N="\e[0m"
LOG_FOLDER="/var/log/roboshop"
LOG_FILE="$LOG_FOLDER"/$0.log
CATALOGUE_HOST=catalogue.cloudmine.co.in


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

dnf module disable nginx -y &>> $LOG_FILE
VALIDATE $? "Disablinig NginX default version"

dnf module enable nginx:1.24 -y &>> $LOG_FILE
VALIDATE $? "Enabling Nginx version is"

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "NginX installation is"

systemctl enable nginx 
systemctl start nginx
VALIDATE $? "Staring NginX Service is"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing of old NginX HTML files is"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "Frontend files are downloaded and unzipping is"

cp /app/roboshop/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Nginx config update is"

systemctl restart nginx
VALIDATE $? "ReStaring NginX Service is"