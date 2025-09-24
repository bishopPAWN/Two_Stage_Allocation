function [Result_rt]=RT_Considered_Demand(fn,Parameter,scen,Pda)
    Lmpda=Parameter.Lmpda(:,scen);
    Lmprt=Parameter.Lmprt(:,scen);
    Wind_r=Parameter.Wind_f(:,scen);
    Solar_r=Parameter.Solar_f(:,scen);
    Load_r=Parameter.Load_f(:,scen);
    %%% 日前变量已经完全确定，实时阶段报价需要根据实际出力来 
    M=10000;
    Prt=sdpvar(24,1);
    Preal=sdpvar(24,1);
    mu_1=binvar(24,1);
    Crt=sdpvar(24,1);%实时成本
    Ctgrt=sdpvar(24,1);%燃气成本
    Cessrt=sdpvar(24,1);%储能成本
    Ptgrt=sdpvar(24,1);%tg出力
    Pwpprt=sdpvar(24,1);%wpp出力
    Ppvprt=sdpvar(24,1);%光伏出力
    Pcert=sdpvar(24,1);%充电电量
    Pdert=sdpvar(24,1);%放电电量
    socrt=sdpvar(24,1);%SOC变量
    Cut_re=sdpvar(24,1);%可削减负荷
    Total_re=sdpvar(24,1);%总负荷
    cess=binvar(24,1);%充电状态变量
    dess=binvar(24,1);%放电状态变量
    stg=binvar(24,1);%tg参与状态变量
    n=24;
    %% 实时出力约束
    F=[];
    F=[F 0<=Preal<=fn(1)*Pwpprt+fn(2)*Ppvprt+fn(3)*Ptgrt+fn(4)*(Pdert-Pcert)+fn(5)*Cut_re];
    %%% 随机性资源约束
    F=[F Preal<=1.3*Pda];
    F=[F Preal-0.8*Pda>=-M*mu_1];
    F=[F Preal<=M*(1-mu_1)];
    F=[F Prt==Preal-Pda];
    F=[F 0<=Pwpprt<=fn(1)*Wind_r];%风电出力约束
    F=[F 0<=Ppvprt<=fn(2)*Solar_r];%光伏出力约束
    %%% 燃气机组出力约束
    %状态约束
    F=[F fn(3)*stg(:,1)*Parameter.Pgmin<=Ptgrt(:,1)<=fn(3)*stg(:,1)*Parameter.Pgmax];
    %起停机约束
    F=[F stg(1,1)==0];%默认起始状态为停机
    %爬坡约束
    F = [F, -Parameter.Dg<=diff(Ptgrt) <= Parameter.Ug];
    %%% 储能设备约束
    % 储能系统约束
    F = [F, 0 <= Pcert <= fn(4)*cess*Parameter.p_cmax];
    F = [F, 0 <= Pdert <= fn(4)*dess*Parameter.p_dmax];
    F = [F, 0 <= cess + dess <= 1];
    F = [F, Parameter.socmin <= socrt <= Parameter.socmax];
    F = [F, socrt(1) ==  0.5+ (Pcert(1)*Parameter.yt_sin - Pdert(1)/Parameter.yt_sout)/Parameter.Esmax];
    F = [F, socrt(24) == 0.5];
    % SOC动态更新
    F = [F, diff(socrt)==(Pcert(2:end)*Parameter.yt_sin - Pdert(2:end)/Parameter.yt_sout)/Parameter.Esmax];
    % 可削减负荷约束
    F = [F, 0 <= Cut_re <= 0.85*Load_r];

    % 成本函数构造
    Ctgrt = Parameter.cg.*(Ptgrt.^2) + Parameter.ag.*Ptgrt + Parameter.bg.*stg;
    Cessrt = Parameter.as * (Pcert + Pdert);
    Cdert = Parameter.Cutting * Cut_re;
    Crt = Ctgrt + Cessrt + Cdert;
    f=sum(Lmpda.*Pda+Lmprt.*Prt-Parameter.pane*(abs(Prt))-Crt);
    opf=f;
    ops=sdpsettings('solver','gurobi');
    output=optimize(F,-opf,ops);
    rtfresult=struct;
    rtfresult.f=double(opf);
    rtfresult.Pwpprt=double(Pwpprt);
    rtfresult.Prt=double(Prt);
    rtfresult.Preal=double(Preal);
    rtfresult.mu_1=double(mu_1);
    rtfresult.Cut_demand=double(Cut_re);
    rtfresult.Total_demand=double(Total_re);
    rtfresult.Ppvprt=double(Ppvprt);
    rtfresult.Ptgrt=double(Ptgrt);
    rtfresult.Pdert=double(Pdert);
    rtfresult.Pcert=double(Pcert);
    rtfresult.Crt=double(Crt);
    rtfresult.rt_solution=double(sum(Lmprt.*Prt-Parameter.pane*(abs(Prt))-Crt));
    Result_rt=rtfresult;
    yalmip('clear');
end
