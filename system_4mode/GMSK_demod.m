function out = GMSK_demod(wav, c0, c1, oversamp, indi, iter)
% input: 
%        wav        �����GMSK�����źŲ���
%        c0         ƥ���˲���1
%        c1         ƥ���˲���2
%        oversamp   ����������
%        indi       =0������ά�ر����볤��Ϊiter  
%                   =1������ά�ر����볤��Ϊiter-1
%        iter       ά�ر����볤��       
%
% output��
%        out   ������

    Nc0=length(c0);  % ƥ���˲���1����
    Nc1=length(c1);  % ƥ���˲���2����

    r0=conv(c0, wav);  % ��������Ĳ���ͨ��ƥ���˲���1
    r0n=r0(Nc0:oversamp:end);  % 8����ȡ
    r1=conv(c1, wav);  % ��������Ĳ���ͨ��ƥ���˲���2
    r1n=r1(Nc1:oversamp:end);  % 8����ȡ
    length1=0;  % ·��1 ����ֵ
    length2=0;  % ·��2 ����ֵ
    length3=0;  % ·��3 ����ֵ
    length4=0;  % ·��4 ����ֵ
    l1=[1 1];   % ·��1 ·��
    l2=[-1 1];  % ·��2 ·��
    l3=[1 -1];  % ·��3 ·��
    l4=[-1 -1]; % ·��4 ·��

    for n=1:(iter)/2-1
        
        % ����λ
        g1=l1;  % �̳���һ�μ������µ�·��1��·��
        g2=l2;  % �̳���һ�μ������µ�·��2��·��
        g3=l3;  % �̳���һ�μ������µ�·��3��·��
        g4=l4;  % �̳���һ�μ������µ�·��4��·��
        length11=imag(r0n(2*n-1))-real(r1n(2*n-1))+length1;  %  1  1 ->  1
        length12=imag(r0n(2*n-1))+real(r1n(2*n-1))+length2;  % -1  1 ->  1
        length21=imag(r0n(2*n-1))+real(r1n(2*n-1))+length3;  %  1 -1 ->  1
        length22=imag(r0n(2*n-1))-real(r1n(2*n-1))+length4;  % -1 -1 ->  1
        length31=-imag(r0n(2*n-1))+real(r1n(2*n-1))+length1; %  1  1 -> -1
        length32=-imag(r0n(2*n-1))-real(r1n(2*n-1))+length2; % -1  1 -> -1
        length41=-imag(r0n(2*n-1))-real(r1n(2*n-1))+length3; %  1 -1 -> -1
        length42=-imag(r0n(2*n-1))+real(r1n(2*n-1))+length4; % -1 -1 -> -1

        % ���ݼ�������·������ֵ����ȡ��
        if length11>length12
            length1=length11;
            l1=[g1,1];
        else
            length1=length12;
            l1=[g2,1];
        end

        if length21>length22
            length2=length21;
            l2=[g3,1];
        else
            length2=length22;
            l2=[g4,1];
        end

        if length31>length32
            length3=length31;
            l3=[g1,-1];
        else
            length3=length32;
            l3=[g2,-1];
        end

        if length41>length42
            length4=length41;
            l4=[g3,-1];
        else
            length4=length42;
            l4=[g4,-1];
        end

        % ͨ��indi�ж� ���1��ż��λ�ļ����Ƿ���Ҫ����
        if(n == (iter)/2-1)
            if(indi)
                continue;
            end
        end
        
        % ż��λ
        g1=l1;  % �̳���һ�μ������µ�·��1��·��
        g2=l2;  % �̳���һ�μ������µ�·��2��·��
        g3=l3;  % �̳���һ�μ������µ�·��3��·��
        g4=l4;  % �̳���һ�μ������µ�·��4��·��
        length11=real(r0n(2*n))-imag(r1n(2*n))+length1;  %  1  1 ->  1
        length12=real(r0n(2*n))+imag(r1n(2*n))+length2;  % -1  1 ->  1
        length21=real(r0n(2*n))+imag(r1n(2*n))+length3;  %  1 -1 ->  1
        length22=real(r0n(2*n))-imag(r1n(2*n))+length4;  % -1 -1 ->  1
        length31=-real(r0n(2*n))+imag(r1n(2*n))+length1; %  1  1 -> -1
        length32=-real(r0n(2*n))-imag(r1n(2*n))+length2; % -1  1 -> -1
        length41=-real(r0n(2*n))-imag(r1n(2*n))+length3; %  1 -1 -> -1
        length42=-real(r0n(2*n))+imag(r1n(2*n))+length4; % -1 -1 -> -1

        % ���ݼ�������·������ֵ����ȡ��
        if length11>length12
            length1=length11;
            l1=[g1,1];
        else
            length1=length12;
            l1=[g2,1];
        end

        if length21>length22
            length2=length21;
            l2=[g3,1];
        else
            length2=length22;
            l2=[g4,1];
        end

        if length31>length32
            length3=length31;
            l3=[g1,-1];
        else
            length3=length32;
            l3=[g2,-1];
        end

        if length41>length42
            length4=length41;
            l4=[g3,-1];
        else
            length4=length42;
            l4=[g4,-1];
        end
    end

    % ������ȫ�����Σ�ѡ������·���ж���ֵ����һ��
    path_length=max(max(length1,length2),max(length3,length4));
    if length1==path_length
        out=l1;
    elseif length2==path_length
        out=l2;
    elseif length3==path_length
        out=l3;
    elseif length4==path_length
        out=l4;
    end 

    a1 = out(2:1:end);  
    a2 = out(1:1:end-1);
    out = a1 .* a2;  % ����������һλ��ǰһλ���
    out(1:2:end)=-out(1:2:end); % ��˽������λȡ������Ϊ���ս�����; 
                                % ��������벨�ζ�Ӧ��ԭʼ�������еĶ�Ӧ��ϵΪ: 
                                % Viterbi(3��end) = bit(4~end)