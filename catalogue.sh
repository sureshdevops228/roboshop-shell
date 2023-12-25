#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script execution start at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root user $N"
    exit 1
else
    echo -e "$G You are root user $N"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling current nodejs version :: " 

dnf module enable nodejs:18 -y &>> $LOGFILE
 
VALIDATE $? "enabling current nodejs18 version :: " 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs18 version :: " 

id roboshop
if [ $? -ne 0 ]
then
    user add roboshop  &>> $LOGFILE
    VALIDATE $? "Roboshop user creation :: "
else
    echo -e "Roboshop user alredy exists $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating app directory :: " 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catalogue application software :: " 

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue application software :: " 

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies :: " 

#User absolute path as catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue.service file :: " 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon-reload:: " 

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling catalogue:: " 

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "start the catalogue:: " 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copyinh mongo.repo file :: " 

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongo db client :: " 

mongo --host mongodb.daws76s.online </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loaing catalogue data into mongodb :: "
