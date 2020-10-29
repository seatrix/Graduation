function [wav_S1, wav_S2] = wav_gen_new(pn_lib_1, pn_lib_2, pn_lib_3, pn_lib_4, mode)

%  ����ͬ��ͷ���ж�Ӧ�ı��ز���

load('lib/g_1024.mat');  % g����
bit_rate = 16e6;  % ��������
T = 1/bit_rate;  % Tb
f_s = 1024e6;  % ����Ƶ��
oversamp = T * f_s; % ����������
f_trans = 32;  % �����ã�

% GMSK����
% 2Mbps A ����ģʽ
if mode == 1
    num_pulses = 12;
    num_bits_pn = 24;
    pn = [1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];  % 2Mbps A ģʽ��ͬ��ͷ��������
    
    % ����S1
    for idx = 1:num_pulses

        phi_last = 0;
        preamble = double(xor(pn_lib_1(idx,:), pn));  % ԭʼͬ��ͷ�����������������õ����յ�ͬ��ͷ����
        preamble = 2*preamble-1;
        for i = 1:num_bits_pn

            if (i==1)
                bit_5 = [preamble(i), preamble(i), preamble(i:i+2)];
            elseif (i==2)
                bit_5 = [preamble(i-1), preamble(i-1:i+2)];
            elseif (i==num_bits_pn-1)
                bit_5 = [preamble(i-2:i+1), 0];
            elseif (i==num_bits_pn)
                bit_5 = [preamble(i-2:i), 0, 0];
            else
                bit_5 = preamble(i-2:i+2);
            end

            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S1_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
%             wav_S1_1024_PHI(idx, (i-1)*oversamp+1:(i)*oversamp) = phi_int;

        end
        wav_S1(idx, :) = wav_S1_1024(idx, 8:8:end);
%         wav_S1_PHI(idx, :) = wav_S1_1024_PHI(idx, 8:8:end);


    end
    
    % ����S2
    for idx = 1:num_pulses

        phi_last = 0;
        preamble = double(xor(pn_lib_2(idx,:), pn));
        preamble = 2*preamble-1;
        
        for i = 1:num_bits_pn

            if (i==1)
                bit_5 = [preamble(i), preamble(i), preamble(i:i+2)];
            elseif (i==2)
                bit_5 = [preamble(i-1), preamble(i-1:i+2)];
            elseif (i==num_bits_pn-1)
                bit_5 = [preamble(i-2:i+1), 0];
            elseif (i==num_bits_pn)
                bit_5 = [preamble(i-2:i), 0, 0];
            else
                bit_5 = preamble(i-2:i+2);
            end

            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S2_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);

        end
        wav_S2(idx, :) = wav_S2_1024(idx, 8:8:end);

    end
    
% 2Mbps B����ģʽ
elseif mode == 2
    
    num_pulses = 12;
    num_bits_pn = 24;
    pn = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0];  % 2Mbps B ģʽ��ͬ��ͷ��������
    % ����S1
    for idx = 1:num_pulses

        phi_last = 0;
        preamble = double(xor(pn_lib_1(idx,:), pn));
        preamble = 2*preamble-1;

        for i = 1:num_bits_pn

            if (i==1)
                bit_5 = [preamble(i), preamble(i), preamble(i:i+2)];
            elseif (i==2)
                bit_5 = [preamble(i-1), preamble(i-1:i+2)];
            elseif (i==num_bits_pn-1)
                bit_5 = [preamble(i-2:i+1), 0];
            elseif (i==num_bits_pn)
                bit_5 = [preamble(i-2:i), 0, 0];
            else
                bit_5 = preamble(i-2:i+2);
            end

            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S1_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);

        end
        wav_S1(idx, :) = wav_S1_1024(idx, 8:8:end);

    end
    
    % ����S2
    for idx = 1:num_pulses

        phi_last = 0;
        preamble = double(xor(pn_lib_2(idx,:), pn));
        preamble = 2*preamble-1;

        for i = 1:num_bits_pn

            if (i==1)
                bit_5 = [preamble(i), preamble(i), preamble(i:i+2)];
            elseif (i==2)
                bit_5 = [preamble(i-1), preamble(i-1:i+2)];
            elseif (i==num_bits_pn-1)
                bit_5 = [preamble(i-2:i+1), 0];
            elseif (i==num_bits_pn)
                bit_5 = [preamble(i-2:i), 0, 0];
            else
                bit_5 = preamble(i-2:i+2);
            end

            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S2_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);

        end
        wav_S2(idx, :) = wav_S2_1024(idx, 8:8:end);

    end
    
