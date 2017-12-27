%连接database
databasename = 'testdb';
username = 'wind';
password = 'password';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';
conn = database(databasename,username,password,driver,url)

s = size(hold);
gaintable = cell(s(1)-1,1);
para = fix(s(1)*s(2)/100);
for sec = 2:s(1)
   secid = hold{sec,1};
   price_prv = 0.0;
   price_curr = 0.0;
   position = 0;
   gain = 0.0;
   sql = ['select ipodate from ipodate where secid = ''',secid,''''];
   curs = exec(conn,sql);
   data = fetch(curs);
   date = data.Data; 
   date = date{1};
   for period = 2:s(2)
       text = ['正在处理',secid,'股票第',num2str(period),'期'];
       disp(text)
       judgedate = datestr(hold{1,period},'YYYYmmdd');
       if date > datetime(judgedate,'format','yyyyMMdd')
           continue
       end
       sql = ['select close from close where secid = ''',secid,''' and tradedate= ''',judgedate,''''];
       curs = exec(conn,sql);
       data = fetch(curs);
       close = data.Data;
       n=0;
       while (strcmp(close{1},'No Data')) && n < 10
           judgedate = datestr(datetime(judgedate,'format','yyyyMMdd')+1,'YYYYmmdd');
           sql = ['select close from close where secid = ''',secid,''' and tradedate= ''',judgedate,''''];
           curs = exec(conn,sql);
           data = fetch(curs);
           close = data.Data;
           n = n + 1;
       end
       if strcmp(close{1},'No Data')
           continue
       end
       price_curr = str2double(close{1});
       if hold{sec,period}==0
           gain = gain + position*(price_curr-price_prv);
           position = 0;
           price_prv=price_curr;
       else
           gain = gain + position*(price_curr-price_prv);
           position = 1;
           price_prv = price_curr;
       end
   end
   gaintable{sec-1,1} = gain;
end

           