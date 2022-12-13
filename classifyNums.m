function outputs = classifyNums(net, img, rowM, colN)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明
outputs = zeros(rowM, colN);
imgs = img2Numbers(img, 4, 4);
for i = 1:rowM
    for j = 1:colN
        img = im2uint8(imgs{i, j} / 255);
        img = rgb2gray(img);
        img = imcomplement(img);
        img = imresize(img,[28,28]);
        outputs(i, j) = double(string(classify(net,img)));
    end
end
end