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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo   
VALIDATE  $? "Adding RabbitMQ Repo is"

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "RabbitMQ installation  is"

systemctl enable rabbitmq-server &>> $LOG_FILE
systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Enabling and Staring of RabbitMQ service is"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "Adding User and Set Permisssions are"