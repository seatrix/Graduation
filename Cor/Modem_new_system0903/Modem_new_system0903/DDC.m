function rx_pulse_128_LPF = DDC(wav)

% ������Ƶͼ����һ֡�а���������������������յ���Ƶ�źŲ����±�Ƶ����������64���������ʽ�Ϊ8����������
% ����2Mbps Aģʽ

% ��������
bit_rate = 16e6;  % ��������
T = 1/bit_rate;  % ����ʱ��
fs_IF = 1024e6;  % ��Ƶ�źŲ�������
fs_BB = 128e6;  % �����źŲ�������
oversamp_BB = T * fs_BB;  % �����źŹ���������
oversamp_IF = T * fs_IF;  % ��Ƶ�źŹ���������
num_bits_pulse = 304;  % 2Mbps A\500Kbps\250Kbps һ��������ĳ���
                       % 2Mbps B ÿ������ȥ��ǰ�������ݲ��ֺ�ĳ���

% ��ͨ�˲���
load('LPF_1024.mat'); % ������1024MHz��ͨ��15MHz,���60MHz
load('LPF_128.mat'); % ������128MHz��ͨ��5MHz�����8MHz

S_lpf = 30;
S_lpf2 = 127;

% 21��Ƶ���±�Ƶ������Ƶ�������Ƶ��
freq_21=[240-40/3*10:40/3:240+40/3*10];%�������5��Ƶ��
freq_5=[240-80/3,240-40/3,240,240+40/3,240+80/3];%�������5��Ƶ��
freq_1=[240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240,240];%�������1��Ƶ��
f_trans=freq_21*1000000;
% f_trans=freq_1*1000000;

% rx_pulse_BB = zeros(21, length(wav));

for pulse_idx = 1:21
    
    dt=(0:length(wav)-1);
    rx_pulse_BB(pulse_idx,:)=wav.*exp(-j*(f_trans(pulse_idx)/1024/1000000)*dt*2*pi);
    rx_pulse_LPF(pulse_idx,:)=conv(rx_pulse_BB(pulse_idx,:),LPF_1024);
    rx_pulse_128(pulse_idx,:)=resample(rx_pulse_LPF(pulse_idx,:),128,1024);
    rx_pulse_128_LPF(pulse_idx,:)=conv(rx_pulse_128(pulse_idx,:),LPF_128);
    
%     figure;
%     plot(real(rx_pulse_128_LPF(pulse_idx,:)),'b');
%     hold on;
%     plot(imag(rx_pulse_128_LPF(pulse_idx,:)),'r');
%     close;
    
end