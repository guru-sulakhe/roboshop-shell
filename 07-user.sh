#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log
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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "Enabling nodejs:20"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Insatalling nodejs"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding user roboshop"
else
    echo "roboshop user already exists, so SKIPPING"

mkdir -p /app &>> $LOGFILE #if not exists it creates,if exists skipping
VALIDATE $? "Changing to app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading user code and storing in tmp directory"

cd /app &>> $LOGFILE
VALIDATE $? "Changing to app directory"

unzip /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unziping user.zip in tmp directory"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Copying user.service to etc directory"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Loading service"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enabling user service"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting user service"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying mongo.repo to etc directory"

dnf install mongodb-mongosh -y &>> $LOGFILE
VALIDATE $? "Installing mongodb client"

mongosh --host mongodb.guru97s.cloud </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Loading mongodb schema from mongodb"