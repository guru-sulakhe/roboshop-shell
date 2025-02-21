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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing java packages"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "roboshop user already exist...$Y SKIPPING $N"
fi

rm -rf /app &>> $LOGFILE
VALIDATE $? "clean up existing directory"

mkdir /app &>> $LOGFILE
VALIDATE $? "Changing to app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "downloading shipping code and storing in tmp directory"

cd /app &>> $LOGFILE
VALIDATE $? "changing to app directory"

unzip /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unziping shipping.zip"

mvn clean package &>> $LOGFILE
VALIDATE $? "cleaning mvn package"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "moving shipping.jar"
 
cp shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copying shipping.service to etc directory"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Loading the service"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling shipping service"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Startign shipping service"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e "use cities" &>> $LOGFILE
if [ $? -ne 0 ]
then
    echo "Schema is ... LOADING"
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
    VALIDATE $? "Loading schema"
else
    echo -e "Schema already exists... $Y SKIPPING $N"
fi

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting shipping service"
