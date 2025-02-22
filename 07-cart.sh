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

id roboshop $>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding user roboshop"
else
    echo "roboshop user is already exists, so skipping"

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Changing to app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading cart code and storing in tmp directory"

cd /app &>> $LOGFILE
VALIDATE $? "Changing to app directory"

unzip /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unziping cart.zip in tmp directory"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Copying user.service to etc directory"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Loading service"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling cart service"

systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting cart service"
