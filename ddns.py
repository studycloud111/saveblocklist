import argparse
import requests
import time
import json
import logging
from aliyunsdkcore.client import AcsClient
from aliyunsdkalidns.request.v20150109 import DescribeDomainRecordsRequest, UpdateDomainRecordRequest

# Configure logging
logging.basicConfig(level=logging.INFO)

# 在这里填写你的 Access Key ID 和 Access Key Secret
access_key_id = 'LTAI7PQSWRJKij4'
access_key_secret = 'aWuq0Ykt2jOvpMQDIKvo5uI'

# 在这里填写你的一级域名
domain_name = 'f3456789.com'

# 在这里填写你的 Telegram Bot Token 和 Chat ID
telegram_bot_token = '5835341AAEAmunoXdJK8towiUTsUYJTnHLtIResrxA'
telegram_chat_id = '1701890'

def send_telegram_message(message):
    url = f"https://api.telegram.org/bot{telegram_bot_token}/sendMessage"
    data = {"chat_id": telegram_chat_id, "text": message}

    try:
        response = requests.post(url, data=data)
        response.raise_for_status()
    except requests.RequestException as e:
        logging.error(f"Failed to send Telegram message: {e}")


def update_dns(value, rr):
    try:
        client = AcsClient(access_key_id, access_key_secret, 'cn-hangzhou')

        request = DescribeDomainRecordsRequest.DescribeDomainRecordsRequest()
        request.set_DomainName(domain_name)
        request.set_accept_format('json')

        response = client.do_action_with_exception(request)
        response = json.loads(response.decode())  # decode bytes to str, then load str to dict

        records = response['DomainRecords']['Record']
        record = next((r for r in records if r['RR'] == rr), None)

        if record is None:
            logging.warning('Record not found.')
            return

        if record['Value'] == value:
            logging.info('IP has not changed.')
            return

        request = UpdateDomainRecordRequest.UpdateDomainRecordRequest()
        request.set_RecordId(record['RecordId'])
        request.set_RR(rr)
        request.set_Type('A')
        request.set_Value(value)
        request.set_TTL(1)
        request.set_accept_format('json')

        client.do_action_with_exception(request)
        logging.info('DNS record updated.')
        send_telegram_message(f'DNS record for {rr}.{domain_name} updated. New IP: {value}')
    except Exception as e:
        logging.error(f"Failed to update DNS: {e}")
        send_telegram_message(f"Failed to update DNS: {e}")


def get_public_ip():
    urls = ['http://ifconfig.me/ip', 'https://api.ipify.org', 'https://ipecho.net/plain']
    for url in urls:
        try:
            response = requests.get(url, timeout=5)
            response.raise_for_status()
            return response.text.strip()
        except requests.RequestException:
            logging.warning(f"Failed to get IP from {url}. Trying another method...")
    raise Exception("Failed to get public IP from all methods.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--rr", help="Specify the RR value of the domain.")
    args = parser.parse_args()

    while True:
        try:
            ip = get_public_ip()
            logging.info(f'Current IP: {ip}')

            if args.rr:
                update_dns(ip, args.rr)
            else:
                logging.error("No RR value provided. Use --rr to specify it.")
        except Exception as e:
            logging.error(f"An error occurred: {e}")

        time.sleep(10)


if __name__ == '__main__':
    main()import argparse
import requests
import time
import json
import logging
from aliyunsdkcore.client import AcsClient
from aliyunsdkalidns.request.v20150109 import DescribeDomainRecordsRequest, UpdateDomainRecordRequest

# Configure logging
logging.basicConfig(level=logging.INFO)

# 在这里填写你的 Access Key ID 和 Access Key Secret
access_key_id = 'LTAI5tE8E6TT67PQSWRJKij4'
access_key_secret = 'aWuq0JtnKXZKYkt2jOvpMQDIKvo5uI'

# 在这里填写你的一级域名
domain_name = 'fscloud123456789.com'

# 在这里填写你的 Telegram Bot Token 和 Chat ID
telegram_bot_token = '5835341964:AAEAmunoXdJK8towiUTsUYJTnHLtIResrxA'
telegram_chat_id = '1701091890'

def send_telegram_message(message):
    url = f"https://api.telegram.org/bot{telegram_bot_token}/sendMessage"
    data = {"chat_id": telegram_chat_id, "text": message}

    try:
        response = requests.post(url, data=data)
        response.raise_for_status()
    except requests.RequestException as e:
        logging.error(f"Failed to send Telegram message: {e}")


