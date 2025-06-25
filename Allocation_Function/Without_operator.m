function Output=Without_operator(Result_da,Result_mar,Result_rt,Parameter)
    fg=bin_listg1(5);
    K=size(Parameter.Load_f,2);
    P=Parameter.P;
    Profit_matrix_expected=zeros(32,6);
    Profit_matrix_expected(:,1:5)=fg;
    Profit_matrix_ex_post=zeros(32,6,K);
    Profit_matrix_mar=zeros(32,6,K);
    for j=1:K
        Profit_matrix_ex_post(:,1:5,j)=fg;
        Profit_matrix_mar(:,1:5,j)=fg;
    end
    Allocate_matrix_mid=zeros(5,K);
    Marginal_mid=zeros(5,K);
    Ind_mid=zeros(5,K);
    Mar_mid=zeros(5,K);
    Allocate_matrix_1=zeros(5,K);
    Allocate_matrix=zeros(5,K);
    Ex_post_Allocation_matrix_DP=zeros(5,K);
    Ex_post_Allocation_matrix_Shapley=zeros(5,K);
    Dev_vector=zeros(1,K);
    Surplus=zeros(5,K);
    for i=2:32
        Profit_matrix_expected(i,6)=Result_da(i).f;
        for j=1:K
            Profit_matrix_ex_post(i,6,j)=Result_rt(i,j).f;
            Profit_matrix_mar(i,6,j)=Result_mar(i,j).f;
        end
    end
    Output=struct;
    Output.Profit_matrix_marginal=Profit_matrix_mar;
    Output.Profit_matrix_expected=Profit_matrix_expected;
    Output.Profit_matrix_ex_post=Profit_matrix_ex_post;
end



