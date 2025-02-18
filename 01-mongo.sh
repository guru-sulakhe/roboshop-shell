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
else
    echo "You are super-user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied Mongo Repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "install mongodb-org"


