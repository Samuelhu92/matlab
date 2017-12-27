function [groupret] = DailyRet(datatable,group,datelength,hedge_data,hedge_times)

databasename = 'testdb';
username = 'wind';
password = 'password';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';
% 连接database
conn = database(databasename,username,password,driver,url)

groupret = cell(group+1,datelength);
groupret(1,:) = datatable(1,:);
for col = 1:datelength-1
    data = datatable{2,col};
    if strcmp(data,'No Data') == 1
        continue
    end
    collection = sortrows(cell2table(datatable{2,col}),4,'ascend');
    s = size(collection);
    groupsize = fix(s(1)/group);
    datestart = datestr(groupret{1,col},'YYYYmmdd');
    dateend = datestr(groupret{1,col+1},'YYYYmmdd');
    sql = ['SELECT tradedate FROM closeF WHERE tradedate BETWEEN ''',datestart,''' AND ''',dateend,''' group by tradedate'];
    curs = exec(conn,sql);
    data = fetch(curs);
    datelist = data.Data;
    for row = 2:group+1
        temp = {};
        X = ['正在处理第',num2str(col),'期,第',num2str(row-1),'组'];
        disp(X)
        start = (row-2)*groupsize+1;
        stop = (row-1)*groupsize;
        secidlist = table2array(collection(start:stop,1));
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
            result{2,i} = ret_vec(i)-0.5*ret_300(i);
        end
        groupret{row,col} = result;
    end
end