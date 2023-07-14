import boto3
import socket
import time
import logging

# 日志记录器
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def connet(ip):
    for i in range(2):
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sc:
                sc.settimeout(10)
                if sc.connect_ex((ip, 443)) == 0:
                    sc.shutdown(socket.SHUT_RDWR)
                    return False
        except:
            pass
    return True

aws = []

with open('ec2.txt', 'r') as f:
    data = f.read().split('\n')
    for item in data:
        item = item.split(',')
        if len(item) > 3:
            try:
                client = boto3.client('ec2', region_name=item[2], aws_access_key_id=item[0], aws_secret_access_key=item[1])
                ids = {}
                for i in range(len(item) - 3):
                    response = client.describe_instances(InstanceIds=[item[i + 3]])
                    for reservation in response['Reservations']:
                        for instance in reservation['Instances']:
                            ids[instance['InstanceId']] = instance['PublicIpAddress']
                aws.append({'client': client, "ids": ids})
            except Exception as e:
                logger.error(e)

while True:
    for a in aws:
        for k, v in a['ids'].items():
            if not connet(v):
                logger.info(f"{k}, {v}, attempting to change ip")
                try:
                    response = a['client'].describe_addresses()
                    for address in response['Addresses']:
                        if address.get('InstanceId') == k:
                            a['client'].disassociate_address(AssociationId=address['AssociationId'])
                            a['client'].release_address(AllocationId=address['AllocationId'])
                except Exception as e:
                    logger.error(f"{k}, {e}")

                try:
                    new_address = a['client'].allocate_address(Domain='vpc')
                    a['client'].associate_address(InstanceId=k, AllocationId=new_address['AllocationId'])
                except Exception as e:
                    logger.error(f"{k}, {e}")

                try:
                    response = a['client'].describe_instances(InstanceIds=[k])
                    new_ip = response['Reservations'][0]['Instances'][0]['PublicIpAddress']
                    logger.info(f"{k}, {v} -> {new_ip}, ip change successful")
                    a["ids"][k] = new_ip
                except Exception as e:
                    logger.error(f"{k}, {e}, ip change failed")
            else:
                logger.info(f"{k}, {v}, connect success")
    time.sleep(3)
