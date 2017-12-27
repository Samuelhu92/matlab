function [ re ] = MaxDrawdown(data,start,stop,n)
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
temp = [];
for i=start+1:stop
    value_i = data(i);
    [max_i,max_i_pos] = max(data(1:i-1));
    dd = (max_i-value_i)/max_i;
    temp{1,i} = max_i;
    temp{2,i} = i;
    temp{3,i} = dd;
    temp{4,i} = max_i_pos;
end
temp_max_uniq = unique(cell2mat(temp(1,:)));
temp_max = cell2mat(temp(1,:));
temp_pos = cell2mat(temp(2,:));
temp_dd = cell2mat(temp(3,:));
temp_max_pos = cell2mat(temp(4,:));
temp_result = [];
for j = 1:length(temp_max_uniq)
    list = find(temp_max==temp_max_uniq(j));
    [dd_max,dd_max_pos] = max(temp_dd(list));
    temp_result = [temp_result;dd_max,temp_max_pos(list(dd_max_pos)),temp_pos(list(dd_max_pos))];
end
[~,pos] =sort(temp_result(:,1),'descend');
re = [];
for i = 1:3
    result = temp_result(:,i);
    re = [re,result(pos(1:n))];
    result = [];
end
end

    

    