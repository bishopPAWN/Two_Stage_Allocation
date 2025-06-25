function [out]=Binary_List(nsize)
%有序产生nsize位二进制码
n=2^nsize;               %矩阵的行数
w=zeros(n,nsize);        %产生结果矩阵
for m = 1:n              %二进制有序矩阵的产生
    w(m,:) = bitget(m-1,nsize:-1:1); 
end
out = w;
end