from config import Config
import pymysql


# MySQL 연결
def get_db_connection():
    try:
        conn = pymysql.connect(
            host=Config.MYSQL_HOST,
            user=Config.MYSQL_USER,
            password=Config.MYSQL_PASSWORD,
            db=Config.MYSQL_DB,
            port=3306,
            charset='utf8'
        )
        return conn
    except pymysql.MySQLError as e:
        print(f"Error connecting to database: {e}")
        return None
