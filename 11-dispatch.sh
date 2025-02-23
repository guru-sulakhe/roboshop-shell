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

dnf install golang -y

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    echo "Adding user roboshop"
    useradd roboshop &>> $LOGFILE
else
    echo "user roboshop is already exists, so $Y SKIPPING $Y"
fi

mkdir /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE
VALIDATE $? "Downloading dispatch.zip and storing it in tmp directory"

cd /app &>> $LOGFILE
VALIDATE $? "Changing to app directory"

unzip /tmp/dispatch.zip &>> $LOGFILE
VALIDATE $? "unziping dispath.service"

go mod init dispatch &>> $LOGFILE
VALIDATE $? "Downloading dependencies and build software"

go get &>> $LOGFILE
VALIDATE $? "Downloading dependencies and build software"

go build &>> $LOGFILE
VALIDATE $? "Downloading dependencies and build software"

cp /home/ec2-user/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE
VALIDATE $? "Copying dispatch.service to etc directory"


systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Loading the service"

systemctl enable dispatch &>> $LOGFILE
VALIDATE $? "Enabling dispatch service"

systemctl start dispatch &>> $LOGFILE
VALIDATE $? "Starting dispatch service"

