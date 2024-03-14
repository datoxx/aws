import boto3

def lambda_handler(event, context):
    ec2_client = boto3.client('ec2', region_name="eu-central-1")
    
    # status of instances 
    def check_instance_status():
        statuses = ec2_client.describe_instance_status(IncludeAllInstances=True)
    
          # Get a list of available Elastic IPs
        response = ec2_client.describe_addresses()
    
        # Find the first available Elastic IP (you can modify this logic as needed)
        elastic_ip = None
        for address in response['Addresses']:
            if 'InstanceId' not in address:
                elastic_ip = address['PublicIp']
                break
            
        print(elastic_ip)
    
    
        for status in statuses['InstanceStatuses']:
            state = status['InstanceState']['Name']
            if state == "running":
                # Associate the Elastic IP with the specified running instance
                ec2_client.associate_address(InstanceId=status['InstanceId'], PublicIp=elastic_ip)
                print(f"Associated Elastic IP {elastic_ip} with Instance ID {status['InstanceId']}")
            print(f"Instance {status['InstanceId']} is {state}")
    
    check_instance_status()
