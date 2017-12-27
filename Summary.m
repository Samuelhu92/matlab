function [conclusion] = Summary(netvalue,group)
conclusion = {group+1,6};
conclusion{1,1} = 'sharp_daily';
conclusion{1,2} = 'voletility_daily';
conclusion{1,3} = 'drawback';
conclusion{1,4} = 'sharp_quarter';
conclusion{1,5} = 'voletility_quarter';
conclusion{1,6} = 'annual return';
for i = 1:group
    r_quarter = {};
    data = cell2mat(netvalue(i+1,:));
    data_d = diff(data);
    %计算年化日度收益率对应的sharp ratio 和 波动率
    r = data_d./data(1:length(data_d));
    r_daily = r;
    std_r_daily = std(r_daily);
    var_r_daily = var(r_daily)*242;
    sharp_daily = (mean(r_daily)-0.03/242)/std_r_daily*(242^0.5);
    %计算最大回撤，第二回撤和第三回撤
    [h,w] = size(netvalue);
    dd = MaxDrawdown(data,1,w,3);
    %计算年化季度收益率对应的sharp ratio和波动率
    r = 1 + r;
    k = fix(length(r)/60);
    for j = 1:k
        rquarter =1;
        for q = (j-1)*60+1:j*60
            rquarter = rquarter*r(q);
        end
        r_quarter{j} = rquarter-1;
    end
    r_quarter = cell2mat(r_quarter);
    mean_r_quarter =mean(r_quarter);
    std_r_quarter = std(r_quarter);
    var_r_quarter = var(r_quarter)*4;
    sharp_quarter = (mean_r_quarter-0.03/4)/std_r_quarter*2;
    annual_r = ((data(w)-data(1))/data(1)+1)^0.1-1;
    conclusion{i+1,1} = sharp_daily;
    conclusion{i+1,2} = var_r_daily;
    conclusion{i+1,3} = dd;
    conclusion{i+1,4} = sharp_quarter;
    conclusion{i+1,5} = var_r_quarter;
    conclusion{i+1,6} = annual_r;
end
end

    
    