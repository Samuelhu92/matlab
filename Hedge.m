function [ret_hedge] = Hedge(retdata,group,percent,hedge_data,hedge_times)
ret_all = {};
n = 1;
s_ret = size(retdata);
for g = 2:s_ret(1);
    for i = 1:s_ret(2)
        data = retdata{2,i};
        s = size(data);
        for k = 1:s(2)
            ret_all{1,n} = data{1,k};
            ret_all{2,n} = data{2,k};
            n =n+1;
        end
    end
s_all = size(ret_all);
for d = 1:s_all(2)
    position = hedge_times == datenum(ret_all{1,d});
    price_300(d) = hedge_data(position);
end
price_300_d = diff(price_300);
s_price_300_d = size(price_300_d);
price_300 = price_300(1:s_price_300_d(2));
ret_300 = price_300_d./price_300;

        
    