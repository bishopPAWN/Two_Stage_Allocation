function  Matrix_Considered_Operator=Operator_2(Matrix)
    Length=size(Matrix,2);
    Matrix_Considered_Operator=zeros(2^Length,Length+1);
    fg=bin_listg1(Length);
    Matrix_Considered_Operator(:,1:Length)=fg;
    Ind=zeros(Length-1,1);
    for i=1:Length-1
        ii=Length-1-i;
        Ind(i)=Matrix(2^(ii)+1,Length);
    end
    for i=1:2^(Length-1)
        Matrix_Considered_Operator(i,Length+1)=sum(fg(i,2:Length)*Ind);
    end
    for i=2^(Length-1)+1:2^Length
        Matrix_Considered_Operator(i,Length+1)=Matrix(i-2^(Length-1),Length);
    end
end