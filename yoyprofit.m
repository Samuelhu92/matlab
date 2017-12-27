databasename = 'testdb';
username = 'root';
password = 'hsyhzhxf92';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';

% 连接database
conn = database(databasename,username,password,driver,url)
% 创建公报日期表
curs = exec(conn, 'DROP TABLE IF EXISTS yoyprofit')
curs = exec(conn, 'CREATE TABLE yoyprofit ( secid VARCHAR(20) NOT NULL,rptwindow DATETIME,yoyprofiit DOUBLE )' )

tablesize = size(yoyprofit);
for stk = 1:tablesize(1)
   secid = yoyprofit{stk,1};
   for period = 3:tablesize(2)
      X = ['正在入库第',stk,'只股票',secid,'第',period,'期'];
      disp(X)
       if isempty(yoyprofit{stk,period}) == 1
           continue
       else
            profit = datenum(yoyprofit{stk,period});
       end
       y = year(yoyprofit);
       reminder = mod((period-2),4);
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
       insert(conn,'rptdate',{'secid','rptwindow','date'},{secid,rptwindow,yoyprofit});
   end
end
close(conn);
               
       