clear all, close all

% training of number before
load 'standard.mat'
compare_height = length(standard_num_in_height);
compare_width = length(standard_num_in_width);

% output of result
f1 = fopen('result.txt','wt');

% input of image for test
img_filename = 'img/qipu_test.jpg';
img = imread(img_filename);

figure;
imshow(img);

[width height] = size(img);

% img_hsv = rgb2hsv(img);
% img_h = img_hsv(:,:,1);
% 
% figure;
% imshow(img_h);
% 
% img_h = medfilt2(img_h,[3 3]);
% 
% level = graythresh(img_h);
% img_bw = im2bw(img_h,level);
% 
% figure;
% imshow(img_bw);

% image position
zero_point_x = 13;
zero_point_y = 18;
panel_x = 668;
panel_y = 683;
unit = 18;
qizi_size_x = floor(panel_x / unit);
qizi_size_y = floor(panel_y / unit);

qizi_center_x_vec = [];
qizi_center_y_vec = [];
for m = 0 : unit
    qizi_center_x_vec = [qizi_center_x_vec (m * qizi_size_x + zero_point_x)];
    qizi_center_y_vec = [qizi_center_y_vec (m * qizi_size_y + zero_point_y)];
end

% type = 0 means no qizi, type = 1 means black, type = 2 means white
type_qipan = zeros(1 + unit,1 + unit);

for x = 10 : 10
    for y = 7 : 7
        % locate qizi position
        c_x = qizi_center_x_vec(x);
        c_y = qizi_center_x_vec(y);
        left = c_x - floor(qizi_size_x / 2);
        if left < 0
            left = 0;
        end
        right = c_x + floor(qizi_size_x / 2);
        if right > width - 1
            right = width - 1;
        end
        top = c_y - floor(qizi_size_y / 2);
        if top < 0
            top = 0;
        end
        bottom = c_y + floor(qizi_size_y / 2);
        if bottom > height - 1
            bottom = height - 1;
        end        
    
        % extract sub qizi in the location
        sub_image = img(left+1:right,top+1:bottom,:);   
        imwrite(sub_image,['img/qizi_', int2str(x), '_', int2str(y), '.png']);
        
        % distinguish white/black/no qizi
        [tmp_width tmp_height] = size(sub_image);
        sub_width = tmp_width;
        sub_height = tmp_height / 3;
        sub_image_full_or_not = zeros(sub_width,sub_height,3);
        count_full_or_not = 0;
        count_black_or_white = 0;
        for m = 1 : sub_width
            for n = 1 : sub_height
                %flag = 0;
                avg = mean(sub_image(m,n,:));
                if avg > 127
                    %flag = 1;
                    count_black_or_white = count_black_or_white + 1;
                end                
                for k = 1 : 3
                    if abs(avg - sub_image(m,n,k)) > 10
                        %flag = 1;
                        count_full_or_not = count_full_or_not + 1;
                        break;
                    end     
                end
%                 if flag == 1
%                     sub_image_full_or_not(m,n,1) = 255;
%                     sub_image_full_or_not(m,n,2) = 255;
%                     sub_image_full_or_not(m,n,3) = 255;
%                 end
            end
        end
        
        if count_full_or_not > 0.5 * sub_width * sub_height
            type_qipan(x,y) = 0;
        else
            if count_black_or_white < 0.5 * sub_width * sub_height
                type_qipan(x,y) = 1;
            else
                type_qipan(x,y) = 2;
            end
        end
        
%         figure;
%         imshow(sub_image);  
                
        type_qipan(x,y)
        if type_qipan(x,y) > 0
            sub_image_grey = rgb2gray(sub_image);
            %sub_image_grey_s = medfilt2(sub_image_grey, [3 3]);
            sub_image_binary = im2bw(sub_image_grey);     
            
            % for white qizi, reverse image
            if type_qipan(x,y) == 2
                sub_image_binary = ~sub_image_binary;
            end
        
            figure;
            imshow(sub_image_binary);
            
            [sub_width1 sub_height1] = size(sub_image_binary);
            [L num] = bwlabel(sub_image_binary);
            S = regionprops(L, 'all');
            
            result_p_list = []
            for m = 1:num % get every sub image
                LTmp = double(L == m);
                
                S(m).BoundingBox = floor(S(m).BoundingBox)
                
                % judge whether it's useful
                new_size = (S(m).BoundingBox(3) + 2) * (S(m).BoundingBox(4) + 2);
                size1 = S(m).BoundingBox(3) * S(m).BoundingBox(4);
                ratio = S(m).Area / size1;
                tleft = S(m).BoundingBox(1);
                ttop = S(m).BoundingBox(2);
                tright = S(m).BoundingBox(1) + S(m).BoundingBox(3);
                tdown = S(m).BoundingBox(2) + S(m).BoundingBox(4);               
                
                % not usefule case
                if ratio > 0.5
                    continue;
                    % the special case for number 8
