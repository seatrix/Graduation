function signal_trans = transmitter(bits, fh_pat_lib_1, th_pat_lib_1, fh_pat_lib_2, th_pat_lib_2, pn_lib_S1_1, pn_lib_S1_2,...
    pn_lib_S2_1, pn_lib_S2_2, pn_lib_S3_1, pn_lib_S3_2, pn_lib_S4_1, pn_lib_S4_2, mode)

% �������
load('lib/f_trans.mat');  % 21��Ƶ��
load('lib/g_1024.mat');  % GMSK���� g���� 

% ������������
bit_rate = 16e6;  % ��������
T = 1/bit_rate;  % ����ʱ��
fs_IF = 1024e6;  % ��Ƶ�źŲ�������
oversamp_IF = T * fs_IF;
num_bits_pn = 24;  % ͬ��ͷS1\S2 ����
num_bits_pn_2 = 21;  % ͬ��ͷS3\S4 ����

switch mode
    % 2Mbps A ģʽ
    case 1 
        
        num_pulses = 12;
        
        % ͬ��ͷ����
        pn = [1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]; % 2Mbps A ģʽͬ��ͷS1\S2��Ӧ����������
        S1_lib_1 = zeros(1, num_bits_pn);
        S2_lib_1 = zeros(1, num_bits_pn);
        S1_lib_2 = zeros(1, num_bits_pn);
        S2_lib_2 = zeros(1, num_bits_pn);
        for i = 1:num_pulses
            S1_lib_1(i,:) = double(xor(pn_lib_S1_1(i,:), pn));
            S2_lib_1(i,:) = double(xor(pn_lib_S2_1(i,:), pn));
            S1_lib_2(i,:) = double(xor(pn_lib_S1_2(i,:), pn));
            S2_lib_2(i,:) = double(xor(pn_lib_S2_2(i,:), pn));
        end
        
        % ��Ƶͼ��
        fh_pat_1 = fh_pat_lib_1(1:num_pulses);
        fh_pat_2 = fh_pat_lib_2(1:num_pulses);
        % ��ʱͼ��
        th_pat_1 = th_pat_lib_1(1:num_pulses);
        th_pat_2 = th_pat_lib_2(1:num_pulses); 
        
        
        [mat_row, mat_col] = size(bits);
        frame_idx = 0;
        for i = 1:mat_row

            % ÿ������һ֡ ����ѡ��һ����Ƶ����ʱͼ��
            if (mod(i-1,12)==0)
                frame_idx = frame_idx + 1; 
                a = rand(1);
                if (a<0.5)
                    sel = 1;
                else
                    sel = 2;
                end

                if (sel == 1)
                    fh_pat = fh_pat_1;
                    th_pat = th_pat_1;
                    pn_lib_S1 = S1_lib_1;
                    pn_lib_S2 = S2_lib_1;
                elseif (sel == 2)
                    fh_pat = fh_pat_2;
                    th_pat = th_pat_2;
                    pn_lib_S1 = S1_lib_2;
                    pn_lib_S2 = S2_lib_2;               
                end

                th_pat_idx(frame_idx) = sel;
            end

            % ���Ʋ�����ʼ��
            % ���ࡢ��ƵƵ�ʡ�ͬ��ͷ���С���ʱ����
            phi_last = 0;  % ��ʼ��λ
            f_idx = fh_pat(mod(i-1,12)+1);
            f_IF = f_trans(f_idx);
            preamble_S1 = 2*(pn_lib_S1(mod(i-1,12)+1,:))-1;
            preamble_S2 = 2*(pn_lib_S2(mod(i-1,12)+1,:))-1;
            t_mod = -304*T/2:1/fs_IF:304*T/2-1/fs_IF;
            t_mod = t_mod(1:end) + (T/oversamp_IF/2);  % ���ĶԳ� 
            bits_trans = [preamble_S1, bits(i,25:end-24), preamble_S2];  % �����˫����ת��

            for j = 1:304   % ÿһ֡: 304bit���ȵĲ���

                % �Բ�ͬλ�ã�ȡ5bit���ݣ�׼���������ģ��
                if (j == 1)
                    bit_5 = [bits_trans(j), bits_trans(j), bits_trans(j:j+2)];
                elseif (j == 2)
                    bit_5 = [bits_trans(j-1), bits_trans(j-1:j+2)];
                elseif (j == 279)  % ���ݲ��ֵ����ڶ�����
                    bit_5 = [bits_trans(j-2:j+1), 0];
                elseif (j == 280)  % ���ݲ������1����
                    bit_5 = [bits_trans(j-2:j), 0, 0];
                elseif (j == 281)  % βͬ��ͷ��1bit
                    phi_last = 0;
                    bit_5 = [bits_trans(j), bits_trans(j), bits_trans(j:j+2)];
                elseif (j == 282)  % βͬ��ͷ��2bit
                    bit_5 = [bits_trans(j-1), bits_trans(j-1:j+2)];
                elseif (j == 303)  % βͬ��ͷ�����ڶ�bit
                    bit_5 = [bits_trans(j-2:j+1), 0];
                elseif (j == 304)  % βͬ��ͷ���һbit
                    bit_5 = [bits_trans(j-2:j), 0, 0];
                else
                    bit_5 = bits_trans(j-2:j+2);
                end

                [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_IF, phi_last, g);
                signal_trans_temp_BB(i, (j-1)*oversamp_IF+1:(j)*oversamp_IF) = complex(I_sig, Q_sig);
                phi_all(i, (j-1)*oversamp_IF+1:(j)*oversamp_IF) = phi_int;
            end
            I_sig_IF = cos(2*pi*f_IF*t_mod);
            Q_sig_IF = sin(2*pi*f_IF*t_mod);
            signal_trans_temp_IF(i, :) = signal_trans_temp_BB(i, :) .* complex(I_sig_IF, Q_sig_IF);  % ��������λ���ƣ�ÿһ��������ز�����ʼ��λ��Ϊ0
