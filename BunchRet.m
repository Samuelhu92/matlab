function [bunchret] = BunchRet(datatable,datelength,hedge_data,hedge_times)

databasename = 'testdb';
username = 'wind';
password = 'password';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';
% 连接database
conn = database(databasename,username,password,driver,url)

bunchret = cell(2,datelength);
bunchret(1,:) = datatable(1,:);
for col = 1:datelength-1
    data = datatable{2,col};
    if strcmp(data,'No Data') == 1
        continue
    end
    collection = sortrows(cell2table(datatable{2,col}),3,'ascend');
    datestart = datestr(bunchret{1,col},'YYYYmmdd');
    dateend = datestr(bunchret{1,col+1},'YYYYmmdd');
    temp = {};
    X = ['正在处理第',num2str(col),'期'];
    disp(X)
    secidlist = table2array(collection(:,1));
    sql = ['SELECT tradedate FROM closenew WHERE tradedate BETWEEN ''',datestart,''' AND ''',dateend,''' group by tradedate'];
    curs = exec(conn,sql);
    data = fetch(curs);
    datelist = data.Data;
    temp(1,2:length(datelist)+1) = datelist;
    temp(2:length(secidlist)+1,1) = secidlist;
    s_temp = size(temp);
    for i = 1:length(secidlist)
        secid = secidlist{i,1};
        sql = ['SELECT secid,close FROM closenew WHERE secid = ''',secid,'''AND tradedate BETWEEN ''',datestart,''' AND ''',dateend,''''];
        curs = exec(conn,sql);
        data = fetch(curs);
        data = data.Data;
        temp(i+1,2:s_temp(2)) = data(:,2);
    end
    start = find(hedge_times==datenum(datestart,'YYYYmmdd'));
    n = 1;
    while isempty(start) ==1
        start = find(hedge_times==datenum(datestart,'YYYYmmdd')+n);
        n = n+1;
    end
    stop = find(hedge_times==datenum(dateend,'YYYYmmdd'));
    m = 1;
    while isempty(stop) ==1
        stop = find(hedge_times==datenum(dateend,'YYYYmmdd')-m);
        m = m+1;
    end 
    price_300 = hedge_data(start:stop);
    price_300_d = diff(price_300);
    s_price_300_d = size(price_300_d);
    price_300 = price_300(1:s_price_300_d(1));
    ret_300 = price_300_d./price_300;
    tempnum = str2double(temp(2:s_temp(1),2:s_temp(2)));
    tempnum_d = diff(tempnum,1,2);
    s_temp_d = size(tempnum_d);
    tempnum = tempnum(:,1:s_temp_d(2));
    ret_mat = tempnum_d./tempnum;
    date = temp(1,2:s_temp_d(2)+1);
    ret_vec = mean(ret_mat,1,'omitnan');
    result = cell(2,s_temp_d(2));
    result(1,:) = date;
    for i = 1:length(date)
        result{2,i} = ret_vec(i)-ret_300(i);
    end
    bunchret{2,col} = result;
end
end