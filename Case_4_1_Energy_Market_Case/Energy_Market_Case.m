clear all;
Scenario_MemberA=[40,80,60,0];
Scenario_MemberB=[50,50,70,60];
addpath('Profit_optimization\');
p=[0.32,0.32,0.32,0.04]';
Quantity=sdpvar(3,1);
Quantity_a=sdpvar(4,1);
Quantity_b=sdpvar(4,1);
Quantity_C=sdpvar(4,1);
fg=bin_listg1(3);
F=[];
Pda=sdpvar(1,1);
Psell=sdpvar(4,1);
Pbuy=sdpvar(4,1);
Crt=sdpvar(4,1);
y=sdpvar(1,1);
E_da=zeros(8,4);
Quantity_Da=zeros(8,4);
%% the sell price need to be lower than the purchase price
Price_sell=0.2;Price_buy=0.6;
Price_da=0.3;
Price_e=0.005;
for kk=2:7
    fn=fg(kk,:);
    E_da(kk,1:3)=fn;
    Quantity_Da(kk,1:3)=fn;
    PRofit_Da(kk,1:3)=fn;
    F=[];
    F=[F fn(1)*min(Scenario_MemberA)<=Quantity(1)<=fn(1)*max(Scenario_MemberA)];
    F=[F fn(2)*min(Scenario_MemberB)<=Quantity(2)<=fn(2)*max(Scenario_MemberB)];
    F=[F fn(3)*0<=Quantity(3)<=fn(3)*100];
    F=[F Pda==Quantity(1)+Quantity(2)+Quantity(3)];
    for i=1:4
        F=[F Quantity_a(i)<=Scenario_MemberA(i)];
        F=[F Quantity_b(i)<=Scenario_MemberB(i)];
        F=[F 0<=Quantity_C(i)<=100];
        F=[F Psell(i)-Pbuy(i)==sum(fn(1)*Quantity_a(i)+fn(2)*Quantity_b(i)+fn(3)*Quantity_C(i))-Pda];
        F=[F 0<=Psell(i)];
        F=[F 0<=Pbuy(i)];
    end
    frt=-Price_buy*Pbuy+Price_sell*Psell-fn(3)*Price_e*Quantity_C.^2;
    %frt=frt-fn(1)*0.02*(Quantity_a-Quantity(1)).^2-fn(2)*0.02*(Quantity_b-Quantity(2)).^2;
    f=Price_da*Pda+sum(p.*frt);
    ops=sdpsettings('solver','gurobi');
    output=optimize(F,-f,ops);
    f=double(f);
    E_da(kk,4)=Price_da*Pda+sum(p.*(-Price_buy*Pbuy+Price_sell*Psell-fn(3)*Price_e*Quantity_C.^2));
    Pda_real=double(Pda);
    Psell_real=double(Psell);
    Pbuy_real=double(Pbuy);
    Quantity_Da(kk,4)=double(Pda);
    PRofit_Da(kk,4)=Price_da*Pda_real-Price_e*double(Quantity(3))*double(Quantity(3));
    PRofit_Da(kk,5)=Price_e*double(Quantity(3))*double(Quantity(3));
end
%%
Quantity=double(Quantity);
Quantity_a=double(Quantity_a);
Quantity_b=double(Quantity_b);
Quantity_C=double(Quantity_C);
yalmip('clear');
RT_a=sdpvar(4,1);
RT_b=sdpvar(4,1);
RT_c=sdpvar(4,1);
Psell=sdpvar(4,1);
Pbuy=sdpvar(4,1);
F=[];
Realized_profit=zeros(8,7);
Real_Time=zeros(8,7);
Realized_profit(:,1:3)=fg;
Real_Time(:,1:3)=fg;
f=0;
Price_dual=zeros(4,1);
for kk=2:7
    fn=fg(kk,:);
    Pda=Quantity_Da(kk,4);
    for i=4:4
        F=[F RT_a(i)==Scenario_MemberA(i)];
        F=[F RT_b(i)==Scenario_MemberB(i)];
        F=[F 0<=RT_c(i)<=100];
        F=[F Psell(i)-Pbuy(i)==sum(fn(1)*RT_a(i)+fn(2)*RT_b(i)+fn(3)*RT_c(i))-Pda];
        F=[F Psell(i)>=0];
        F=[F Pbuy(i)>=0];
        f=-Price_buy*Pbuy(i)+Price_sell*Psell(i)-fn(3)*Price_e*RT_c(i)*RT_c(i);
        ops=sdpsettings('solver','gurobi');
        output=optimize(F,-f,ops);
        Price_dual(i)=dual(F(4));
        Realized_profit(kk,i+3)=double(f)+Price_da*Pda;
        Real_Time(kk,i+3)=double(f)+PRofit_Da(kk,5);% Real-Time Profit of Each Scenario
        F=[];
    end
end
RT_a=double(RT_a);
RT_b=double(RT_b);
RT_c=double(RT_c);