% 500K����ģʽ    
elseif mode == 3
    num_pulses = 15;
    num_bits_pn = 45;
    pn = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];  % 500Kbps ģʽ��ͬ��ͷS1��S2��������
    pn_2 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];  % 500Kbps ģʽ��ͬ��ͷS3��S4��������
    % ����S1��S3
    for idx = 1:num_pulses
        preamble_s1 = double(xor(pn_lib_1(idx,:), pn));
        preamble_s3 = double(xor(pn_lib_3(idx,:), pn_2));
        preamble_s1 = 2*preamble_s1-1;
        preamble_s3 = 2*preamble_s3-1;
        phi_last = 0;
        for i = 1:num_bits_pn-21
            if (i==1)
                bit_5 = [preamble_s1(i), preamble_s1(i), preamble_s1(i:i+2)];
            elseif (i==2)
                bit_5 = [preamble_s1(i-1), preamble_s1(i-1:i+2)];
            elseif (i==num_bits_pn-21-1)
                bit_5 = [preamble_s1(i-2:i+1), 0];
            elseif (i==num_bits_pn-21)
                bit_5 = [preamble_s1(i-2:i), 0, 0];
            else
                bit_5 = preamble_s1(i-2:i+2);
            end

            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S1_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
        end
        phi_last = 0;
        for i = num_bits_pn-20:num_bits_pn
            if (i==num_bits_pn-20)
                bit_5 = [preamble_s3(i-num_bits_pn+21), preamble_s3(i-num_bits_pn+21), preamble_s3(i-num_bits_pn+21:i-num_bits_pn+21+2)];
            elseif (i==num_bits_pn-19)
                bit_5 = [preamble_s3(i-num_bits_pn+21-1), preamble_s3(i-num_bits_pn+21-1:i-num_bits_pn+21+2)];
            elseif (i==num_bits_pn-1)
                bit_5 = [preamble_s3(i-num_bits_pn+21-2:i-num_bits_pn+21+1), 0];
            elseif (i==num_bits_pn)
                bit_5 = [preamble_s3(i-num_bits_pn+21-2:i-num_bits_pn+21), 0, 0];
            else
                bit_5 = preamble_s3(i-num_bits_pn+21-2:i-num_bits_pn+21+2);
            end
            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S1_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
        end
        wav_S1(idx, :) = wav_S1_1024(idx, 8:8:end);

    end
    
    % ����S4��S2
    for idx = 1:num_pulses
        preamble_s2 = double(xor(pn_lib_2(idx,:), pn));
        preamble_s4 = double(xor(pn_lib_4(idx,:), pn_2));
        preamble_s2 = 2*preamble_s2-1;
        preamble_s4 = 2*preamble_s4-1;
        phi_last = 0;
        for i = 1:num_bits_pn-21
            if (i==1)
                bit_5 = [preamble_s2(i), preamble_s2(i), preamble_s2(i:i+2)];
            elseif (i==2)
                bit_5 = [preamble_s2(i-1), preamble_s2(i-1:i+2)];
            elseif (i==num_bits_pn-21-1)
                bit_5 = [preamble_s2(i-2:i+1), 0];
            elseif (i==num_bits_pn-21)
                bit_5 = [preamble_s2(i-2:i), 0, 0];
            else
                bit_5 = preamble_s2(i-2:i+2);
            end

            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S2_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
        end
        phi_last = 0;
        for i = num_bits_pn-20:num_bits_pn
            if (i==num_bits_pn-20)
                bit_5 = [preamble_s4(i-num_bits_pn+21), preamble_s4(i-num_bits_pn+21), preamble_s4(i-num_bits_pn+21:i-num_bits_pn+21+2)];
            elseif (i==num_bits_pn-19)
                bit_5 = [preamble_s4(i-num_bits_pn+21-1), preamble_s4(i-num_bits_pn+21-1:i-num_bits_pn+21+2)];
            elseif (i==num_bits_pn-1)
                bit_5 = [preamble_s4(i-num_bits_pn+21-2:i-num_bits_pn+21+1), 0];
            elseif (i==num_bits_pn)
                bit_5 = [preamble_s4(i-num_bits_pn+21-2:i-num_bits_pn+21), 0, 0];
            else
                bit_5 = preamble_s4(i-num_bits_pn+21-2:i-num_bits_pn+21+2);
            end
            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S2_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
        end
        wav_S2(idx, :) = wav_S2_1024(idx, 8:8:end);

    end
    
    
