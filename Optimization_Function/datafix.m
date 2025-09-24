%% 该文件为定义文件，用于定义内部所用的数据集
%definite k to get the real-time response
function Parameter = datafix(k )
    Parameter=Creating(k);%wind_f,solar_f:风光预测值
    %wpp pvp上限
    %弃风弃光惩罚
    %% tg的情况
    Parameter.ag=100;%边际成本%￥/(MW*15min)
    Parameter.bg=40;%固定成本%￥/(15min)
    Parameter.cg=80;%二次成本%￥/(MW*15min)^2
    Parameter.sg=0;%开机成本
    Parameter.dg=0;%关机成本
    Parameter.Pgmin=0.1;%出力下限
    Parameter.Pgmax=6.0;%出力上限
    Parameter.Ug=1.5;
    Parameter.Dg=1.5;
    %Gg:最小开机时间Hg：最小停机时间，Ug：最大向上爬坡功率 Dg:最大向下爬坡功率
    %% 储能的情况
    Parameter.Esmax=8;%MW*15min
    Parameter.as=0;%运行成本
    Parameter.yt_sout=0.95;
    Parameter.yt_sin=0.95;%能量消耗常数
    Parameter.p_cmax=1.5;%充电功率
    Parameter.p_dmax=1.5;%放电功率
    Parameter.socmin=0.05;%最小荷电状态
    Parameter.socmax=0.95;%最大荷电状态
    %% cutting
    Parameter.Cutting=685;%￥/MW*15min
    %% 惩罚
    Parameter.pane=500;%惩罚水平￥/MW*15min
    Parameter.res=0;
end

