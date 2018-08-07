clear all;
clc;

pic_data = imread('./800x600a.jpg');
pic_red = pic_data(:, :, 1);
pic_green = pic_data(:,:,2);
pic_blue = pic_data(:,:,3);
[ROW COL] = size(pic_red);

fid = fopen('./abcde800x600a.txt', 'w+');
for r = 1 : ROW
    for c = 1: COL
        %redȡ����λ��greenȡ����λ��blueȡ��2λ��ƴ�ӳ�8λ����
        %��Ϊԭ������ΪRGB888��ʽ������ԭʼ��һ֡������Ϊ24bit,����һ֡����Ϊ8���ء�Ϊ��������ʣ���������������
        %0D224 = 1110_-2
        pic_out(r,c) = bitand(pic_red(r,c), 224) + bitshift(bitand(pic_green(r,c), 224), -3) + bitshift(bitand(pic_blue(r,c), 192), -6);
        fprintf(fid, '%02x', pic_out(r,c));
    end
end
fclose(fid);%�ر��ļ�

