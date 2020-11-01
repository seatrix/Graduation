function [bits_sync] = data_gen(mat_row, mode)

% ���ո���������ģʽ ��������

switch mode 
    case 1
        preamble_mat = zeros(mat_row, 24);  %��*��
        bits_rand = randi([0,1], [mat_row,256]);  %���������������
        bits_sync = [preamble_mat, bits_rand, preamble_mat];
    case 2
        bits_sync = randi([0,1], [mat_row, 6144]);
    case 3
        preamble_mat = zeros(mat_row, 24+21);
        bits_rand = randi([0,1], [mat_row,214]);  
        bits_sync = [preamble_mat, bits_rand, preamble_mat];
    case 4
        preamble_mat = zeros(mat_row, 24+21);
        bits_rand = randi([0,1], [mat_row,214]);  
        bits_sync = [preamble_mat, bits_rand, preamble_mat];
end

bits_sync = 2*bits_sync-1;
