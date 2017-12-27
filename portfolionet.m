
for row = 2:11
    n = 1;
    net = 1;
    for col = 2:33
        X = ['正在操作第',num2str(row-1),'组第',num2str(col),'期'];
        disp(X)
        data = groupret{row,col};
        s = size(data);
        for i = 1:s(2)
            data_daily = data(:,i);
            date = data_daily{1};
            date = strsplit(date,' ');
            date = date{1};
            net = net*(1+data_daily{2});
            netvalue{row,n} = net;
            netvalue{1,n} = date;
            n = n+1;
        end
    end
end
        