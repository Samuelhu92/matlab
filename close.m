databasename = 'testdb';
username = 'wind';
password = 'password';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';

% 连接database
conn = database(databasename,username,password,driver,url)
curs = exec(conn,'set auotocommit = 0')
% 创建日行情表
curs = exec(conn, 'DROP TABLE IF EXISTS stockprice')
curs = exec(conn, 'CREATE TABLE stockprice ( secid VARCHAR(20) NOT NULL,tradedate INTEGER,close DOUBLE,open DOUBLE,high DOUBLE,low DOUBLE,amt DOUBLE)' )

tablesize = size(close);


for stk = a:b
    secid = close{stk,1};
    for period = 3:tablesize(2)
        completion = ((stk-a)*tablesize(2)+(period-1))/para;
        if round(completion) == completion
            X = ['已完成%',num2str(completion),'。'];
            disp(X)
        end
        closeprice = close{stk,period};
        if isempty(closeprice) == 1
            continue
        end
        date = datenum(datetime(close{1,period},'ConvertFrom','excel'));
        insert(conn,'stockprice',{'secid','tradedate','close'},{secid,date,closeprice});
    end
end
close(conn);