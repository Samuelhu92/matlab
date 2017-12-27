function [groupret] = DailyReturn(database,group,datelength)
databasename = 'testdb';
username = 'wind';
password = 'password';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';
% 连接database
conn = database(databasename,username,password,driver,url)

groupret = cell(group+1,datelength);
groupret(1,:) = database(1,:);
for col = 1:datelength
    data = yoy_300{2,col};
    if strcmp(data,'No Data') == 1
        continue
    end
    collection = sortrows(cell2table(yoy_300{2,col}),3,'descend');
    s = size(collection);
    groupsize = fix(s(1)/10);
    datestart = datestr(groupret{1,col},'YYYYmmdd');
    dateend = datestr(groupret{1,col+1},'YYYYmmdd');
    for row = 2:11
        temp = {};
        accre = {};
        X = ['正在处理第',num2str(col),'期,第',num2str(row-1),'组'];
        disp(X)
        start = (row-2)*groupsize+1;
        stop = (row-1)*groupsize;
        secidlist = table2array(collection(start:stop,1));
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
            result{2,i} = ret_vec(i);
        end
        groupret{row,col} = result;
    end
end