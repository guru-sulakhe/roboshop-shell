#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log
MYSQL_HOST=mysql.guru97s.cloud
R = "\e[31m"
G = "\e[32m"
Y = "\e[33m"
N = "\e[0m"

VALIDATE(){
    if [$1 -ne 0]
    then
        echo -e "$2.. $R Failed $N"
    else
        echo -e "$2.. $G Successful $N" 
    fi   
}

if [$USERID -ne 0]
then
    echo "you don't have access, only root-user can access the file, try to login in as root-user"
    exit 1 # manually exits if error
else
    echo "You are super-user"
fi

dnf install python3.11 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "installing python"

id roboshop &>> $LOGFILE
if [ $? -ne 0]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "adding user roboshop"
else
    echo "user roboshop is already exists so skipping.."
fi

rm -rf /app &>> $LOGFILE
VALIDATE $? "clean up existing directory"

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading payment.zip and storing it on tmp directory"

cd /app &>> $LOGFILE
VALIDATE $? "Changing to app directory"

unzip /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzipping payment.zip in app directory"

pip3.11 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "installing python build dependencies"

cp payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copying payment.service to etc directory"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "loading service"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "Enabling payment service"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting payment service"


