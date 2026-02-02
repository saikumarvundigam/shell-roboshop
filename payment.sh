
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



dnf install python3 gcc python3-devel -y &>> $LOG_FILE
VALIDATE $? "Python installation is"


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

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading payment code"

cp /tmp/payment.zip /app &>>$LOG_FILE
VALIDATE $? "Copying payment file to app is"

unzip payment.zip &>>$LOG_FILE
VALIDATE $? "Uzip payment code"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Creation of payment Service is"

systemctl daemon-reload
systemctl enable payment  &>>$LOG_FILE
systemctl start payment
VALIDATE $? "Starting and enabling payment"