%             signal_trans_temp_IF(i,:) = signal_trans_temp_BB(i,:);

        end

        % ����֡���ƺ���źŲ��ΰ�����ʱͼ������������źŲ���
        last = 0;
        frame_idx = 0;
        for i = 1:mat_row
            if (mod(i-1,12)==0)
                frame_idx = frame_idx + 1;
                th_idx = th_pat_idx(frame_idx);
                if th_idx==1
                    th_pat = th_pat_1;
                elseif th_idx==2
                    th_pat = th_pat_2;
                end
            end
            th = th_pat(mod(i-1,12)+1);
            temp_S = [zeros(1, th/2*oversamp_IF), signal_trans_temp_IF(i,:), zeros(1, th/2*oversamp_IF)];
            signal_trans(last+1:last+length(temp_S)) = temp_S;
            last = last+length(temp_S);
        end
        
    % 2Mbps B ģʽ
    case 2
        
        num_pulses = 12;
        
        % ͬ��ͷ����
        pn = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0];  % 2Mbps B ģʽͬ��ͷS1\S2��Ӧ����������
        S1_lib_1 = zeros(1, num_bits_pn);
        S2_lib_1 = zeros(1, num_bits_pn);
        S1_lib_2 = zeros(1, num_bits_pn);
        S2_lib_2 = zeros(1, num_bits_pn);
        for i = 1:num_pulses
            S1_lib_1(i,:) = double(xor(pn_lib_S1_1(i,:), pn));
            S2_lib_1(i,:) = double(xor(pn_lib_S2_1(i,:), pn));
            S1_lib_2(i,:) = double(xor(pn_lib_S1_2(i,:), pn));
            S2_lib_2(i,:) = double(xor(pn_lib_S2_2(i,:), pn));
        end
        
        % ��Ƶͼ��
        fh_pat_1 = fh_pat_lib_1(1:num_pulses);
        fh_pat_2 = fh_pat_lib_2(1:num_pulses);
        % ��ʱͼ��
        th_pat_1 = th_pat_lib_1(1:num_pulses);
        th_pat_2 = th_pat_lib_2(1:num_pulses);
        
        
        [mat_row, mat_col] = size(bits);
        frame_idx = 0;
        frame_length = 304*12+512*6+103*12;
        for i = 1:mat_row

            % ÿ������һ֡ ����ѡ��һ����Ƶ����ʱͼ��
            frame_idx = frame_idx + 1; 
            a = rand(1);
            if (a<0.5)
                sel = 1;
            else
                sel = 2;
            end

            if (sel == 1)
                fh_pat = fh_pat_1;
                th_pat = th_pat_1;
                pn_lib_S1 = S1_lib_1;
                pn_lib_S2 = S2_lib_1;
            elseif (sel == 2)
                fh_pat = fh_pat_2;
                th_pat = th_pat_2;
                pn_lib_S1 = S1_lib_2;
                pn_lib_S2 = S2_lib_2;               
            end

            th_pat_idx(frame_idx) = sel;
            frame_last_bit = 0;
            last = 0;
            num_bits_pulse = zeros(12);
            for j = 1:num_pulses

                % ���Ʋ�����ʼ��
                % ���ࡢ��ƵƵ�ʡ�ͬ��ͷ���С���ʱ����
                phi_last = 0;  % ��ʼ��λ
                f_idx = fh_pat(mod(j-1,12)+1);
                f_IF = f_trans(f_idx);
                preamble_S1 = 2*(pn_lib_S1(mod(j-1,12)+1,:))-1;
                preamble_S2 = 2*(pn_lib_S2(mod(j-1,12)+1,:))-1;
                th = th_pat(mod(j-1,12)+1);
                bits_trans = [bits(i, frame_last_bit+1:frame_last_bit+th/2), preamble_S1, bits(i, frame_last_bit+th/2+1:frame_last_bit+th/2+256), preamble_S2, bits(i, frame_last_bit+th/2+257:frame_last_bit+th/2+256+th/2)]; 
                frame_last_bit = frame_last_bit + 256 + th;
                signal_trans_temp_BB = zeros(1, (304+3+th)*oversamp_IF);
                for jj = 1:304+th+3   % ÿһ������: (304+th+3)bit���ȵĲ���

                    % �Բ�ͬλ�ã�ȡ5bit���ݣ�׼���������ģ��

                    % ǰ���ݶ�
                    if (jj == 1)
                        bit_5 = [1, 1, 1, 1, 1];
                    elseif (jj == 2)
                        bit_5 = [1, 1, 1, 1, bits_trans(1)];
                    elseif (jj == 3)
                        bit_5 = [1, 1, 1, bits_trans(1:2)];
                    elseif (jj == 4)
                        bit_5 = [1, 1, bits_trans(1:3)];
                    elseif (jj == 5)
                        bit_5 = [1, bits_trans(1:4)];
                    elseif (jj < th/2+3-1)
                        bit_5 = bits_trans(jj-3-2:jj-3+2);
                    elseif (jj == th/2+3-1)
                        bit_5 = [bits_trans(jj-3-2:jj-3+1),0];
                    elseif (jj == th/2+3)
                        bit_5 = [bits_trans(jj-3-2:jj-3), 0, 0];


                    % �м����ݶ�    
                    elseif (jj == th/2+3+1)  % ��ͬ��ͷ��1bit
                        phi_last = 0;
                        bit_5 = [bits_trans(jj-3), bits_trans(jj-3), bits_trans(jj-3:jj-3+2)];
                    elseif (jj == th/2+3+2)  % ��ͬ��ͷ��2bit
                        bit_5 = [bits_trans(jj-3-1), bits_trans(jj-3-1:jj-3+2)];
                    elseif (jj < th/2+3+280-1)
                        bit_5 = bits_trans(jj-3-2:jj-3+2);
                    elseif (jj == th/2+3+280-1)  % ���ݲ��ֵ�����2bit
                        bit_5 = [bits_trans(jj-3-2:jj-3+1), 0];
                    elseif (jj == th/2+3+280)  % ���ݲ������1bit
                        bit_5 = [bits_trans(jj-3-2:jj-3), 0, 0];                   


                    % β���ݶ�     
                    elseif (jj == th/2+3+280+1)  % βͬ��ͷ��1bit 
                        phi_last = 0;
                        bit_5 = [bits_trans(jj-3),bits_trans(jj-3),bits_trans(jj-3:jj-3+2)];
                    elseif (jj == th/2+3+280+2)  % βͬ��ͷ��2bit 
                        bit_5 = [bits_trans(jj-3-1), bits_trans(jj-3-1:jj-3+2)];
                    elseif (jj < th+3+304-1)  
                        bit_5 = bits_trans(jj-3-2:jj-3+2);
                    elseif (jj == th+3+304-1)  % ���ݶε�����2bit
                        bit_5 = [bits_trans(jj-3-2:jj-3+1), 0];
                    elseif (jj == th+3+304)  % ���ݶ����1bit
                        bit_5 = [bits_trans(jj-3-2:jj-3), 0, 0];    

                    end

                    [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_IF, phi_last, g);
                    signal_trans_temp_BB((jj-1)*oversamp_IF+1:(jj)*oversamp_IF) = complex(I_sig, Q_sig);

                end
                num_bits_pulse(j) = 3+th+304;
                t_mod = -num_bits_pulse(j)*T/2:1/fs_IF:num_bits_pulse(j)*T/2-1/fs_IF;
                t_mod = t_mod(1:end) + (T/oversamp_IF/2);  % ���ĶԳ�

                I_sig_IF = cos(2*pi*f_IF*t_mod);
                Q_sig_IF = sin(2*pi*f_IF*t_mod);
                signal_trans_temp_IF = signal_trans_temp_BB .* complex(I_sig_IF, Q_sig_IF);  % ��������λ���ƣ�ÿһ��������ز�����ʼ��λ��Ϊ0
