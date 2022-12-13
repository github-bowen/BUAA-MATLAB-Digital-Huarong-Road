function [numbers] = img2Numbers(img, rowM, colN)
%输入图片名字，返回分割好的数字元胞数组
%   输入图片，返回分割好的数字元胞数组
% 图像预处理
I=img;
oldImg = I;
I = rgb2gray(I);
I = imadjust(I,[0.3 0.7],[0.1 0.9],2);
% figure, imshow(I), hold on;
for i = 1:10
    I = medfilt2(I);
end
h = fspecial('log');
I = imfilter(I, h);
% figure, imshow(I), hold on;
% figure, imshow(I), hold on;
I = imbinarize(I);
%figure, imshow(I), hold on;
I = edge(I, "log");
SE = strel("disk",2);
I = imdilate(I, SE);
% figure, imshow(I), hold on;



% 计算边界
[B,L] = bwboundaries(I,'noholes');
% imshow(label2rgb(L, @jet, [.5 .5 .5]))
% hold on

%计算边界围起来最大的面积
maxArea = 0;
maxB = 0;
stats = regionprops(L,'Area','Centroid');
for k = 1:length(B)
  % 获取一条边界上的所有点
  boundary = B{k};
  % 计算边界周长
  delta_sq = diff(boundary).^2;   
  perimeter = sum(sqrt(sum(delta_sq,2)));
  % 获取边界所围面积
  area = stats(k).Area;
  if area > maxArea
        maxArea = area;
        maxB = B{k};
  end
end

% 选取四个边界上的四个点
% 左下角的x-y最大
% 右下角的x+y最大
% 左上角的x+y最小
% 右上角的x-y最小
tempLeftTopVal = maxB(1,1) + maxB(1,2);
tempLeftBottomVal = maxB(1,1) - maxB(1,2);
tempRightTopVal = maxB(1,1) + maxB(1,2);
tempRightBottomVal = maxB(1,1) - maxB(1,2);

leftTop = [maxB(1,1), maxB(1,2)];
leftBottom = [maxB(1,1), maxB(1,2)];
rightTop = [maxB(1,1), maxB(1,2)];
rightBottom = [maxB(1,1), maxB(1,2)];
    for j = 1:length(maxB)
        oldImgX = maxB(j,1);
        oldImgY = maxB(j,2);
        if oldImgX + oldImgY < tempLeftTopVal
            tempLeftTopVal = oldImgX + oldImgY;
            leftTop = [oldImgX, oldImgY];
        end
        if oldImgX - oldImgY > tempLeftBottomVal
            tempLeftBottomVal = oldImgX - oldImgY;
            leftBottom = [oldImgX, oldImgY];
        end
        if oldImgX + oldImgY > tempRightBottomVal
            tempRightBottomVal = oldImgX + oldImgY;
            rightBottom = [oldImgX, oldImgY];
        end
        if oldImgX - oldImgY < tempRightTopVal
            tempRightTopVal = oldImgX - oldImgY;
            rightTop = [oldImgX, oldImgY];
        end
    end
% disp(leftTop);
% disp(leftBottom);
% disp(rightTop);
% disp(rightBottom)
%  imshow(label2rgb(L, @jet, [.5 .5 .5]))
%  hold on
%  plot(maxB(:,2), maxB(:,1), 'w', 'LineWidth', 2);

% imshow(oldImg);
[m,n,k] = size(oldImg);

col=round(sqrt((leftTop(1)-rightTop(1))^2+(leftTop(2)-rightTop(2))^2));   %从原四边形获得新矩形宽
row=round(sqrt((leftTop(1)-leftBottom(1))^2+(leftTop(2)-leftBottom(2))^2));   %从原四边形获得新矩形高
newImg = ones(row,col, k);
% 原图四个基准点的坐标
rightBottom = [rightTop(1) + (leftBottom(1) - leftTop(1)), rightTop(2) + (leftBottom(2) - leftTop(2))];
oldImgX = [leftTop(1),rightTop(1),leftBottom(1),rightBottom(1)];
oldImgY = [leftTop(2),rightTop(2),leftBottom(2),rightBottom(2)];
% 新图四个基准点坐标
newImgX = [1,1,row,row];
newImgY = [1,col,1,col];
% 透视变换的变换矩阵计算

% A*warpmatrix = B
%A
A=[oldImgX(1),oldImgY(1),1,0,0,0,-newImgX(1)*oldImgX(1),-newImgX(1)*oldImgY(1);             
   0,0,0,oldImgX(1),oldImgY(1),1,-newImgY(1)*oldImgX(1),-newImgY(1)*oldImgY(1);
   oldImgX(2),oldImgY(2),1,0,0,0,-newImgX(2)*oldImgX(2),-newImgX(2)*oldImgY(2);
   0,0,0,oldImgX(2),oldImgY(2),1,-newImgY(2)*oldImgX(2),-newImgY(2)*oldImgY(2);
   oldImgX(3),oldImgY(3),1,0,0,0,-newImgX(3)*oldImgX(3),-newImgX(3)*oldImgY(3);
   0,0 ,0,oldImgX(3),oldImgY(3),1,-newImgY(3)*oldImgX(3),-newImgY(3)*oldImgY(3);
   oldImgX(4),oldImgY(4),1,0,0,0,-newImgX(4)*oldImgX(4),-newImgX(4)*oldImgY(4);
   0,0,0,oldImgX(4),oldImgY(4),1,-newImgY(4)*oldImgX(4),-newImgY(4)*oldImgY(4)];
% B
B = [newImgX(1),newImgY(1),newImgX(2),newImgY(2),newImgX(3),newImgY(3),newImgX(4),newImgY(4)]';
% warpmatrix a11,a12,a13,...,a33
% a33 = 1
warpmatrix = A\B;
perspectiveTransformationMatrix = [warpmatrix(1),warpmatrix(2),warpmatrix(3);
     warpmatrix(4),warpmatrix(5),warpmatrix(6);
     warpmatrix(7),warpmatrix(8),1];
invPerspectiveTransformationMatrix = inv(perspectiveTransformationMatrix);
 for i = 1:row
     for j = 1:col
         for u = 1:k
            % A^-1 * [x;y;1]得到原图归一化坐标
            normalizationCod = perspectiveTransformationMatrix \ [i;j;1];
            % 乘上Z得到未归一化坐标
            realCod = ([warpmatrix(7)*normalizationCod(1)-1 warpmatrix(8)*normalizationCod(1);warpmatrix(7)*normalizationCod(2) warpmatrix(8)*normalizationCod(2)-1]) \ [-normalizationCod(1) -normalizationCod(2)]';
            if realCod(1) < m && realCod(2) < n
                newImg(i,j, 1) = oldImg(round(realCod(1)),round(realCod(2)), 1); %最近邻插值
                newImg(i,j, 2) = oldImg(round(realCod(1)),round(realCod(2)), 2); %最近邻插值
                newImg(i,j, 3) = oldImg(round(realCod(1)),round(realCod(2)), 3); %最近邻插值
            else
                newImg(i,j, :) = [0,0,0];
            end
         end
     end
 end


% figure;
% imshow(oldImg,[]);title('原图');
% figure;
% imshow(newImg,[]);title('透视变换后')
psize = size(newImg);

%华容道大小
M = rowM;
N = colN;

a = repmat(fix(psize(1) / M), 1,M);
a(M) = sum(psize(1) - sum(a(:)) + a(M));
b = repmat(fix(psize(2) / N), 1, N);
b(N) = sum(psize(2) - sum(b(:)) + b(N));
numbers = mat2cell(newImg, a, b, 3);
