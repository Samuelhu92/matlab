function [netvalue] = PFnet(retdata,group,datelength)
for row = 2:group+1
    n = 1;
    net = 1;
    for col = 2:datelength
        X = ['���ڲ�����',num2str(row-1),'���',num2str(col),'��'];
        disp(X)
        data = retdata{row,col};
        s = size(data);
        for i = 1:s(2)
            net = net*(1+data{2,i});
            netvalue{row,n} = net;
            netvalue{1,n} = data{1,i};
            n = n+1;
        end
    end
end
end
        