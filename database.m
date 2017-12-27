databasename = 'testdb';
username = 'root';
password = 'hsyhzhxf92';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=false';

% 连接database
conn = database(databasename,username,password,driver,url);
% 创建公报日期表
curs = exec(conn, 'DROP TABLE IF EXISTS rptdate');
curs = exec(conn, 'CREATE TABLE rptdate ( secid VARCHAR(20) NOT NULL,rptwindow VARCHAR(50),date VARCHAR(50) )' );

a = size(rptDate);
for stk = 1:a(1)
   secid = rptDate{stk,1};
   for period = 3:a(2)
       date = datenum(rptDate{stk,period));
       y = year(date)
       reminder = mod((period-2),4)
       switch reminder
           case 1
              rptwindow = datetime(y,3,31);
           case 2
               rptwindow = datetime(y,6,30);
           case 3
               rptwindow = datetime(y,9,30);
           case 0
               rptwindow = datetime(y,12,31);
       end
       insert(conn,'rptdate',{'secid','rptwindow','date'},{secid,rptwindow,date});
       commit(conn);
   end
end
          
               
       