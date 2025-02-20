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

dnf install mysql-server -y &>> $LOGFILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling mysqld"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? " Changing the default root password in order to start using the database service"






