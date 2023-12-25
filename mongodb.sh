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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> LOGFILE

VALIDATE $? "Copied MongoDB Repo"

dnf install mongodb-org -y  &>> LOGFILE
VALIDATE $? "Installing MongoDB :: "

systemctl enable mongod
VALIDATE $? "Enabling MongoDB :: "

systemctl start mongod
VALIDATE $? "Starting MongoDB :: "