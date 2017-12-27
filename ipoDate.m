databasename = 'testdb';
username = 'root';
password = 'hsyhzhxf92';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';

% 连接database
conn = database(databasename,username,password,driver,url)
% 创建ipo时间表
curs = exec(conn, 'DROP TABLE IF EXISTS ipodate')
curs = exec(conn, 'CREATE TABLE ipodate ( secid VARCHAR(20) NOT NULL,ipodate DATETIME)' )

tablesize = size(ipoDate);
for stk=1:tablesize(1)
    secid = ipoDate{stk,1};
    ipodate = ipoDate{stk,3};
    insert(conn,'ipodate',{'secid','ipodate'},{secid,ipodate});
end
close(conn);

