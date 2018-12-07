%% traditional ML method
clear;clc;
%��ȡ����
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
    'nndatasets','DigitDataset');
digitData = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');
% ���ݴ���
data_Files=digitData.Files;
datasize = numel(data_Files);
data_arr=zeros(datasize,28*28);
data_label=double(digitData.Labels)-1;
for i = 1:datasize
    im = imread(data_Files{i,1});
    bwimg=imbinarize(im); %��ֵ��
    if mod(i,1000)==0 & 0
        figure
        imshowpair(im,bwimg,'montage');
    end
    img_arr = reshape(bwimg, 1, numel(bwimg)); %ͼ��չ��Ϊһ��
    img_arr=double(img_arr);
    data_arr(i,:)=img_arr; %��������double����Ȼ�ᱨ��
end
%% 
%�ָ�����
[train_arr,train_label,test_arr,test_label] = split_train_test(data_arr,data_label,10,0.9);
X=train_arr(1:50:9000,:);
Y=train_label(1:50:9000,:);
%{
����Ѱ��
rng default
Mdl = fitcecoc(X,Y,'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus'))
isLoss = resubLoss(Mdl)
%}

%%
%���Ժ˺���
%{
t = templateLinear('Lambda',0.008');
Mdl = fitcecoc(X',Y,'Learners',t,'ObservationsIn','columns')
Mdl = fitcecoc(X,Y)
%}
%%
%{
%��ͨ�˺���
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
%SPLIT_TRAIN_TEST �ָ�ѵ�����Ͳ��Լ�
%  ����X�����ݾ��� y�Ƕ�Ӧ���ǩ k�������� ratio��ѵ�����ı���
%  ����ѵ����X_train�Ͷ�Ӧ�����ǩy_train ���Լ�X_test�Ͷ�Ӧ�����ǩy_test

m = size(X, 1);
y_labels = unique(y); % ȥ�أ�kӦ�õ���length(y_labels) 
d = [1:m]';

X_train = [];
y_train= [];

for i = 1:k
    comm_i = find(y == y_labels(i));
    if isempty(comm_i) % �������������ݼ��в�����
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