%                 signal_trans_temp_IF = signal_trans_temp_BB;
                temp = [zeros(1, 100*oversamp_IF), signal_trans_temp_IF];
                signal_trans_temp(last+1:last+(100+num_bits_pulse(j))*oversamp_IF) = temp;
                last = last + (100+num_bits_pulse(j))*oversamp_IF;
            end
            signal_trans((i-1)*frame_length*oversamp_IF+1:i*frame_length*oversamp_IF) = signal_trans_temp;
        end
           
    % 500K ģʽ    
    case 3
        
        num_pulses = 48;
        
        % ͬ��ͷ����
        pn = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];  % 500Kbps ģʽ ͬ��ͷS1\S2��Ӧ����������
        pn_2 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];  % 500Kbps ģʽ ͬ��ͷS3\S4��Ӧ����������
        S1_lib_1 = zeros(1, num_bits_pn);
        S2_lib_1 = zeros(1, num_bits_pn);
        S3_lib_1 = zeros(1, num_bits_pn_2);
        S4_lib_1 = zeros(1, num_bits_pn_2);
        S1_lib_2 = zeros(1, num_bits_pn);
        S2_lib_2 = zeros(1, num_bits_pn);
        S3_lib_2 = zeros(1, num_bits_pn_2);
        S4_lib_2 = zeros(1, num_bits_pn_2);
        for i = 1:num_pulses
            S1_lib_1(i,:) = double(xor(pn_lib_S1_1(i,:), pn));
            S2_lib_1(i,:) = double(xor(pn_lib_S2_1(i,:), pn));
            S3_lib_1(i,:) = double(xor(pn_lib_S3_1(i,:), pn_2));
            S4_lib_1(i,:) = double(xor(pn_lib_S4_1(i,:), pn_2));
            S1_lib_2(i,:) = double(xor(pn_lib_S1_2(i,:), pn));
            S2_lib_2(i,:) = double(xor(pn_lib_S2_2(i,:), pn));
            S3_lib_2(i,:) = double(xor(pn_lib_S3_2(i,:), pn_2));
            S4_lib_2(i,:) = double(xor(pn_lib_S4_2(i,:), pn_2));
        end
        
        % ��Ƶͼ��
        fh_pat_1 = fh_pat_lib_1(1:num_pulses);
        fh_pat_2 = fh_pat_lib_2(1:num_pulses);
        % ��ʱͼ��
        th_pat_1 = th_pat_lib_1(1:num_pulses);
        th_pat_2 = th_pat_lib_2(1:num_pulses);
        
        [mat_row, mat_col] = size(bits);
        frame_idx = 0;
        for i = 1:mat_row

            % ÿ������һ֡ ����ѡ��һ����Ƶ����ʱͼ��
            if (mod(i-1,num_pulses)==0)
                frame_idx = frame_idx + 1; 
                a = rand(1);
                if (a<0.5)
                    sel = 1;
                else
                    sel = 2;
                end

                if (sel == 1)
                    fh_pat = fh_pat_1;
                    th_pat = th_pat_1;
                    pn_lib_S1 = S1_lib_1;
                    pn_lib_S2 = S2_lib_1;
                    pn_lib_S3 = S3_lib_1;
                    pn_lib_S4 = S4_lib_1;
                elseif (sel == 2)
                    fh_pat = fh_pat_2;
                    th_pat = th_pat_2;
                    pn_lib_S1 = S1_lib_2;
                    pn_lib_S2 = S2_lib_2;
                    pn_lib_S3 = S3_lib_2;
                    pn_lib_S4 = S4_lib_2;
                end

                th_pat_idx(frame_idx) = sel;
            end

            % ���Ʋ�����ʼ��
            % ���ࡢ��ƵƵ�ʡ�ͬ��ͷ���С���ʱ����
            phi_last = 0;  % ��ʼ��λ
            f_idx = fh_pat(mod(i-1,num_pulses)+1);
            f_IF = f_trans(f_idx);
            preamble_S1 = 2*(pn_lib_S1(mod(i-1,num_pulses)+1,:))-1;
            preamble_S2 = 2*(pn_lib_S2(mod(i-1,num_pulses)+1,:))-1;
            preamble_S3 = 2*(pn_lib_S3(mod(i-1,num_pulses)+1,:))-1;
            preamble_S4 = 2*(pn_lib_S4(mod(i-1,num_pulses)+1,:))-1;
            t_mod = -304*T/2:1/fs_IF:304*T/2-1/fs_IF;
            t_mod = t_mod(1:end) + (T/oversamp_IF/2);  % ���ĶԳ�
            bits_trans = [preamble_S1, preamble_S3, bits(i,46:end-45), preamble_S4, preamble_S2];  % �����˫����ת��

            for j = 1:304   % ÿһ֡: 304bit���ȵĲ���

                % �Բ�ͬλ�ã�ȡ5bit���ݣ�׼���������ģ��
                if (j == 1)
                    bit_5 = [bits_trans(j), bits_trans(j), bits_trans(j:j+2)];
                elseif (j == 2)
                    bit_5 = [bits_trans(j-1), bits_trans(j-1:j+2)];
                elseif (j == 258)  % ���ݲ��ֵ����ڶ�����
                    bit_5 = [bits_trans(j-2:j+1), 0];
                elseif (j == 259)  % ���ݲ������1����
                    bit_5 = [bits_trans(j-2:j), 0, 0];
                elseif (j == 260)  % βͬ��ͷ��1bit
                    phi_last = 0;
                    bit_5 = [bits_trans(j), bits_trans(j), bits_trans(j:j+2)];
                elseif (j == 261)  % βͬ��ͷ��2bit
                    bit_5 = [bits_trans(j-1), bits_trans(j-1:j+2)];
                elseif (j == 303)  % βͬ��ͷ�����ڶ�bit
                    bit_5 = [bits_trans(j-2:j+1), 0];
                elseif (j == 304)  % βͬ��ͷ���һbit
                    bit_5 = [bits_trans(j-2:j), 0, 0];
                else
                    bit_5 = bits_trans(j-2:j+2);
                end

                [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_IF, phi_last, g);
                signal_trans_temp_BB(i, (j-1)*oversamp_IF+1:(j)*oversamp_IF) = complex(I_sig, Q_sig);

            end
            I_sig_IF = cos(2*pi*f_IF*t_mod);
            Q_sig_IF = sin(2*pi*f_IF*t_mod);
            signal_trans_temp_IF(i, :) = signal_trans_temp_BB(i, :) .* complex(I_sig_IF, Q_sig_IF);  % ��������λ���ƣ�ÿһ��������ز���ʼ��λ��Ϊ0
