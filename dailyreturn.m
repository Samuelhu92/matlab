
databasename = 'testdb';
username = 'wind';
password = 'password';
driver = 'com.mysql.jdbc.Driver';
url = 'jdbc:mysql://localhost:3306/testdb?characterEncoding=utf8&amp;useSSL=true&amp;socketFactory=com.mysql.jdbc.NamedPipeSocketFactory';
% 连接database
conn = database(databasename,username,password,driver,url)

groupret = cell(11,33);
groupret(1,:) = yoy(1,:);
for col = 1:33
    data = yoy{2,col};
    if strcmp(data,'No Data') == 1
        continue
    end
    collection = sortrows(cell2table(yoy{2,col}),3,'descend');
    s = size(collection);
    groupsize = fix(s(1)/10);
    n = 1;
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
        str = ['''',secidlist{1,1},''''];
        for i = 2:length(secidlist)
            str = strcat(str,',','''',secidlist{i,1},'''');
        end
        sql = ['SELECT secid,close,tradedate FROM close WHERE secid in (',str,')AND tradedate BETWEEN ''',datestart,''' AND ''',dateend,'''order by tradedate'];
        curs = exec(conn,sql);
        data = fetch(curs);
        data = data.Data;
        datelist = unique(data(:,3));
        temp(1,2:length(datelist)+1) = datelist;
        temp(2:length(secidlist)+1,1) = secidlist;
        for i = 1:length(data)
            positionx = find(strcmp(temp,data{i,1}));
            positiony = find(datenum(datelist)==datenum(data{i,3}))+1;
            temp{positionx,positiony} = str2double(data{i,2});
        end
        s = size(temp);
        %检查temp表如果价格有缺失则将上一期价格填补
        for r = 2:s(1)
            for c = 2:s(2)
                if isempty(temp{r,c}) == 1
                    temp{r,c} = temp{r,c-1};
                end
            end
        end
        %将temp表转换成收益率表
        for c = 2:s(2)-1
            ret = 0;
            for r = 2:s(1)
                temp{r,c} = (temp{r,c+1}-temp{r,c})/temp{r,c};
                ret = ret + temp{r,c};
            end
            accre{c} = ret;
        end
        result = struct('table',{temp},'accre',{accre});
        groupret{row,col} = result;
    end
end

        