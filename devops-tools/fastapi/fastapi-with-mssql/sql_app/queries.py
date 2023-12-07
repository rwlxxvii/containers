import pyodbc
#import pymsmsql
"""
conn = pymssql.connect(
    server='<server-address>',
    user='<username>',
    password='<password>',
    database='<database-name>',
    as_dict=True
)
"""
SERVER = '<server-address>'
DATABASE = '<database-name>'
USERNAME = '<username>'
PASSWORD = '<password>'

connectionString = f'DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};UID={USERNAME};PWD={PASSWORD}'

conn = pyodbc.connect(connectionString)

SQL_QUERY = """
SELECT 
TOP 5 c.CustomerID, 
c.CompanyName, 
COUNT(soh.SalesOrderID) AS OrderCount 
FROM 
SalesLT.Customer AS c 
LEFT OUTER JOIN SalesLT.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID 
GROUP BY 
c.CustomerID, 
c.CompanyName 
ORDER BY 
OrderCount DESC;
"""

cursor = conn.cursor()
cursor.execute(SQL_QUERY)