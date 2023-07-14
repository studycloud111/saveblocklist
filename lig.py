import boto3
import socket
import time


def ip_starts_with_43(ip):
    return ip.startswith("43.")


def connet(ip):
    for i in  range(2):
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

with open('ydx.txt', 'r') as f:
    ydx = f.read().split('\n')
    for ydx in ydx:
        ydx = ydx.split(',')
        if len(ydx) > 3:
            try:
                client = boto3.client('lightsail', region_name=ydx[2], aws_access_key_id=ydx[0],
                                      aws_secret_access_key=ydx[1])
                response = client.get_instances()
                ids = {}
                for i in range(len(ydx) - 3):
                    for instance in response['instances']:
                        if instance['name'] == ydx[i + 3]:
                            ids[instance['name']] = instance['publicIpAddress']
                aws.append({'client': client, "ids": ids})
            except Exception as e:
                print(e)

while True:
    for a in aws:
        for k, v in a['ids'].items():
            if not ip_starts_with_43(v) or connet(v):
                print(k, v, 'change ip')
                try:
                    a['client'].detach_static_ip(staticIpName=k + 'ipv4')
                except Exception as e:
                    print(k, e)

                try:
                    a['client'].release_static_ip(staticIpName=k + 'ipv4')
                except Exception as e:
                    print(k, e)

                try:
                    a['client'].allocate_static_ip(staticIpName=k + 'ipv4')
                except Exception as e:
                    print(k, e)

                try:
                    a['client'].attach_static_ip(
                        staticIpName=k + 'ipv4', instanceName=k)
                except Exception as e:
                    print(k, e)

                try:
                    response = a['client'].get_instance(instanceName=k)
                    print(k, v, "->", response['instance']['publicIpAddress'], 'change ip success')
                    a["ids"][k] = response['instance']['publicIpAddress']
                except Exception as e:
                    print(k, e, "change ip fail")
            else:
                print(k, v, 'connect success')
    time.sleep(60)
import boto3
import socket
import time


def ip_starts_with_43(ip):
    return ip.startswith("43.")


def connet(ip):
    for i in  range(2):
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

with open('ydx.txt', 'r') as f:
    ydx = f.read().split('\n')
    for ydx in ydx:
        ydx = ydx.split(',')
        if len(ydx) > 3:
            try:
                client = boto3.client('lightsail', region_name=ydx[2], aws_access_key_id=ydx[0],
                                      aws_secret_access_key=ydx[1])
                response = client.get_instances()
                ids = {}
                for i in range(len(ydx) - 3):
                    for instance in response['instances']:
                        if instance['name'] == ydx[i + 3]:
                            ids[instance['name']] = instance['publicIpAddress']
                aws.append({'client': client, "ids": ids})
            except Exception as e:
                print(e)

while True:
    for a in aws:
        for k, v in a['ids'].items():
            if not ip_starts_with_43(v) or connet(v):
                print(k, v, 'change ip')
                try:
                    a['client'].detach_static_ip(staticIpName=k + 'ipv4')
                except Exception as e:
                    print(k, e)

                try:
                    a['client'].release_static_ip(staticIpName=k + 'ipv4')
                except Exception as e:
                    print(k, e)

                try:
                    a['client'].allocate_static_ip(staticIpName=k + 'ipv4')
                except Exception as e:
                    print(k, e)

                try:
                    a['client'].attach_static_ip(
                        staticIpName=k + 'ipv4', instanceName=k)
                except Exception as e:
                    print(k, e)

                try:
                    response = a['client'].get_instance(instanceName=k)
                    print(k, v, "->", response['instance']['publicIpAddress'], 'change ip success')
                    a["ids"][k] = response['instance']['publicIpAddress']
                except Exception as e:
                    print(k, e, "change ip fail")
            else:
                print(k, v, 'connect success')
    time.sleep(60)
