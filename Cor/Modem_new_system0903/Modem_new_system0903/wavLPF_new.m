function [wav_S1_1_f] = wavLPF_new(wav_S1_1, LPF, S_lpf)

% ���������ɵĶ�Ӧ��ͬ�����еĲ��ξ������ղ��ֵĻ����źŵ�ͨ�˲����������վ�����ͨ�˲�����һ�����Ŷ�Ӧ1����Ѳ�����Ĳ��Σ�������ͬ��ͷ���ղ��������������

num_pulses = size(wav_S1_1, 1);
oversamp = 8;

wav_S1_1_f = zeros(size(wav_S1_1,1), size(wav_S1_1, 2)/8);


for i = 1:num_pulses
    S1_wav_1_temp = conv(wav_S1_1(i,:), LPF);
    S1_wav_1_f_temp = S1_wav_1_temp(S_lpf:S_lpf+length(wav_S1_1(i,:))-1);
    wav_S1_1_f(i,:) = S1_wav_1_f_temp(1:oversamp:end);

end


