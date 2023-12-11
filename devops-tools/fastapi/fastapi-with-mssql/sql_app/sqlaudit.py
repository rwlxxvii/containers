import os
import pyodbc

SERVER = '<server-address>'
DATABASE = '<database-name>'
USERNAME = '<username>'
PASSWORD = '<password>'

connectionString = f'DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};UID={USERNAME};PWD={PASSWORD};Trusted_Connection=yes;'

conn = pyodbc.connect(connectionString)

# place sql file in this directory or change directory
inputdir = 'C:\Users\Public\sqlaudit'

for script in os.listdir(inputdir):
    with open(inputdir+'\\' + script,'r') as inserts:
        sqlScript = inserts.read()
        for statement in sqlScript.split(';'):
            with conn.cursor() as cur:
                cur.execute(statement)
    print(script)

conn.close()