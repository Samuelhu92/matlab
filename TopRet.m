function [top25ret] = TopRet(datatable,top,datelength,hedge_data,hedge_times)

databasename = 'testdb';
username = 'wind';
password = 'password';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';
% 连接database
conn = database(databasename,username,password,driver,url)

top25ret = cell(2,datelength);
top25ret(1,:) = datatable(1,:);
for col = 1:datelength-1
    a = datatable{2,col};
    if strcmp(a,'No Data') == 1
        continue
    end
    collection = sortrows(cell2table(datatable{2,col}),3,'descend');
    datestart = datestr(top25ret{1,col},'YYYYmmdd');
    dateend = datestr(top25ret{1,col+1},'YYYYmmdd');
    temp = {};
    X = ['正在处理第',num2str(col),'期'];
    disp(X)
    start = 1;
    if height(collection) < top
        top = height(collection);
    end
    stop = top;
    secidlist = table2array(collection(start:stop,1));
    sql = ['SELECT tradedate FROM closeF WHERE tradedate BETWEEN ''',datestart,''' AND ''',dateend,''' group by tradedate'];
    curs = exec(conn,sql);
    data = fetch(curs);
    datelist = data.Data;
    temp(1,2:length(datelist)+1) = datelist;
    temp(2:length(secidlist)+1,1) = secidlist;
    s_temp = size(temp);
    for i = 1:length(secidlist)
        secid = secidlist{i,1};
        sql = ['SELECT secid,close FROM closeF WHERE secid = ''',secid,'''AND tradedate BETWEEN ''',datestart,''' AND ''',dateend,''''];
        curs = exec(conn,sql);
        data = fetch(curs);
        data = data.Data;
        temp(i+1,2:s_temp(2)) = data(:,2);
    end
    for d = 2:s_temp(2)
        position = hedge_times == datenum(temp{1,d});
        price_300(d-1) = hedge_data(position);
    end
    price_300_d = diff(price_300);
    s_price_300_d = size(price_300_d);
    price_300 = price_300(1:s_price_300_d(2));
    ret_300 = price_300_d./price_300;
    tempnum = str2double(temp(2:s_temp(1),2:s_temp(2)));
    [m,~] = find(isnan(tempnum(:,1)));
    tempnum(m,:) = [];
    tempnum_d = diff(tempnum,1,2);
    s_temp_d = size(tempnum_d);
    tempnum = tempnum(:,1:s_temp_d(2));
    ret_mat = tempnum_d./tempnum;
    [l,~] = find(ret_mat(:,1)==0);
    for i =1:length(l)
        if (ret_mat(i,2)==0) && (ret_mat(i,3)==0) && (ret_mat(i,4)==0) && (ret_mat(i,5)==0)
            ret_mat(l,:) = [];
        end
    end
    [p,~] = find(ret_mat>0.11);
    ret_mat(p,:) = [];
    date = temp(1,2:s_temp_d(2)+1);
    ret_vec = mean(ret_mat,1,'omitnan');
    ret_vec(1) = ret_vec(1)-0.0005;
    ret_vec(end) = ret_vec(end)-0.001;
    result = cell(2,s_temp_d(2));
    result(1,:) = date;
    for i = 1:length(date)
        result{2,i} = ret_vec(i)-ret_300(i);
    end
    top25ret{2,col} = result;
end
end