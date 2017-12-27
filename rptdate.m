databasename = 'testdb';
username = 'wind';
password = 'password';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';

% 连接database
conn = database(databasename,username,password,driver,url)
% 创建公报日期表
curs = exec(conn, 'DROP TABLE IF EXISTS yoyincome')
curs = exec(conn, 'CREATE TABLE yoyincome ( secid VARCHAR(20) NOT NULL,rptwindow DATETIME,date INTEGER, yoyincome DOUBLE )' )

tablesize = size(rptDate);
para = fix(tablesize(1)*tablesize(2)/100);

for stk = 1:tablesize(1)
   secid = rptDate{stk,1};
   if secid ~= yoyincome{stk,1}
       continue
   end
   for period = 3:tablesize(2)
       completion = ((stk-1)*tablesize(2)+(period-1))/para;
       if round(completion) == completion
           X = ['已完成%',num2str(completion),'。'];
           disp(X)
       end
       date = rptDate{stk,period};
       if isempty(date) == 1
           continue
       else
           date = datenum(date);
       end
       y = year(date);
       reminder = mod((period-2),4);
       switch reminder
           case 1
              rptwindow = datetime(y,3,30);
           case 2
               rptwindow = datetime(y,6,30);
           case 3
               rptwindow = datetime(y,9,30);
           case 0
               rptwindow = datetime(y-1,12,30);
       end
       income = yoyincome{stk,period};
       if isempty(income) == 1
           income = 0;
       end
       insert(conn,'yoyincome',{'secid','rptwindow','date','yoyincome'},{secid,rptwindow,date,income});
   end
end
close(conn);
               
       