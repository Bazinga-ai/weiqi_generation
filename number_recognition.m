clear all,close all
clc

% TRAINING PROCESS
P = 10;
K = 1;
INTERVAL = 5;
number_train_img_x = zeros(P,INTERVAL);
number_train_img_y = zeros(P,INTERVAL);

is_white = false;
valid_num_grey = 255;
for p = 1:P
    for k = 1:K
        img_filename = ['img/',int2str(p),'_',int2str(k),'.png'];
        if exist(img_filename) == 0
            continue;
        end
        img = imread(img_filename);
        img_binary = im2bw(img);
        img_binary = img_binary .* 255;
        [valid_num_in_height valid_num_in_width] = get_character_number(img_binary,INTERVAL);
    end
    number_train_img_x(p,:) = valid_num_in_height;
    number_train_img_y(p,:) = valid_num_in_width;
    
    figure;
    imshow(img_binary);
end

% GET RESULT
img_test = imread('test/t8.png');
img_test_binary = im2bw(img_test);
img_test_binary = img_test_binary .* 255;
[test_height test_width] = get_character_number(img_test_binary,INTERVAL);

figure;
imshow(img_test_binary);

min_distance = 10;
min_p = 0;
distance = zeros(P,1)
for p = 1:P
    for m = 1:INTERVAL
        distance(p) = distance(p) + abs(test_height(m) - number_train_img_x(p,m)) ...
            + abs(test_width(m) - number_train_img_y(p,m))
    end
    if distance(p) < min_distance
        min_distance = distance(p);
        min_p = p;        
    end
end

min_p
