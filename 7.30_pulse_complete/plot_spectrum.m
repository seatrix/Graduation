clear all; clc;

% GMSK ������ܷ��� ��״̬��Viterbi���
%       ͬ��ͷ���� 24bits ǰ�����1ͬ��ͷ
%                ���������ܳ��� 304bits
%                ͬ��ͷ���У� 1111_1111_0000_0000_0000_0000
%                ������������500*256 = 128000

load('g_128.mat');
load('c0.mat');
load('c0_f.mat');
load('c1.mat');
load('c1_f.mat');
mat_row = 1;
bit_rate = 16;  % bps
T = 1/bit_rate;  % Tb
num_bits = mat_row*100000;  % 500 * 250  ��β����ͬ��ͷ�м�Ϊ250bit����
L = 0;
f_s = 128;
oversamp = T * f_s;
T_s = 1/f_s;  % �������
f_trans = 32;
Eb = 1; % ��������
BER = zeros(1,11);

load('bits_rand.mat');
load('bits_diff_check.mat');

% preamble_seq_der = [1,1,-1,1,  -1,1,-1,1,  1,1,-1,1,  -1,1,-1,1,  -1,1,-1,1,  -1,1,-1,1]; % Ԥ����+˫���� ��ͬ��ͷ����
preamble_seq_der = [1,1,0,1,  0,1,0,1,  1,1,0,1,  0,1,0,1,  0,1,0,1,  0,1,0,1]; % Ԥ�����ͬ��ͷ����
% preamble_seq = [1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]; % ͬ������
thres = 0;  % �о�����
para_dec = 1;  % ��ȡ����
start = 0;  % ��ȡ��ʼλ��
Eb_N0 = 0: 1: 17;

for SNR_idx = 1:length(Eb_N0)

    SNR_idx
    N0 = 1/10^(Eb_N0(SNR_idx)/10);
   

    % GMSK����
    % ������ʼ��
    phi_last = 0;
    pbit = [0,1,1,1];

    for i = 3:num_bits-2

            bit_5 = bits(i-2:i+2);

            [s_gmsk, phi_last, s_gmsk_sin, pbit, I_sig, Q_sig, phi_int] = GMSK(bit_5, pbit, mod(i-1,2), f_trans, phi_last, g);

            signal_trans_I((i-3)*oversamp+1:(i-2)*oversamp) = I_sig;
            signal_trans_temp((i-3)*oversamp+1:(i-2)*oversamp) = complex(I_sig, Q_sig);

    end
    signal_trans = signal_trans_temp(1:end);

    % �Ӹ�˹������
    White_N = sqrt(N0*oversamp/2)*(randn(1,length(signal_trans))+1i*randn(1,length(signal_trans)));
    sig_N = signal_trans + White_N; 
    
    % ��Ƶƫ
%     t = 1:1:length(signal_trans);
%     t = 0:1/oversamp:num_bits-4-1/oversamp;
%     t = mod(0.16*2*pi*t*T, 2*pi);
%     t = 0.16*2*pi*T;

%     rx = signal_trans .* complex(cos(t), sin(t));
%     rx = sig_N .* complex(cos(t), sin(t));
    
    
%     rx = sig_N;
    rx = signal_trans;
   
    % GMSK ���
    Nc0=length(c0_f);
    Nc1=length(c1_f);
    
    r0=conv(c0_f,rx);
    r0n=r0(Nc0:oversamp:end);
    r1=conv(c1_f,rx);
    r1n=r1(Nc1:oversamp:end);
    length1=0;
    length2=0;
    length3=0;
    length4=0;
    l1=[1 1];
    l2=[-1 1];
    l3=[1 -1];
    l4=[-1 -1];
    
    for n=1:(num_bits-4)/2-1
        g1=l1;
        g2=l2;
        g3=l3;
        g4=l4;
        length11=imag(r0n(2*n+1))-real(r1n(2*n+1))+length1;
        length12=imag(r0n(2*n+1))+real(r1n(2*n+1))+length2;
        length21=imag(r0n(2*n+1))+real(r1n(2*n+1))+length3;
        length22=imag(r0n(2*n+1))-real(r1n(2*n+1))+length4;
        length31=-imag(r0n(2*n+1))+real(r1n(2*n+1))+length1;
        length32=-imag(r0n(2*n+1))-real(r1n(2*n+1))+length2;
        length41=-imag(r0n(2*n+1))-real(r1n(2*n+1))+length3;
        length42=-imag(r0n(2*n+1))+real(r1n(2*n+1))+length4;
        
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
        
        g1=l1;
        g2=l2;
        g3=l3;
        g4=l4;
        length11=real(r0n(2*n+2))-imag(r1n(2*n+2))+length1;
        length12=real(r0n(2*n+2))+imag(r1n(2*n+2))+length2;
        length21=real(r0n(2*n+2))+imag(r1n(2*n+2))+length3;
        length22=real(r0n(2*n+2))-imag(r1n(2*n+2))+length4;
        length31=-real(r0n(2*n+2))+imag(r1n(2*n+2))+length1;
        length32=-real(r0n(2*n+2))-imag(r1n(2*n+2))+length2;
        length41=-real(r0n(2*n+2))-imag(r1n(2*n+2))+length3;
        length42=-real(r0n(2*n+2))+imag(r1n(2*n+2))+length4;
        
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
    
    a1=out(2:1:end);
    a2=out(1:1:end-1);
    out=a1.*a2;
    out(1:2:end)=-out(1:2:end);
    error=sum(abs((bits_diff_check(6:end-3)-out(3:end-1))))/2;
    pe(SNR_idx)=error/(num_bits-4-4);

    
end