def update_dns(value, rr):
    try:
        client = AcsClient(access_key_id, access_key_secret, 'cn-hangzhou')

        request = DescribeDomainRecordsRequest.DescribeDomainRecordsRequest()
        request.set_DomainName(domain_name)
        request.set_accept_format('json')

        response = client.do_action_with_exception(request)
        response = json.loads(response.decode())  # decode bytes to str, then load str to dict

        records = response['DomainRecords']['Record']
        record = next((r for r in records if r['RR'] == rr), None)

        if record is None:
            logging.warning('Record not found.')
            return

        if record['Value'] == value:
            logging.info('IP has not changed.')
            return

        request = UpdateDomainRecordRequest.UpdateDomainRecordRequest()
        request.set_RecordId(record['RecordId'])
        request.set_RR(rr)
        request.set_Type('A')
        request.set_Value(value)
        request.set_TTL(1)
        request.set_accept_format('json')

        client.do_action_with_exception(request)
        logging.info('DNS record updated.')
        send_telegram_message(f'DNS record for {rr}.{domain_name} updated. New IP: {value}')
    except Exception as e:
        logging.error(f"Failed to update DNS: {e}")
        send_telegram_message(f"Failed to update DNS: {e}")


def get_public_ip():
    urls = ['http://ifconfig.me/ip', 'https://api.ipify.org', 'https://ipecho.net/plain']
    for url in urls:
        try:
            response = requests.get(url, timeout=5)
            response.raise_for_status()
            return response.text.strip()
        except requests.RequestException:
            logging.warning(f"Failed to get IP from {url}. Trying another method...")
    raise Exception("Failed to get public IP from all methods.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--rr", help="Specify the RR value of the domain.")
    args = parser.parse_args()

    while True:
        try:
            ip = get_public_ip()
            logging.info(f'Current IP: {ip}')

            if args.rr:
                update_dns(ip, args.rr)
            else:
                logging.error("No RR value provided. Use --rr to specify it.")
        except Exception as e:
            logging.error(f"An error occurred: {e}")

        time.sleep(10)


if __name__ == '__main__':
    main()import argparse
import requests
import time
import json
import logging
from aliyunsdkcore.client import AcsClient
from aliyunsdkalidns.request.v20150109 import DescribeDomainRecordsRequest, UpdateDomainRecordRequest

# Configure logging
logging.basicConfig(level=logging.INFO)

# 在这里填写你的 Access Key ID 和 Access Key Secret
access_key_id = 'LTAI5tE8E6TT67PQSWRJKij4'
access_key_secret = 'aWuq0JtnKXZKYkt2jOvpMQDIKvo5uI'

# 在这里填写你的一级域名
domain_name = 'fscloud123456789.com'

# 在这里填写你的 Telegram Bot Token 和 Chat ID
telegram_bot_token = '5835341964:AAEAmunoXdJK8towiUTsUYJTnHLtIResrxA'
telegram_chat_id = '1701091890'

def send_telegram_message(message):
    url = f"https://api.telegram.org/bot{telegram_bot_token}/sendMessage"
    data = {"chat_id": telegram_chat_id, "text": message}

    try:
        response = requests.post(url, data=data)
        response.raise_for_status()
    except requests.RequestException as e:
        logging.error(f"Failed to send Telegram message: {e}")


def update_dns(value, rr):
    try:
        client = AcsClient(access_key_id, access_key_secret, 'cn-hangzhou')

        request = DescribeDomainRecordsRequest.DescribeDomainRecordsRequest()
        request.set_DomainName(domain_name)
        request.set_accept_format('json')

        response = client.do_action_with_exception(request)
        response = json.loads(response.decode())  # decode bytes to str, then load str to dict

        records = response['DomainRecords']['Record']
        record = next((r for r in records if r['RR'] == rr), None)

        if record is None:
            logging.warning('Record not found.')
            return

        if record['Value'] == value:
            logging.info('IP has not changed.')
            return

        request = UpdateDomainRecordRequest.UpdateDomainRecordRequest()
        request.set_RecordId(record['RecordId'])
        request.set_RR(rr)
        request.set_Type('A')
        request.set_Value(value)
        request.set_TTL(1)
        request.set_accept_format('json')

        client.do_action_with_exception(request)
        logging.info('DNS record updated.')
        send_telegram_message(f'DNS record for {rr}.{domain_name} updated. New IP: {value}')
    except Exception as e:
        logging.error(f"Failed to update DNS: {e}")
        send_telegram_message(f"Failed to update DNS: {e}")


def get_public_ip():
    urls = ['http://ifconfig.me/ip', 'https://api.ipify.org', 'https://ipecho.net/plain']
    for url in urls:
        try:
            response = requests.get(url, timeout=5)
            response.raise_for_status()
            return response.text.strip()
        except requests.RequestException:
            logging.warning(f"Failed to get IP from {url}. Trying another method...")
    raise Exception("Failed to get public IP from all methods.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--rr", help="Specify the RR value of the domain.")
    args = parser.parse_args()

    while True:
        try:
            ip = get_public_ip()
            logging.info(f'Current IP: {ip}')

            if args.rr:
                update_dns(ip, args.rr)
            else:
                logging.error("No RR value provided. Use --rr to specify it.")
        except Exception as e:
            logging.error(f"An error occurred: {e}")

        time.sleep(10)


if __name__ == '__main__':
    main()
