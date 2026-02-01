#!/bin/bash

R="\e[31m"
G="\e[32m"
B="\e[33m"
Y="\e[34m"
N="\e[0m"



LOG_FOLDER="/var/log/roboshop"
LOG_FILE="$LOG_FOLDER"/$0.log
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
echo "$2 success"
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "MONGO Repo copy is "