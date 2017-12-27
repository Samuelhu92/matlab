databasename = 'testdb';
username = 'wind';
password = 'password';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';
% 连接database
conn = database(databasename,username,password,driver,url)

% 建立年度三个换仓期满足条件股票的数据元祖
% 创建时间表头
yoy = {};
Y = (2006:2016);
M = [4,8,10];
n=1;
for a=1:length(Y)
    y = Y(a);
    for b=1:length(M)
        m = M(b);
        switch(m)
            case 4
                d=29;
            case 8
                d=29;
            case 10
                d=29;
        end
        yoy{1,n}=datetime(y,m,d);
        n=n+1;
    end
end
%对于每一个换仓节点在数据库中搜索满足条件的股票，并返回其代码。对所有时间节点进行遍历，结果储存在table中。
for period=1:33
    X = ['正在搜索第',num2str(period),'期'];
    disp(X)
    y_temp = year(yoy{1,period});
    m_temp = month(yoy{1,period});
    switch(m_temp)
        case 4
            m_temp = '03';
            d_temp = 30;
        case 8
            m_temp = '06';
            d_temp = 30;
        case 10
            m_temp = '09';
            d_temp = 30;
    end
    switchdate = int2str(datenum(yoy{1,period}));
    rptwindow = [int2str(y_temp),m_temp,int2str(d_temp)];
    sql = [' SELECT i.secid as secid, i.rptwindow as rptwindow,k.rptwindow as rptwindowprev ,i.yoyprofit-k.yoyprofit as delta FROM yoyprofit i INNER JOIN yoyprofit k ON i.secid=k.secid AND i.yoyprofit > k.yoyprofit AND i.yoyprofit > 20 AND i.yoyprofit < 100 AND k.yoyprofit > 0 AND i.rptwindow=DATE_ADD(k.rptwindow,INTERVAL 1 QUARTER) INNER JOIN ipodate l ON i.secid = l.secid AND l.ipodate < ''20160101'' WHERE i.rptwindow=',rptwindow,' AND i.date <= ',switchdate,''];
    curs = exec(conn,sql);
    data = fetch(curs);
    data = data.Data;
    if iscell(data)==1
        yoy{2,period} = data;
    else
        continue
    end
end
%创建所有股票在选择节点操作表，1表示持有，0表示不持有。
curs = exec(conn,'SELECT secid from ipodate')
secidlist = fetch(curs);
secidlist = secidlist.Data;
rows = length(secidlist)+1;
cols = 45;
hold = cell(rows,cols);
hold(:) = {0};

%建立secid列
for row=2:rows
    secid = secidlist{row-1,1};
    hold{row,1} = secid;
end
%建立date行
for col=2:cols
    date = yoy{1,col-1};
    hold{1,col} = date;
end
for col = 2:cols
    X=yoy{2,col-1};
    if strcmp(X,'No Data')==0
        for i=1:length(X)
            target = X{i,1};
            f=find(strcmp(hold(:,1),target));
            hold{f,col}=1;
        end
    else
        continue
    end
end






        

