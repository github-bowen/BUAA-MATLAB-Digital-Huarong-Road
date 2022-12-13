
load cnn.mat net;
img = imread('15.jpg');
outputs = classifyNums(net, img, 4, 4);
