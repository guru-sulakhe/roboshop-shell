#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log
R = "\e[31m"
G = "\e[32m"
Y = "\e[33m"
N = "\e[0m"
MONGO_HOST=mongodb.guru97s.cloud

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
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing nodejs"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Useradd roboshop"
else 
    echo "roboshop user already exists.. so $Y skipping $N"
fi

rm -rf /app &>> $LOGFILE
VALIDATE $? "Removing /app existed directory "

mkdir -p /app &>> $LOGFILE #if not exists then it will create, if exists it will be skipped
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading catalogue code and storing in tmp directory"

cd /app &>> $LOGFILE
VALIDATE $? "Changing to app directory"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unziping  catalogue.zip"

npm install &>> $LOGFILE
VALIDATE $? "Downloading dependencies"

cp /home/ec2-user/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "copying catalogue service to etc"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "loading the service"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Staring catalogue service"

cp /home/ec2-user/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongo.repo to etc directory"

dnf install -y mongodb-mongosh &>> $LOGFILE
VALIDATE $? "Installing mongodb client"

SCHEMA_EXISTS=$(mongosh --host $MONGO_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')") &>> $LOGFILE #check catalogue is existed in db or not
if [ $SCHEMA_EXISTS -lt 0 ]
then 
    echo "schema does not exists, LOADING SCHEMA"
    mongosh --host $MONGO_HOST </app/schema/catalogue.js &>> $LOGFILE
    VALIDATE $? "Loading catalogue data to mongodb"
else
    echo "schema is already exists.. so $Y SKIPPING $N"
fi



