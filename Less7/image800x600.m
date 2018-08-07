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
        %red取高三位，green取高两位，blue取高2位，拼接成8位数据
        %因为原本你是为RGB888格式，这样原始的一帧数据是为24bit,串口一帧数据为8比特。为了提高速率，所以这样来处理
        %0D224 = 1110_-2
        pic_out(r,c) = bitand(pic_red(r,c), 224) + bitshift(bitand(pic_green(r,c), 224), -3) + bitshift(bitand(pic_blue(r,c), 192), -6);
        fprintf(fid, '%02x', pic_out(r,c));
    end
end
fclose(fid);%关闭文件