%                     flag = false;
%                     convex_count = S(m).FilledArea;                    
%     
%                     TT = LTmp;
%                     
%                     queuex = [tleft];
%                     queuey = [ttop];
%                     zero_count = 1;
%                     TT(ttop,tleft) = -1;
%                     while (length(queuex) > 0)
%                         'start'
%                         firstx = queuex(1)
%                         firsty = queuey(1)
%                         queuex(1) = [];
%                         queuey(1) = [];                        
%                         
%                         if (firstx - 1 >= tleft - 1 && TT(firsty,firstx - 1) == 0 && ...
%                             (sum(queuex == firstx - 1) == 0 || sum(queuey == firsty) == 0))
%                             queuex = [queuex firstx-1];
%                             queuey = [queuey firsty];  
%                             TT(firsty,firstx - 1) = -1;
%                             zero_count = zero_count + 1;
%                         end
%                         
%                         if (firstx + 1 <= tright + 1 && TT(firsty,firstx + 1) == 0 && ...
%                             (sum(queuex == firstx + 1) == 0 || sum(queuey == firsty) == 0))
%                             queuex = [queuex firstx+1];
%                             queuey = [queuey firsty];
%                             T(firsty,firstx + 1) = -1;
%                             zero_count = zero_count + 1;
%                         end
%                         
%                         if (firsty - 1 >= ttop - 1 && TT(firsty - 1,firstx) == 0 && ...
%                             (sum(queuex == firstx) == 0 || sum(queuey == firsty - 1) == 0))
%                             queuex = [queuex firstx];
%                             queuey = [queuey firsty - 1];
%                             T(firsty - 1,firstx) = -1;
%                             zero_count = zero_count + 1;
%                         end
%                         
%                         if (firsty + 1 <= tdown + 1 && TT(firsty + 1,firstx) == 0 && ...
%                            (sum(queuex == firstx) == 0 || sum(queuey == firsty + 1) == 0))
%                             queuex = [queuex firstx];
%                             queuey = [queuey firsty + 1];
%                             T(firsty + 1,firstx) = -1;
%                             zero_count = zero_count + 1;
%                         end
%                     end
%                     
%                     if (zero_count + convex_count) == new_size
%                         continue
%                     end
                end
                
                % if in the edge, continue
                if tleft <= 2 || ttop <= 2 || (tright >= sub_width1 - 2) || (tdown >= sub_height1 - 2)
                    continue;
                end               
                
                LTmp = LTmp .* 255;
                figure;
                imshow(LTmp);
                title('result');
                %imwrite(LTmp,['img/qizi_', int2str(x), '_', int2str(y), '_sub_', int2str(num),'_',int2str(m),'.png']);

                [test_num_in_height test_num_in_width] = get_character_number(LTmp);

                test_height = length(test_num_in_height);
                test_width = length(test_num_in_width);

                ratio_test_height = int16(compare_height / test_height);
                ratio_test_width = int16(compare_width / test_width);
                
                test_standard_num_in_height = zeros(compare_height,1);
                test_standard_num_in_width = zeros(compare_width,1);
                
                for m1 = 1:test_height
                    test_standard_num_in_height(ratio_test_height * (m1 - 1) + 1 : ratio_test_height * m1 ) = test_num_in_height(m1);
                end
                test_standard_num_in_height = test_standard_num_in_height(1:compare_height);

                for m1 = 1:test_width
                    test_standard_num_in_width(ratio_test_width * (m1 - 1) + 1 : ratio_test_width * m1 ) = test_num_in_width(m1);
                end
                test_standard_num_in_width = test_standard_num_in_width(1:compare_width);
                
                % compare with all standard number from 0 to 9.
                P = 10;
                min_distance = 10;
                min_p = 0;
                distance = zeros(P,1);
                for p = 1 : P
                    for k1 = 1 : compare_height
                        distance(p) = distance(p) + abs(test_standard_num_in_height(k1) - standard_num_in_height(p,k1));
                    end
                    for k1 = 1 : compare_width
                        distance(p) = distance(p) + abs(test_standard_num_in_width(k1) - standard_num_in_width(p,k1));
                    end
                    
                    if distance(p) < min_distance
                        min_distance = distance(p);
                        min_p = p;   
                    end
                end
                
                'sk',min_p
                % get result for value of position(x,y)
                result_p_list = [min_p - 1, result_p_list];
            end 
            
            index = 1;
            result_num = 0;
           
            for m1 = 1 : length(result_p_list)
                result_num = result_num + index * result_p_list(m1);
                index = index * 10;
            end
        else
            result_num = -1;
        end  
        
        fprintf(f1,'v(%d,%d) = %d \n',[x,y,result_num]);
    end
end

fclose(f1);
        