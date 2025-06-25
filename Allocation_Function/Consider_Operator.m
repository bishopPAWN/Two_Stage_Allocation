function Output= Consider_Operator(Result_da,Result_mar,Result_rt,Input,Parameter)
    fg=bin_listg1(6);
    K=size(Parameter.Load_f,2);
    Chart_two_stage=zeros(5,6,K);
    Chart_dp=zeros(5,6,K);
    Chart_shapley=zeros(5,6,K);
    DP_two_stage=zeros(6,K);
    DP_shapley=zeros(6,K);
    DP_ex_post=zeros(6,K);
    P=Parameter.P;
    Profit_matrix_expected=zeros(32,7);
    Profit_matrix_ex_post=zeros(64,7,K);
    Allocate_matrix_mid=zeros(6,K);
    Profit_final_expected=zeros(64,7);
    Marginal_mid=zeros(6,K);
    Ind_mid=zeros(6,K);
    Mar_mid=zeros(6,K);
    Test_11=zeros(6,K);
    Allocate_matrix_1=zeros(6,K);
    Allocate_matrix=zeros(6,K);
    Ex_post_Allocation_matrix_DP=zeros(6,K);
    Ex_post_Allocation_matrix_Shapley=zeros(6,K);
    Ex_post_Allocation_matrix_Least_Core=zeros(6,K);
    Ex_post_Allocation_matrix_Proportional=zeros(6,K);
    Dev_vector=zeros(1,K);
    Surplus=zeros(6,K);
    Ind_contri_excepted=zeros(6,1);
    Profit_matrix_expected=Operator_2(Input.Profit_matrix_expected);
    for i=1:K
        Profit_matrix_ex_post(:,:,i)=Operator_2(Input.Profit_matrix_ex_post(:,:,i));
    end
    for j=1:K
        Ex_post_Allocation_matrix_DP(:,j)=compute_dp(Profit_matrix_ex_post(:,:,j))';
        Ex_post_Allocation_matrix_Shapley(:,j)=compute_shapley(Profit_matrix_ex_post(:,:,j))';
        Ex_post_Allocation_matrix_Least_Core(:,j)=compute_Least_Core(Profit_matrix_ex_post(:,:,j))';
        Ex_post_Allocation_matrix_Proportional(:,j)=compute_Proportional(Profit_matrix_ex_post(:,:,j))';
    end
    Fixed_Ratio_allocation=Proportion_Record(Result_da,Result_rt,Parameter);
    Solution_1=compute_dp(Profit_matrix_expected);
    Chart=propensity_chat(Profit_matrix_expected,Solution_1);
    DP_expected=Chart(5,1);%日前的DP值情况
    Ind_dp=DP_expected/(1+DP_expected);
    Mar_dp=1/(1+DP_expected);
    for j=1:K
        for i=1:6
        Ind_mid(i,j)=Ind_dp*(Profit_matrix_ex_post(2^(i-1)+1,7,j));
        Mar_mid(i,j)=Mar_dp*(Profit_matrix_ex_post(64,7,j)-Profit_matrix_ex_post(64-2^(i-1),7,j));
        Allocate_matrix_mid(i,j)=Ind_mid(i,j)+Mar_mid(i,j);
        Test_11(i,j)=Profit_matrix_ex_post(64,7,j)-Profit_matrix_ex_post(64-2^(i-1),7,j)-Profit_matrix_ex_post(2^(i-1)+1,7,j);
        end
        Dev_vector(1,j)=Result_rt(32,j).f-sum(Allocate_matrix_mid(:,j));
        
        for k=1:5
            Surplus(k,j)=Result_mar(32,j).f-Result_mar(32-2^(k-1),j).f-Result_mar(2^(k-1)+1,j).f;
        end
        Surplus(6,j)=Result_mar(32,j).f;
        for k=1:5
            Surplus(6,j)=Surplus(6,j)-Result_mar(2^(k-1)+1,j).f;
        end
        for ii=1:6
            Allocate_matrix_1(ii,j)=Allocate_matrix_mid(ii,j)+Dev_vector(1,j)*Surplus(ii,j)/sum(Surplus(:,j));
        end
    end
    for k=1:6
        Allocate_matrix(7-k,:)=Allocate_matrix_1(k,:);
    end
    for j=1:K
        Chart_two_stage(:,:,j)=propensity_chat(Profit_matrix_ex_post(:,:,j),Allocate_matrix(:,j));
        Chart_dp(:,:,j)=propensity_chat(Profit_matrix_ex_post(:,:,j),Ex_post_Allocation_matrix_DP(:,j));
        Chart_shapley(:,:,j)=propensity_chat(Profit_matrix_ex_post(:,:,j),Ex_post_Allocation_matrix_Shapley(:,j));
        Chart_Least_core(:,:,j)=propensity_chat(Profit_matrix_ex_post(:,:,j),Ex_post_Allocation_matrix_Least_Core(:,j));
        Chart_Proportional(:,:,j)=propensity_chat(Profit_matrix_ex_post(:,:,j),Ex_post_Allocation_matrix_Proportional(:,j));
        Chart_Fixed_Ratio(:,:,j)=propensity_chat(Profit_matrix_ex_post(:,:,j),Fixed_Ratio_allocation(:,j));
    end
    for j=1:K
        DP_two_stage(:,j)=Chart_two_stage(5,:,j)';
        DP_shapley(:,j)=Chart_shapley(5,:,j)';
        DP_ex_post(:,j)=Chart_dp(5,:,j)';
        DP_least(:,j)=Chart_Least_core(5,:,j)';
        DP_proportional(:,j)=Chart_Proportional(5,:,j)';
        DP_fixed_ratio(:,j)=Chart_Fixed_Ratio(5,:,j)';
    end
    %%考虑期望上的事情
    Vector=0;
    for j=1:K
        Vector=Vector+Profit_matrix_ex_post(:,7,j)*P(j);
    end
    Profit_final_expected=[fg,Vector];
    Chart_Shapley_ex=propensity_chat(Profit_final_expected,Ex_post_Allocation_matrix_Shapley*P');
    Chart_al=propensity_chat(Profit_final_expected,Allocate_matrix*P');
    Chart_Least_core=propensity_chat(Profit_final_expected,Ex_post_Allocation_matrix_Least_Core*P');
    Chart_Proportional=propensity_chat(Profit_final_expected,Ex_post_Allocation_matrix_Proportional*P');
    Chart_Dp_ex=propensity_chat(Profit_final_expected,Ex_post_Allocation_matrix_DP*P');
    Chart_Dp_Fixed=propensity_chat(Profit_final_expected,Fixed_Ratio_allocation*P');

    %% Count DP_two_stage<DP_one_stage
    mean_matrix = mean(DP_two_stage); 
    row_matrix=DP_ex_post(1,1:K);
    compare_result=mean_matrix<row_matrix;
    Negaive_two_stage=Negative_Count(DP_two_stage);
    Negative_Shapley=Negative_Count(DP_shapley);
    %% 结构体定义
    Output=struct;
    Output.sum_result_DP=sum(compare_result);
    Output.sum_Neg_Two=sum(Negaive_two_stage);
    Output.sum_Neg_Shapley=sum(Negative_Shapley);
    Output.DP_two_stage=DP_two_stage;
    Output.DP_shapley=DP_shapley;
    Output.DP_ex_post=DP_ex_post;
    Output.DP_expected=DP_expected;
    Output.expected_allocation=Allocate_matrix*P';
    Output.expected_equal_dp=Ex_post_Allocation_matrix_DP*P';
    Output.expected_shapley=Ex_post_Allocation_matrix_Shapley*P';
    Output.Chart_Shapley_ex=Chart_Shapley_ex;
    Output.DP_two_stage;
    Output.Chart_al=Chart_al;
    Output.Chart_Dp_ex=Chart_Dp_ex;
    Output.Chart_Fixed_Ratio=Chart_Dp_Fixed;
    Output.DP_two_stage_E=DP_two_stage*P';
    Output.DP_shapley_E=DP_shapley*P';
    Output.DP_ex_post_E=DP_ex_post*P';
    Output.Allocate_matrix=Allocate_matrix;
    Output.Ex_post_Allocation_matrix_DP=Ex_post_Allocation_matrix_DP;
    Output.Test_11=Test_11;
    Output.Surplus=Surplus;
    Output.Dev_vector=Dev_vector;
    Output.Ex_post_Allocation_matrix_Shapley=Ex_post_Allocation_matrix_Shapley;
    Output.Solution1=Solution_1;
    Output.Chart_Least_core=Chart_Least_core;
    Output.Chart_Proportional=Chart_Proportional;
    Output.DP_Least=DP_least;
    Output.DP_Proportional=DP_proportional;
    Output.DP_Fixed=DP_fixed_ratio;
end