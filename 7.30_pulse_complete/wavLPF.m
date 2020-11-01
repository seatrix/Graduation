function [wav_S1_1_f, wav_S2_1_f, wav_S1_2_f, wav_S2_2_f] = wavLPF(wav_S1_1, wav_S2_1, wav_S1_2, wav_S2_2, LPF, S_lpf)

% ���������ɵĶ�Ӧ��ͬ�����еĲ��ξ������ղ��ֵĻ����źŵ�ͨ�˲����������վ�����ͨ�˲�����һ�����Ŷ�Ӧ1����Ѳ�����Ĳ��Σ�������ͬ��ͷ���ղ��������������

num_pulses = size(wav_S1_1, 1);  %���ؾ������������������
oversamp = 8;  %�����Ĺ���������

wav_S1_1_f = zeros(size(wav_S1_1,1), size(wav_S1_1, 2)/8);
wav_S2_1_f = zeros(size(wav_S2_1,1), size(wav_S2_1, 2)/8);
wav_S1_2_f = zeros(size(wav_S1_2,1), size(wav_S1_2, 2)/8);
wav_S2_2_f = zeros(size(wav_S2_2,1), size(wav_S2_2, 2)/8);

for i = 1:num_pulses
    S1_wav_1_temp = conv(wav_S1_1(i,:), LPF);
    S1_wav_1_f_temp = S1_wav_1_temp(S_lpf+1:S_lpf+length(wav_S1_1(i,:)));
    wav_S1_1_f(i,:) = S1_wav_1_f_temp(8:oversamp:end);

    S2_wav_1_temp = conv(wav_S2_1(i,:), LPF);
    S2_wav_1_f_temp = S2_wav_1_temp(S_lpf+1:S_lpf+length(wav_S2_1(i,:)));
    wav_S2_1_f(i,:) = S2_wav_1_f_temp(8:oversamp:end);
    
    S1_wav_2_temp = conv(wav_S1_2(i,:), LPF);
    S1_wav_2_f_temp = S1_wav_2_temp(S_lpf+1:S_lpf+length(wav_S1_2(i,:)));
    wav_S1_2_f(i,:) = S1_wav_2_f_temp(8:oversamp:end);

    S2_wav_2_temp = conv(wav_S2_2(i,:), LPF);
    S2_wav_2_f_temp = S2_wav_2_temp(S_lpf+1:S_lpf+length(wav_S2_2(i,:)));
    wav_S2_2_f(i,:) = S2_wav_2_f_temp(8:oversamp:end);
end
