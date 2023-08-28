import requests
import pymysql
import time
import logging
import datetime
import argparse

def parse_args():
    parser = argparse.ArgumentParser(description="库存监控脚本")
    parser.add_argument("--db_host", default="127.0.0.1", help="数据库主机地址")
    parser.add_argument("--db_user", required=True, help="数据库用户名")
    parser.add_argument("--db_password", required=True, help="数据库密码")
    parser.add_argument("--db_name", required=True, help="数据库名称")
    parser.add_argument("--telegram_token", required=True, help="Telegram Token")
    parser.add_argument("--chat_id", required=True, help="Telegram 聊天 ID")
    parser.add_argument("--website", default="https://faka.99u.top/buy/", help="购买网址")
    parser.add_argument("--sleep_duration", type=int, default=10, help="休眠时间 (秒)")

    return parser.parse_args()

logging.basicConfig(level=logging.INFO)

conn = None
cursor = None
last_message_content = None
last_messages_info = {}
last_stock_info = {}

def ensure_db_connection(args):
    global conn, cursor
    if conn and conn.open:
        conn.close()
    conn = pymysql.connect(
        host=args.db_host,
        user=args.db_user,
        password=args.db_password,
        database=args.db_name
    )
    cursor = conn.cursor()

def get_current_stock(args):
    ensure_db_connection(args)
    query = """
        SELECT goods.id, goods.gd_name, COUNT(carmis.status) as status_count
        FROM goods
        LEFT JOIN carmis ON goods.id = carmis.goods_id
        WHERE carmis.status = 1
        GROUP BY goods.id, goods.gd_name
        HAVING
        status_count > 0;
    """
    cursor.execute(query)
    return {
        product[0]: {
            'id': product[0],
            'gd_name': product[1],
            'status_count': product[2]
        } for product in cursor.fetchall()
    }

def create_stock_message(current_stock, args):
    current_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    # 开始消息
    message = "🔔<b>库存实时通知</b>🔔\n"
    message += "🔷🔷🔷🔷🔷🔷🔷🔷\n"  # 使用蓝色钻石作为开头分隔线
    
    for product_id, data in current_stock.items():
        gd_name = data['gd_name']
        status_count = data['status_count']
        id = data['id']
        
        # 在一行内集中显示商品信息
        message += f"▪ 💼<b>{gd_name}</b> 📊<b>{status_count}</b>个\n🔗{args.website}{id}\n"
        message += "--------------------------\n"  # 商品间的分隔线
        
    # 更新时间
    message += f"⏰<i>最后更新时间:</i> {current_time}⏰\n"
    return message

def stock_increased(current_stock):
    global last_stock_info

    for product_id, data in current_stock.items():
        if product_id not in last_stock_info:
            return True
        if data['status_count'] > last_stock_info[product_id]['status_count']:
            return True

    return False

def send_telegram_message(args, message):
    url = f"https://api.telegram.org/bot{args.telegram_token}/sendMessage"
    payload = {
        'chat_id': args.chat_id,
        'text': message,
        'parse_mode': 'HTML'
    }
    response = requests.post(url, data=payload).json()
    return response

def delete_telegram_message(args, message_id):
    url = f"https://api.telegram.org/bot{args.telegram_token}/deleteMessage"
    payload = {
        'chat_id': args.chat_id,
        'message_id': message_id
    }
    response = requests.post(url, data=payload).json()
    return response

def hours_since_last_message():
    global last_messages_info

    if "timestamp" in last_messages_info:
        difference = datetime.datetime.now() - last_messages_info["timestamp"]
        return difference.total_seconds() / 3600
    return float('inf')

def main():
    global last_message_content, last_messages_info, last_stock_info
    args = parse_args()

    while True:
        logging.info("Starting new iteration...")
        current_stock = get_current_stock(args)
        logging.info(f"Current stock: {current_stock}")

        message = create_stock_message(current_stock, args)

        if stock_increased(current_stock):
            if last_messages_info and "message_id" in last_messages_info and hours_since_last_message() < 24:
                delete_telegram_message(args, last_messages_info["message_id"])
            
            response = send_telegram_message(args, message)
            if response.get("ok"):
                last_messages_info = {
                    "message_id": response["result"]["message_id"],
                    "timestamp": datetime.datetime.now()
                }
            last_message_content = message
        elif message != last_message_content and "message_id" in last_messages_info:
            url = f"https://api.telegram.org/bot{args.telegram_token}/editMessageText"
            payload = {
                'chat_id': args.chat_id,
                'message_id': last_messages_info["message_id"],
                'text': message,
                'parse_mode': 'HTML'
            }
            response = requests.post(url, data=payload).json()
            if response.get("ok"):
                last_messages_info["timestamp"] = datetime.datetime.now()
            last_message_content = message

        last_stock_info = current_stock

        logging.info(f"Sleeping for {args.sleep_duration} seconds...")
        time.sleep(args.sleep_duration)

if __name__ == "__main__":
    main()
