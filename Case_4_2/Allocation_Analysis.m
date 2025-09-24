addpath("../Allocation_Function/");
fg=Binary_List(3);
Actual_Output=[2000,5000,250];
Bidding=[3047.75,5618.25,146];
Matrix=zeros(8,1);
Profit=zeros(8,1);
Time_Record=zeros(8,1);
mu_1=binvar(1,1);
Preal=sdpvar(1,1);
Pda=sdpvar(1,1);
M=100000;
for i=2:8
    tic
    fn=fg(i,:);
    F=[];
    F=[F Preal<=sum(Actual_Output.*fn)];
    F=[F Pda==sum(Bidding.*fn)];
    F=[F Preal<=1.3*Pda];
    F=[F Preal-0.8*Pda>=-M*(1-mu_1)];
    F=[F Preal<=M*mu_1];
    Output=sum(Actual_Output.*fn);
    bid_quantity=sum(Bidding.*fn);
    opf=3.5*Preal;
    ops=sdpsettings('solver','gurobi');
    output=optimize(F,-opf,ops);
    Profit(i)=double(opf);
    % if Output<bid_quantity*0.8
    %     Matrix(i)=0;
    % elseif  Output> bid_quantity*1.3
    %     Matrix(i)=bid_quantity*1.3*3.5;
    % else
    %    Matrix(i)=Output*3.5;
    % end
    Time_Record(i)=toc;
end
Matrix_1=[fg,Profit];
Matrix_time=[fg,Time_Record];
Solution_1=Operator_2(Matrix_1); 
tic
Shapley_Solution=compute_shapley(Solution_1);
Shapley_time=toc;
tic
Equal_DP_Solution=compute_dp(Solution_1);
Equal_time=toc;
tic
Least_core_solution=compute_Least_Core(Solution_1);
Least_time=toc;
Proportion_solution=compute_Proportional(Solution_1);
tic
Nucleolus_solution=compute_Nucleolus(Solution_1);
Nucleolus_time=toc;
Fixed_Ratio=[3806.25	5950	14875	743.75];
Test1=Shapley_Solution-Equal_DP_Solution;
DP_Analysis_Equal_DP=propensity_chat(Solution_1,Equal_DP_Solution);
DP_Analysis_Shapley=propensity_chat(Solution_1,Shapley_Solution);
DP_Analysis_Least_Core=propensity_chat(Solution_1,Least_core_solution);
DP_Analysis_Proportion=propensity_chat(Solution_1,Proportion_solution);
DP_Analysis_Fixed_Ratio=propensity_chat(Solution_1,Fixed_Ratio);
DP_Analysis_Nucleolus=propensity_chat(Solution_1,Nucleolus_solution);