%             signal_trans_temp_IF(i,:) = signal_trans_temp_BB(i,:);

        end


        % ����֡���ƺ���źŲ��ΰ�����ʱͼ������������źŲ���
        last = 0;
        frame_idx = 0;
        for i = 1:mat_row
            if (mod(i-1,num_pulses)==0)
                frame_idx = frame_idx + 1;
                th_idx = th_pat_idx(frame_idx);
                if th_idx==1
                    th_pat = th_pat_1;
                elseif th_idx==2
                    th_pat = th_pat_2;
                end
            end
            if (mod(i,num_pulses)~=0)
                th = th_pat(mod(i-1,num_pulses)+1);
                temp_S = [zeros(1, th/2*oversamp_IF), signal_trans_temp_IF(i,:), zeros(1, th/2*oversamp_IF)];
                signal_trans(last+1:last+length(temp_S)) = temp_S;
                last = last+length(temp_S);
            else
                th = th_pat(mod(i-1,num_pulses)+1);
                temp_S = [zeros(1, th/2*oversamp_IF), signal_trans_temp_IF(i,:), zeros(1, th/2*oversamp_IF), zeros(1, 10*oversamp_IF)];
                signal_trans(last+1:last+length(temp_S)) = temp_S;
                last = last+length(temp_S);
            end
        end
        
    % 250K ģʽ    
    case 4
        
        num_pulses = 96;
        
        % ͬ��ͷ����
        pn = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];  % 250Kbps ģʽ ͬ��ͷS1\S2��Ӧ����������
        pn_2 = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];  % 250Kbps ģʽ ͬ��ͷS3\S4��Ӧ����������
        S1_lib_1 = zeros(1, num_bits_pn);
        S2_lib_1 = zeros(1, num_bits_pn);
        S3_lib_1 = zeros(1, num_bits_pn_2);
        S4_lib_1 = zeros(1, num_bits_pn_2);
        S1_lib_2 = zeros(1, num_bits_pn);
        S2_lib_2 = zeros(1, num_bits_pn);
        S3_lib_2 = zeros(1, num_bits_pn_2);
        S4_lib_2 = zeros(1, num_bits_pn_2);
        for i = 1:num_pulses
            S1_lib_1(i,:) = double(xor(pn_lib_S1_1(i,:), pn));
            S2_lib_1(i,:) = double(xor(pn_lib_S2_1(i,:), pn));
            S3_lib_1(i,:) = double(xor(pn_lib_S3_1(i,:), pn_2));
            S4_lib_1(i,:) = double(xor(pn_lib_S4_1(i,:), pn_2));
            S1_lib_2(i,:) = double(xor(pn_lib_S1_2(i,:), pn));
            S2_lib_2(i,:) = double(xor(pn_lib_S2_2(i,:), pn));
            S3_lib_2(i,:) = double(xor(pn_lib_S3_2(i,:), pn_2));
            S4_lib_2(i,:) = double(xor(pn_lib_S4_2(i,:), pn_2));
        end

        % ��Ƶͼ��
        fh_pat_1 = fh_pat_lib_1(1:num_pulses);
        fh_pat_2 = fh_pat_lib_2(1:num_pulses);
        % ��ʱͼ��
        th_pat_1 = th_pat_lib_1(1:num_pulses);
        th_pat_2 = th_pat_lib_2(1:num_pulses); 
        
        [mat_row, mat_col] = size(bits);
        
        frame_idx = 0;
        for i = 1:mat_row

            % ÿ������һ֡ ����ѡ��һ����Ƶ����ʱͼ��
            if (mod(i-1,num_pulses)==0)
                frame_idx = frame_idx + 1; 
                a = rand(1);
                if (a<0.5)
                    sel = 1;
                else
                    sel = 2;
                end

                if (sel == 1)
                    fh_pat = fh_pat_1;
                    th_pat = th_pat_1;
                    pn_lib_S1 = S1_lib_1;
                    pn_lib_S2 = S2_lib_1;
                    pn_lib_S3 = S3_lib_1;
                    pn_lib_S4 = S4_lib_1;
                elseif (sel == 2)
                    fh_pat = fh_pat_2;
                    th_pat = th_pat_2;
                    pn_lib_S1 = S1_lib_2;
                    pn_lib_S2 = S2_lib_2;
                    pn_lib_S3 = S3_lib_2;
                    pn_lib_S4 = S4_lib_2;
                end

                th_pat_idx(frame_idx) = sel;
            end

            % ���Ʋ�����ʼ��
            % ���ࡢ��ƵƵ�ʡ�ͬ��ͷ���С���ʱ����
            phi_last = 0;  % ��ʼ��λ
            f_idx = fh_pat(mod(i-1,num_pulses)+1);
            f_IF = f_trans(f_idx);
            preamble_S1 = 2*(pn_lib_S1(mod(i-1,num_pulses)+1,:))-1;
            preamble_S2 = 2*(pn_lib_S2(mod(i-1,num_pulses)+1,:))-1;
            preamble_S3 = 2*(pn_lib_S3(mod(i-1,num_pulses)+1,:))-1;
            preamble_S4 = 2*(pn_lib_S4(mod(i-1,num_pulses)+1,:))-1;
            t_mod = -304*T/2:1/fs_IF:304*T/2-1/fs_IF;
            t_mod = t_mod(1:end) + (T/oversamp_IF/2);  % ���ĶԳ�
            bits_trans = [preamble_S1, preamble_S3, bits(i,46:end-45), preamble_S4, preamble_S2];  % �����˫����ת��

            for j = 1:304   % ÿһ֡: 304bit���ȵĲ���

                % �Բ�ͬλ�ã�ȡ5bit���ݣ�׼���������ģ��
                if (j == 1)
                    bit_5 = [bits_trans(j), bits_trans(j), bits_trans(j:j+2)];
                elseif (j == 2)
                    bit_5 = [bits_trans(j-1), bits_trans(j-1:j+2)];
                elseif (j == 258)  % ���ݲ��ֵ����ڶ�����
                    bit_5 = [bits_trans(j-2:j+1), 0];
                elseif (j == 259)  % ���ݲ������1����
                    bit_5 = [bits_trans(j-2:j), 0, 0];
                elseif (j == 260)  % βͬ��ͷ��1bit
                    phi_last = 0;
                    bit_5 = [bits_trans(j), bits_trans(j), bits_trans(j:j+2)];
                elseif (j == 261)  % βͬ��ͷ��2bit
                    bit_5 = [bits_trans(j-1), bits_trans(j-1:j+2)];
                elseif (j == 303)  % βͬ��ͷ�����ڶ�bit
                    bit_5 = [bits_trans(j-2:j+1), 0];
                elseif (j == 304)  % βͬ��ͷ���һbit
                    bit_5 = [bits_trans(j-2:j), 0, 0];
                else
                    bit_5 = bits_trans(j-2:j+2);
                end

                [phi_last, I_sig, Q_sig, phi_int] = GMSK(bit_5, f_IF, phi_last, g);
                signal_trans_temp_BB(i, (j-1)*oversamp_IF+1:(j)*oversamp_IF) = complex(I_sig, Q_sig);

            end
            I_sig_IF = cos(2*pi*f_IF*t_mod);
            Q_sig_IF = sin(2*pi*f_IF*t_mod);
            signal_trans_temp_IF(i, :) = signal_trans_temp_BB(i, :) .* complex(I_sig_IF, Q_sig_IF);  % ��������λ���ƣ�ÿһ��������ز���ʼ��λ��Ϊ0
%             signal_trans_temp_IF(i,:) = signal_trans_temp_BB(i,:);

        end


        % ����֡���ƺ���źŲ��ΰ�����ʱͼ������������źŲ���
        last = 0;
        frame_idx = 0;
        for i = 1:mat_row
            if (mod(i-1,num_pulses)==0)
                frame_idx = frame_idx + 1;
                th_idx = th_pat_idx(frame_idx);
                if th_idx==1
                    th_pat = th_pat_1;
                elseif th_idx==2
                    th_pat = th_pat_2;
                end
            end
            th = th_pat(mod(i-1,num_pulses)+1);
            temp_S = [zeros(1, th/2*oversamp_IF), signal_trans_temp_IF(i,:), zeros(1, th/2*oversamp_IF)];
            signal_trans(last+1:last+length(temp_S)) = temp_S;
            last = last+length(temp_S);
        end
        
        
end