%     for idx = 1:num_pulses
% 
%         phi_last = 0;
%         preamble = [double(xor(pn_lib_4(idx,:), pn_2)), double(xor(pn_lib_2(idx,:), pn))];
%         preamble = 2*preamble-1;
%        
%         for i = 1:num_bits_pn
% 
%             if (i==1)
%                 bit_5 = [preamble(i), preamble(i), preamble(i:i+2)];
%             elseif (i==2)
%                 bit_5 = [preamble(i-1), preamble(i-1:i+2)];
%             elseif (i==num_bits_pn-1)
%                 bit_5 = [preamble(i-2:i+1), 0];
%             elseif (i==num_bits_pn)
%                 bit_5 = [preamble(i-2:i), 0, 0];
%             else
%                 bit_5 = preamble(i-2:i+2);
%             end
% 
%             [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
%             wav_S2_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
% 
%         end
%         wav_S2(idx, :) = wav_S2_1024(idx, 8:8:end);
% 
%     end
    
% 250K����ģʽ    
else
    num_pulses = 15;
    num_bits_pn = 45;
    pn = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    pn_2 = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    
     % ����S1��S3
    for idx = 1:num_pulses
        preamble_s1 = double(xor(pn_lib_1(idx,:), pn));
        preamble_s3 = double(xor(pn_lib_3(idx,:), pn_2));
        preamble_s1 = 2*preamble_s1-1;
        preamble_s3 = 2*preamble_s3-1;
        preamble_s1_s3=[preamble_s1,preamble_s3];
        phi_last = 0;
        for i = 1:45
            if (i==1)
                bit_5 = [preamble_s1_s3(i), preamble_s1_s3(i), preamble_s1_s3(i:i+2)];
            elseif (i==2)
                bit_5 = [preamble_s1_s3(i-1), preamble_s1_s3(i-1:i+2)];
            elseif (i==44)
                bit_5 = [preamble_s1_s3(i-2:i+1), 0];
            elseif (i==45)
                bit_5 = [preamble_s1_s3(i-2:i), 0, 0];
            else
                bit_5 = preamble_s1_s3(i-2:i+2);
            end

            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S1_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
        end
        wav_S1(idx, :) = wav_S1_1024(idx, 1:64:end);

    end
    
    % ����S4��S2
    for idx = 1:num_pulses
        preamble_s2 = double(xor(pn_lib_2(idx,:), pn));
        preamble_s4 = double(xor(pn_lib_4(idx,:), pn_2));
        preamble_s2 = 2*preamble_s2-1;
        preamble_s4 = 2*preamble_s4-1;
        phi_last = 0;
        for i = 1:num_bits_pn-21
            if (i==1)
                bit_5 = [preamble_s2(i), preamble_s2(i), preamble_s2(i:i+2)];
            elseif (i==2)
                bit_5 = [preamble_s2(i-1), preamble_s2(i-1:i+2)];
            elseif (i==num_bits_pn-21-1)
                bit_5 = [preamble_s2(i-2:i+1), 0];
            elseif (i==num_bits_pn-21)
                bit_5 = [preamble_s2(i-2:i), 0, 0];
            else
                bit_5 = preamble_s2(i-2:i+2);
            end

            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S2_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
        end
        phi_last = 0;
        for i = num_bits_pn-20:num_bits_pn
            if (i==num_bits_pn-20)
                bit_5 = [preamble_s4(i-num_bits_pn+21), preamble_s4(i-num_bits_pn+21), preamble_s4(i-num_bits_pn+21:i-num_bits_pn+21+2)];
            elseif (i==num_bits_pn-19)
                bit_5 = [preamble_s4(i-num_bits_pn+21-1), preamble_s4(i-num_bits_pn+21-1:i-num_bits_pn+21+2)];
            elseif (i==num_bits_pn-1)
                bit_5 = [preamble_s4(i-num_bits_pn+21-2:i-num_bits_pn+21+1), 0];
            elseif (i==num_bits_pn)
                bit_5 = [preamble_s4(i-num_bits_pn+21-2:i-num_bits_pn+21), 0, 0];
            else
                bit_5 = preamble_s4(i-num_bits_pn+21-2:i-num_bits_pn+21+2);
            end
            [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
            wav_S2_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
        end
        wav_S2(idx, :) = wav_S2_1024(idx, 1:64:end);

    end
    
%     % ����S1��S3
%     for idx = 1:num_pulses
% 
%         phi_last = 0;
%         preamble = [double(xor(pn_lib_1(idx,:), pn)), double(xor(pn_lib_3(idx,:), pn_2))];
%         preamble = 2*preamble-1;
% 
%         for i = 1:num_bits_pn
% 
%             if (i==1)
%                 bit_5 = [preamble(i), preamble(i), preamble(i:i+2)];
%             elseif (i==2)
%                 bit_5 = [preamble(i-1), preamble(i-1:i+2)];
%             elseif (i==num_bits_pn-1)
%                 bit_5 = [preamble(i-2:i+1), 0];
%             elseif (i==num_bits_pn)
%                 bit_5 = [preamble(i-2:i), 0, 0];
%             else
%                 bit_5 = preamble(i-2:i+2);
%             end
% 
%             [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
%             wav_S1_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
% 
%         end
%         wav_S1_temp(idx, :) = wav_S1_1024(idx, 8:8:end);
% 
%     end
%     
%     % ����S4��S2
%     for idx = 1:num_pulses
% 
%         phi_last = 0;
%         preamble = [double(xor(pn_lib_4(idx,:), pn_2)), double(xor(pn_lib_2(idx,:), pn))];
%         preamble = 2*preamble-1;
% 
%         for i = 1:num_bits_pn
% 
%             if (i==1)
%                 bit_5 = [preamble(i), preamble(i), preamble(i:i+2)];
%             elseif (i==2)
%                 bit_5 = [preamble(i-1), preamble(i-1:i+2)];
%             elseif (i==num_bits_pn-1)
%                 bit_5 = [preamble(i-2:i+1), 0];
%             elseif (i==num_bits_pn)
%                 bit_5 = [preamble(i-2:i), 0, 0];
%             else
%                 bit_5 = preamble(i-2:i+2);
%             end
% 
%             [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_trans, phi_last, g);
%             wav_S2_1024(idx, (i-1)*oversamp+1:(i)*oversamp) = complex(I_sig, Q_sig);
% 
%         end
%         wav_S2_temp(idx, :) = wav_S2_1024(idx, 8:8:end);
% 
%     end
    
%     wav_S1 = repmat(wav_S1_temp, [2,1]);
%     wav_S2 = repmat(wav_S2_temp, [2,1]);

end
    
    
    
    
