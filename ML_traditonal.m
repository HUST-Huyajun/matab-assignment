%% traditional ML method
clear;clc;
%读取数据
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
    'nndatasets','DigitDataset');
digitData = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');
% 数据处理
data_Files=digitData.Files;
datasize = numel(data_Files);
data_arr=zeros(datasize,28*28);
data_label=double(digitData.Labels)-1;
for i = 1:datasize
    im = imread(data_Files{i,1});
    bwimg=imbinarize(im); %二值化
    if mod(i,1000)==0 & 0
        figure
        imshowpair(im,bwimg,'montage');
    end
    img_arr = reshape(bwimg, 1, numel(bwimg)); %图像展开为一行
    img_arr=double(img_arr);
    data_arr(i,:)=img_arr; %都必须是double，不然会报错
end
%% 
%分割数据
[train_arr,train_label,test_arr,test_label] = split_train_test(data_arr,data_label,10,0.9);
X=train_arr(1:50:9000,:);
Y=train_label(1:50:9000,:);
%{
机器寻优
rng default
Mdl = fitcecoc(X,Y,'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus'))
isLoss = resubLoss(Mdl)
%}

%%
%线性核函数
%{
t = templateLinear('Lambda',0.008');
Mdl = fitcecoc(X',Y,'Learners',t,'ObservationsIn','columns')
Mdl = fitcecoc(X,Y)
%}
%%
%{
%普通核函数
t = templateSVM('Standardize',1)
% Train the ECOC classifier.  It is good practice to specify the class
Mdl = fitcecoc(X,Y,'Learners',t);
%}
%% 
y_pred=predict(Mdl,test_arr);
accuracy = sum(y_pred==test_label)/numel(y_pred);
fprintf("test accuracy=%.1f%%\n",accuracy*100);
%% 
function [X_train, y_train,  X_test, y_test] = split_train_test(X, y, k, ratio)
%SPLIT_TRAIN_TEST 分割训练集和测试集
%  参数X是数据矩阵 y是对应类标签 k是类别个数 ratio是训练集的比例
%  返回训练集X_train和对应的类标签y_train 测试集X_test和对应的类标签y_test

m = size(X, 1);
y_labels = unique(y); % 去重，k应该等于length(y_labels) 
d = [1:m]';

X_train = [];
y_train= [];

for i = 1:k
    comm_i = find(y == y_labels(i));
    if isempty(comm_i) % 如果该类别在数据集中不存在
        continue;
    end
    size_comm_i = length(comm_i);
    rp = randperm(size_comm_i); % random permutation
    rp_ratio = rp(1:floor(size_comm_i * ratio));
    ind = comm_i(rp_ratio);
    X_train = [X_train; X(ind, :)];
    y_train = [y_train; y(ind, :)];
    d = setdiff(d, ind);
end

X_test = X(d, :);
y_test = y(d, :);

end