import json
import boto3

# Stop Lightsail Instance
def lambda_handler(event, context):
    client = boto3.client('lightsail', region_name='REGION_HERE')
    response = client.stop_instance(
    instanceName='INSTANCE_NAME'
)
    return {
        'statusCode': 200,
        'body': json.dumps('Lambda has stopped instance')
    }


# Start Lightsail Instance
import json
import boto3
def lambda_handler(event, context):
    client = boto3.client('lightsail', region_name='REGION_HERE')
    response = client.start_instance(
    instanceName='INSTANCE_NAME'
)
    return {
        'statusCode': 200,
        'body': json.dumps('Lambda started INSTANCE_NAME')
    }