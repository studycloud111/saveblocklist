# -*- coding: utf-8 -*-
import argparse
import requests
import time
import json
from aliyunsdkcore.client import AcsClient
from aliyunsdkalidns.request.v20150109 import DescribeDomainRecordsRequest, UpdateDomainRecordRequest

# 在这里填写你的 Access Key ID 和 Access Key Secret
access_key_id = 'LTAI5tE8E7PQSWRJKij4'
access_key_secret = 'aWuq0JtnKXt2jOvpMQDIKvo5uI'

# 在这里填写你的一级域名
domain_name = 'f89.com'


def update_dns(value, rr):
    client = AcsClient(access_key_id, access_key_secret, 'cn-hangzhou')

    request = DescribeDomainRecordsRequest.DescribeDomainRecordsRequest()
    request.set_DomainName(domain_name)
    request.set_accept_format('json')

    response = client.do_action_with_exception(request)
    response = json.loads(response.decode())  # decode bytes to str, then load str to dict

    records = response['DomainRecords']['Record']
    record = next((r for r in records if r['RR'] == rr), None)

    if record is None:
        print('Record not found.')
        return

    if record['Value'] == value:
        print('IP has not changed.')
        return

    request = UpdateDomainRecordRequest.UpdateDomainRecordRequest()
    request.set_RecordId(record['RecordId'])
    request.set_RR(rr)
    request.set_Type('A')
    request.set_Value(value)
    request.set_TTL(1)
    request.set_accept_format('json')

    client.do_action_with_exception(request)

    print('DNS record updated.')

def get_public_ip():
    urls = ['http://ifconfig.me/ip', 'https://api.ipify.org', 'https://ipecho.net/plain']
    for url in urls:
        try:
            response = requests.get(url, timeout=5)
            response.raise_for_status()
            return response.text.strip()
        except requests.RequestException:
            print(f"Failed to get IP from {url}. Trying another method...")
    raise Exception("Failed to get public IP from all methods.")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--rr", help="Specify the RR value of the domain.")
    args = parser.parse_args()

    while True:
        ip = get_public_ip()
        print('Current IP: %s' % ip)

        if args.rr:
            update_dns(ip, args.rr)
        else:
            print("No RR value provided. Use --rr to specify it.")

        time.sleep(10)

if __name__ == '__main__':
    main()
