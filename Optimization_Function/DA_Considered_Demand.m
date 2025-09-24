function [Result_dabe]=DA_Considered_Demand(fn,Parameter)
    %% 变量设置
    %%% 日前变量需要提供唯一结果 
    ps=Parameter.P;
    Pda=sdpvar(24,1);%日前出力
    Ptgda=sdpvar(24,1);%tg出力
    Pwppda=sdpvar(24,1);%wpp出力
    Ppvpda=sdpvar(24,1);%光伏出力
    Pceda=sdpvar(24,1);%充电电量
    Pdeda=sdpvar(24,1);%放电电量
    soc=sdpvar(24,1);%SOC变量
    cess=binvar(24,1);%充电状态变量
    dess=binvar(24,1);%放电状态变量
    stg=binvar(24,1);%tg参与状态变量
    Cda=sdpvar(24,1);%日前成本
    Ctgda=sdpvar(24,1);%tg成本
    Cessda=sdpvar(24,1);%ess成本
    Cdemand=sdpvar(24,1);%需求响应成本
    Cut_demand=sdpvar(24,1);%可削减负荷
    Load_forecast=sdpvar(24,1);%随机性负荷
    Total_load=sdpvar(24,1);%总体负荷
    n=24;
    lmpdas=Parameter.Lmpda;
    lmprts=Parameter.Lmprt;
    K=size(Parameter.Wind_f,2);
    F=[];
    %% 约束条件
    %%%日前投标约束
    F=[F Pda(:,1)==fn(3)*Ptgda(:,1)+fn(4)*(Pdeda(:,1)-Pceda(:,1))+fn(1)*Pwppda(:,1)+fn(2)*Ppvpda(:,1)+fn(5)*Cut_demand(:,1)];
    %%% 新能源机组预测出力约束(随机性负荷约束)
    F = [F, min(Parameter.Wind_f(:,1:K),[],2) <= Pwppda(:,1) <= max(Parameter.Wind_f(:,1:K),[],2)];
    F = [F, min(Parameter.Solar_f(:,1:K),[],2) <= Ppvpda(:,1) <= max(Parameter.Solar_f(:,1:K),[],2)];
    F = [F, min(Parameter.Load_f(:,1:K),[],2) <= Load_forecast(:,1) <= max(Parameter.Load_f(:,1:K),[],2)];
    %%% 燃气机组出力约束
    %状态约束
    F=[F fn(3)*stg(:,1)*Parameter.Pgmin<=Ptgda(:,1)];
    F=[F Ptgda(:,1)<=fn(3)*stg(:,1)*Parameter.Pgmax];
    %起停机约束
    F=[F stg(1,1)==0];%默认起始状态为停机
    %爬坡约束
    F = [F -Parameter.Dg<= diff(Ptgda)<= Parameter.Ug];
    %%% 储能设备约束
    %充放电约束
    F=[F 0<=Pceda(:,1)<=fn(4)*cess(:,1)*Parameter.p_cmax];
    F=[F 0<=Pdeda(:,1)<=fn(4)*dess(:,1)*Parameter.p_dmax];
    F=[F cess(:,1)+dess(:,1)<=1];
    F=[F 0<=cess(:,1)+dess(:,1)];
    %SOC约束
    F=[F Parameter.socmin<=soc(:,1)<=Parameter.socmax];
    %充放电约束
    F=[F soc(24,1)==0.5];%(最终电量约束)
    F=[F, soc(1,1)==0.5+ (Pceda(1,1)*Parameter.yt_sin - Pdeda(1,1)/Parameter.yt_sout) / Parameter.Esmax];
    F=[F, diff(soc) == (Pceda(2:end,1)*Parameter.yt_sin - Pdeda(2:end,1)/Parameter.yt_sout) / Parameter.Esmax];
    %可转移负荷约束
    %可削减负荷约束
    %F=[F 0<=Cut_demand(:,1)<=0.85*min(Parameter.Load_f(:,1:K),[],2)];
    F=[F 0<=Cut_demand(:,1)<=0.85*Parameter.Load_base];
    %可削减负荷约束
    %%%日前成本约束：
    Ctgda(:,1)=Parameter.ag*Ptgda(:,1)+Parameter.cg*Ptgda(:,1).^2+Parameter.bg*stg(:,1);
    Cessda(:,1)=Parameter.as*(Pceda(:,1)+Pdeda(:,1));
    Cdemand(:,1)=Parameter.Cutting*Cut_demand(:,1);
    Cda(:,1)=Ctgda(:,1)+Cessda(:,1)+Cdemand(:,1);
    %%%日前利润计算
    Profitda = sum(lmpdas .* repmat(Pda(:,1),1,K) - repmat(Cda(:,1),1,K), 1);

    %%%%%%%%%%%
    %%%%%%%%%%%
    %%%实时投标
    %%% 实时变量根据场景而来
    M=100000;
    mu_1=binvar(24,K);
    K=size(Parameter.Lmpda,2);
    Pre=sdpvar(24,K);%实时参与电力市场量
    Preal=sdpvar(24,K);%
    Stgre=binvar(24,K);
    Re_cess=binvar(24,K);
    Re_dess=binvar(24,K);
    Ptgre=sdpvar(24,K);%tg出力
    Pwppre=sdpvar(24,K);%wpp出力
    Ppvpre=sdpvar(24,K);%光伏出力
    Pcere=sdpvar(24,K);%充电电量
    Pdere=sdpvar(24,K);%放电电量
    socre=sdpvar(24,K);%实时SOC情况
    Cre=sdpvar(24,K);%实时成本
    Ctgre=sdpvar(24,K);
    Cessre=sdpvar(24,K);
    Cdemre=sdpvar(24,K);
    Cutre_demand=sdpvar(24,K);%可削减负荷
    Loadre=sdpvar(24,K);%随机性负荷
    Re_load=sdpvar(24,K);%总体负荷
    % Shenzhen 
    F=[F 0<=Preal<=fn(3)*Ptgre + fn(4)*(Pdere - Pcere) + fn(1)*Pwppre + fn(2)*Ppvpre + fn(5)*Cutre_demand];
    %
    F=[F Preal<=1.3*repmat(Pda,1,K)];
    F=[F Preal-0.8*repmat(Pda,1,K)>=-M*(ones(24,K)-mu_1)];
    F=[F Preal<=M*mu_1];
    F=[F Pre==Preal-repmat(Pda,1,K)];
    %F = [F, Pre <= fn(3)*Ptgre + fn(4)*(Pdere - Pcere) + fn(1)*Pwppre + fn(2)*Ppvpre - fn(5)*Re_load];
    F = [F, Pwppre == fn(1)*Parameter.Wind_f];
    F = [F, Ppvpre == fn(2)*Parameter.Solar_f];
    F = [F, Loadre == fn(5)*Parameter.Load_f];

    %%%tg实时约束
    %出力约束
    F=[F Stgre(1,:)==0];
    LowerBound = fn(3) * Stgre * Parameter.Pgmin; 
    UpperBound = fn(3) * Stgre * Parameter.Pgmax;  
    F = [F  LowerBound<= Ptgre <= UpperBound];
    %爬坡约束
    F=[F -Parameter.Dg<=diff(Ptgre)<=Parameter.Ug];
    %%%储能实时约束
    %出力约束
    F=[F 0<=Pcere<=fn(4)*Re_cess*Parameter.p_cmax];
    F=[F 0<=Pdere<=fn(4)*Re_dess*Parameter.p_cmax];
    F=[F 0<=Re_cess+Re_dess<=1];
    %起动电量
    F = [F socre(1,:) == 0.5 + (Pcere(1,:)*Parameter.yt_sin - Pdere(1,:)/Parameter.yt_sout)/Parameter.Esmax];
    F=  [F socre(24,:)==0.5];

    %SOC约束
    F=[F Parameter.socmin <=socre<=Parameter.socmax];
    %充放电约束
    % 1. socre状态转移
    F = [F diff(socre)== (Pcere(2:end,:)*Parameter.yt_sin - Pdere(2:end,:)/Parameter.yt_sout)/Parameter.Esmax];
    % 2. socre上下界
    %可转移负荷约束
    F=[F 0<=Cutre_demand<=0.85*Parameter.Load_f];
    %%%实时阶段成本计算
    Ctgre = Parameter.ag * Ptgre + Parameter.cg * (Ptgre.^2) + Parameter.bg * Stgre;
    Cessre = Parameter.as * (Pcere + Pdere);
    Cdemre = Parameter.Cutting * Cutre_demand;
    Cre = Ctgre + Cessre + Cdemre;
    fre=0;
    %%%实时收益计算
    Profit = sum(lmpdas .* repmat(Pda,1,K) + lmprts .* Pre - Cre - Parameter.pane * abs(Pre), 1);
    f=sum(ps.*Profit);
    %% 考虑CVaR
    opf=f;
    ops=sdpsettings('solver','gurobi');
    output=optimize(F,-opf,ops);
    Result_dabe=struct;
    Result_dabe.Pda=double(Pda);
    Result_dabe.f=double(opf);
    Result_dabe.Ptgda=double(Ptgda);
    Result_dabe.Pwppda=double(Pwppda);
    Result_dabe.Ppvpda=double(Ppvpda);
    Result_dabe.Pceda=double(Pceda);
    Result_dabe.Pdeda=double(Pdeda);
    Result_dabe.Profitda=double(Profitda);
    Result_dabe.Total_load=double(Total_load);
    Result_dabe.Cutting_load=double(Cut_demand);
    Result_dabe.Soc=double(soc);
    Result_dabe.Cda=double(Cda);
    Result_dabe.Ctgda=sum(double(Ctgda(:,1)));
    Result_dabe.Cessda=sum(double(Cessda(:,1)));
    Result_dabe.Ctgda_list=double(Ctgda(:,1));
    Result_dabe.Cessda_list=double(Cessda(:,1));
    yalmip('clear');
end
