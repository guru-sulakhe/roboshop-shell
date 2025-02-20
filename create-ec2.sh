#!/bin/bash

instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")

for name in ${instances[@]}; do
    if [ $name == "shipping" ] || [ $name == "mysql" ]
    then
        instance_type="t3.medium"
    else
        instance_type="t3.micro"
    fi
    echo "creating instance for: $name with instance type: $instance_type"
    instance_id=$(aws ec2 run-instances --image-id ami-454adgd12dd3dedbr --instance-type $instance_type --security-group-ids sg-903004f8oxg1sw4q --subnet-id subnet-6e7f829e4483287954 --query "Instances[0].InstanceId" --output text) #creating ec2 instance

    aws ec2 create-tags --resource $instance_id --tags Key=Name, Value=$name #creating tags for var instance_id 
    
    private_ip=$(aws ec2 describe-instances --instance-ids i-04429f69b1bbd7867 --query 'Reservations[0].Instances[0].[PrivateIpAddress]' --output text) #describing ec2,for displaying private-IP address

    if [$name=="web"]
    then
        aws ec2 wait instance-running --instance-ids $instance_id #wating the instance, untill instance starts running,then only public-ip will be created
        public_ip=$(aws ec2 describe-instances --instance-ids i-04429f69b1bbd7867 --query 'Reservations[0].Instances[0].[PublicIpAddress]' --output text) #describing ec2,for displaying public-IP address

done 