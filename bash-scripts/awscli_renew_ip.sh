#!/bin/bash
# Restart Lightsail Server

# Note: AWS CLI should be configured on your machine
# IAM User should have start/stop lightsail policy assinged to it

instance_name='UPDATE_INSTANCE_NAME_HERE'

function refresh_ip {
    echo "Stopping AWS Lightsail Instance"
    aws lightsail stop-instance --instance-name ${instance_name}
    echo "Sleeping for 5 minutes"
    sleep 5m
    echo "Starting AWS Lightsail Instnace"
    aws lightsail start-instance --instance-name ${instance_name}
    echo "Done"
}

refresh_ip