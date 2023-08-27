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
    parser.add_argument("--edit_window", type=int, default=6*3600, help="消息编辑窗口 (秒)")

    return parser.parse_args()

# 配置日志
logging.basicConfig(level=logging.INFO)

# 初始化数据库连接和游标
conn = None
cursor = None

# 上一次的消息内容和消息信息
last_message_content = None
last_messages_info = {}

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
    query = "SELECT `id`, `gd_name`, `in_stock` FROM `goods`"
    cursor.execute(query)
    return {
        product[0]: {
            'id': product[0],
            'gd_name': product[1],
            'in_stock': product[2]
        } for product in cursor.fetchall()
    }

def create_stock_message(current_stock, args):
    """为所有产品构建消息"""
    current_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    message = "🔊库存实时更新:\n\n"  # 开始的标题部分和额外的空行
    
    for product_id, data in current_stock.items():
        gd_name = data['gd_name']
        stock = data['in_stock']
        id = data['id']
        
        # 格式化每个库存信息
        message += f"☁️【{gd_name}】库存现有 <b>{stock}</b>个,👇\n💬   {args.website}{id}\n\n"
        
    message += f"⏰ 更新时间: {current_time}\n"
    return message

def send_telegram_message(args, message):
    url = f"https://api.telegram.org/bot{args.telegram_token}/sendMessage"
    payload = {
        'chat_id': args.chat_id,
        'text': message,
        'parse_mode': 'HTML'
    }
    response = requests.post(url, data=payload).json()
    return response

def main():
    global last_message_content, last_messages_info
    args = parse_args()

    while True:
        logging.info("Starting new iteration...")
        current_stock = get_current_stock(args)
        logging.info(f"Current stock: {current_stock}")

        message = create_stock_message(current_stock, args)

        # 判断是否需要编辑消息
        if message != last_message_content:
            if last_messages_info:
                # 编辑消息
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
            else:
                # 发送新消息
                response = send_telegram_message(args, message)
                if response.get("ok"):
                    last_messages_info = {
                        "message_id": response["result"]["message_id"],
                        "timestamp": datetime.datetime.now()
                    }
            # 更新上一次的消息内容
            last_message_content = message

        logging.info(f"Sleeping for {args.sleep_duration} seconds...")
        time.sleep(args.sleep_duration)

if __name__ == "__main__":
    main()
