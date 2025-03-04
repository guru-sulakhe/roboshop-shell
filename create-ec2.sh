#!/bin/bash

instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")
domain_name="guru97s.cloud"
hosted_zone_id="Z08844556711QEV7DH9F" #YOUR HOSTED ZONE ID

for name in ${instances[@]}; do
    if [ $name == "shipping" ] || [ $name == "mysql" ]
    then
        instance_type="t3.medium"
    else
        instance_type="t3.micro"
    fi
    echo "creating instance for: $name with instance type: $instance_type"
    instance_id=$(aws ec2 run-instances --image-id ami-454adgd12dd3dedbr --instance-type $instance_type --security-group-ids sg-903004f8oxg1sw4q --subnet-id subnet-6e7f829e4483287954 --query "Instances[0].InstanceId" --output text) #creating ec2 instance
    echo "instance created for $name"

    aws ec2 create-tags --resource $instance_id --tags Key=Name, Value=$name #creating tags for var instance_id 

    if [ $name == "web" ]
    then
        aws ec2 wait instance-running --instance-ids $instance_id #wating the instance, untill instance starts running,then only public-ip will be created
        public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].[PublicIpAddress]' --output text) #describing ec2,for displaying public-IP address
        ip_to_use=$public_ip
    else
        private_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].[PrivateIpAddress]' --output text) #describing ec2,for displaying private-IP address
        ip_to_use=$private_ip
    fi

    #creating R53 record for ec2-instances
    echo "creating R53 record for $name"
    aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch '
    {
    "Comment": "Creating a record set for '$name'"
    ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
        "Name"              : "'$name.$domain_name'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$ip_to_use'"
        }]
        }
    }]
    }'
done  