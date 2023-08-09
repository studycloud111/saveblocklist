import boto3
import socket
import time
import json
import argparse
from aliyunsdkcore.client import AcsClient
from aliyunsdkalidns.request.v20150109 import DeleteDomainRecordRequest, AddDomainRecordRequest, \
    DescribeDomainRecordsRequest

# 初始化Aliyun客户端
ali_client = AcsClient('sdfsd4', 'aWsdfsdfsdf5uI', 'cn-hangzhou')
#参数
parser = argparse.ArgumentParser(description="Script to fetch record ID.")
parser.add_argument("--domain", type=str, required=True, help="Domain name")
parser.add_argument("--rr", type=str, required=True, help="Subdomain name")
parser.add_argument("--ttl", type=str,default=1, help="Value for the record")
parser.add_argument("--file", type=str, required=True, help="Value for the record")
parser.add_argument("--port", type=int, required=True, help="Value for the record")
args = parser.parse_args()


def get_all_records(domain, subdomain, record_type):
    request = DescribeDomainRecordsRequest.DescribeDomainRecordsRequest()
    request.set_DomainName(domain)
    response = ali_client.do_action_with_exception(request)
    all_records = json.loads(response)
    matched_records = [
        record for record in all_records.get('DomainRecords', {}).get('Record', [])
        if record.get('RR') == subdomain and record.get('Type') == record_type
    ]
    return matched_records
def ensure_only_my_ips(domain, subdomain, record_type, my_ips):
    # 获取所有与指定子域和记录类型匹配的记录
    records = get_all_records(domain, subdomain, record_type)

    to_delete = [record for record in records if record['Value'] not in my_ips]

    for record in to_delete:
        try:
            delete_record(record['RecordId'])
            print(f"Deleted record {record['RecordId']} with IP {record['Value']}.")
        except Exception as e:
            print(f"Error deleting record {record['RecordId']}: {e}")
def get_record_id(DomainName, RR, IP):
    request = DescribeDomainRecordsRequest.DescribeDomainRecordsRequest()
    request.set_DomainName(DomainName)
    response = ali_client.do_action_with_exception(request)
    records = json.loads(response.decode('utf-8'))
    for record in records['DomainRecords']['Record']:
        if record['RR'] == RR and record['Value'] == IP:
            return record['RecordId']
    return None


def delete_record(RecordId):
    request = DeleteDomainRecordRequest.DeleteDomainRecordRequest()
    request.set_RecordId(RecordId)
    ali_client.do_action_with_exception(request)


def add_record(DomainName, RR, Type, Value, TTL=600, Line='default'):
    request = AddDomainRecordRequest.AddDomainRecordRequest()
    request.set_DomainName(DomainName)
    request.set_RR(RR)
    request.set_Type(Type)
    request.set_Value(Value)
    request.set_TTL(TTL)
    request.set_Line(Line)
    ali_client.do_action_with_exception(request)


def connet(ip):
    for i in range(2):
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sc:
                sc.settimeout(10)
                if sc.connect_ex((ip, args.port)) == 0:
                    sc.shutdown(socket.SHUT_RDWR)
                    return False
        except:
            pass
    return True


aws = []

with open(args.file, 'r') as f:
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
                aws.append({'client': client, "ids": ids,'region_name': ydx[2]  # Add region_name to the dictionary
})
            except Exception as e:
                print(e)

while True:
    all_ips = []
    for a in aws:
        for k, v in a['ids'].items():
            all_ips.append(v)  # 收集所有的IP地址
            current_region = a['region_name']  # 获取当前的region_name
            print(current_region)
            if connet(v):
                print(k, v, 'change ip')
                # 获取阿里云解析记录的RecordId
                record_id = get_record_id(args.domain, args.rr, v)
                # 删除阿里云解析记录
                if record_id:
                    delete_record(record_id)
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
                    # 如果成功，添加新的阿里云解析记录
                    new_ip = response['instance']['publicIpAddress']
                    all_ips.append(new_ip)
                    all_ips.remove(v)
                    # 如果DNS记录中不存在这个IP，就添加新的解析记录
                    if get_record_id(args.domain, args.rr, new_ip) is None:
                        line = 'default'  # 默认线路
                        if a.get('region_name') == 'ap-northeast-1':  # 如果region_name是ap-northeast-1
                            line = 'unicom'  # 设置线路为联通
                        elif a.get('region_name') == 'ap-southeast-1':  # 如果region_name是ap-southeast-1
                            line = 'telecom'  # 设置线路为电信
                        add_record(args.domain, args.rr, 'A', new_ip, TTL=args.ttl)
                    a["ids"][k] = response['instance']['publicIpAddress']
                    print(k, v, "->", response['instance']['publicIpAddress'], 'adding DNS record and change ip success')
                except Exception as e:
                    print(k, e, "change ip fail")
            else:
                try:
                    is_resolved = get_record_id(args.domain, args.rr, v)
                    if not is_resolved:  # 如果IP没有解析
                        print(f"{k} {v} has not been resolved in DNS.")
                        try:
                            # 如果DNS记录中不存在这个IP，就添加新的解析记录
                            #   .  default：默认 telecom：中国电信 unicom：中国联通 mobile：中国移动
                            if get_record_id(args.domain, args.rr, v) is None:
                                line = 'default'  # 默认线路
                                if a.get('region_name') == 'ap-northeast-1':  # 如果region_name是ap-northeast-1
                                    line = 'unicom'  # 设置线路为联通
                                elif a.get('region_name') == 'ap-southeast-1':  # 如果region_name是ap-southeast-1
                                    line = 'telecom'  # 设置线路为电信
                                add_record(args.domain, args.rr, 'A', v, TTL=args.ttl)
                        except Exception as e:
                            print(k, e, "adding DNS record failed")
                    else:
                        print(f"{k} {v} is already resolved in DNS.")
                except Exception as e:
                    print(k, e, "error checking DNS resolution")
                print(k, v, 'connect success')
    print(all_ips)
    ensure_only_my_ips(args.domain, args.rr, 'A', all_ips)
    time.sleep(60)
