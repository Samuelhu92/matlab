function [ done ] = slicePriceInDB(table,tablesize,conn,para,start,stop)
%UNTITLED7 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
curs = exec(conn,'start transaction');
table = {};
for stk = start:stop
    para = fix((stop-start+1)*tablesize(2)/100);
    secid = table{stk,1};
    for period = 3:tablesize(2)
        completion = ((stk-start)*tablesize(2)+(period-1))/para;
        if round(completion) == completion
            X = ['�����%',num2str(completion),'��'];
            disp(X)
        end
        closeprice = table{stk,period};
        if isempty(closeprice) == 1
            continue
        end
        date = datenum(datetime(table{1,period},'ConvertFrom','excel'));
        table = {
        insert(conn,'stockprice',{'secid','tradedate','close'},{secid,date,closeprice});
    end
end
done = 0;
return 
end

