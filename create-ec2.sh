#!/bin/bash

instances = ("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")

for name in ${instances[@]}; do
    if [ $name == "shipping" ] || [ $name == "mysql" ]
    then
        instance_type = "t3.medium"
    else
        instance_type = "t3.micro"
    fi
    echo "creating instance for: $name"
done 