function Least_Core=compute_Least_Core(matrix)
    [num_rows, num_cols] = size(matrix);
    num_mem=num_cols-1;
    fg=Binary_List(num_mem);
    Vn=matrix(num_rows,num_cols);%the total profit
    Vi=zeros(num_mem,1);
    Vn_i=zeros(num_mem,1);
    xi=sdpvar(num_mem,1);
    sigma=sdpvar(1,1);
    F=[];
    F=[F sum(xi)==Vn];
    F=[F fg(2:end-1,:)*xi+sigma>=matrix(2:end-1,end)];
    ops=sdpsettings('solver','gurobi');
    optimize(F,sigma,ops);
    sigma=double(sigma);
    Least_Core=double(xi);
end
