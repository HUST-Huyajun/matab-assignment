%% transfer learning
clear;clc;close all;
% %��ȡѵ�����Ͳ��Լ�
% %�任ͼƬ��С
% digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
%     'nndatasets','DigitDataset');
% digitData = imageDatastore(digitDatasetPath, ...
%     'IncludeSubfolders',true,'LabelSource','foldernames');
% digitData=IMAGERESIZE(digitData);
%%

%��ȡalexnet
net = alexnet;
net.Layers
%��ȡѵ�����Ͳ��Լ� alexnet
digitDatasetPath = 'D:\matlab��ҵ\�����ҵ\ͼƬ��\competiton\alextnetsize\';
digitData = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');
%%
%% 
%{
% ��ȡmatlab�Լ�ѵ���õ���ĸ���ַ�������
load(fullfile(matlabroot,'examples','nnet','LettersClassificationNet.mat'))
net.Layers
%��ȡѵ�����Ͳ��Լ� matlab�Դ�����
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
    'nndatasets','DigitDataset');
digitData = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');
%}
%%
[trainDigitData,testDigitData] = splitEachLabel(digitData,0.999,'randomize');
trainsize=trainDigitData.Files;
testsize=testDigitData.Files;
fprintf("trainsize=%d\n",numel(trainsize));
fprintf("testsize=%d\n",numel(testsize));
%��ʾǰ20��ѵ����Ƭ
%{
numImages = numel(trainDigitData.Files);
idx = randperm(numImages,20);
for i = 1:20
    subplot(4,5,i)
    
    I = readimage(trainDigitData, idx(i));
    label = char(trainDigitData.Labels(idx(i)));
    
    imshow(I)
    title(label)
end
%}
%%

% �ı�������������
layersTransfer = net.Layers(1:end-3);
% ��ʾ�µ�������
numClasses =  numel(categories(trainDigitData.Labels));
% ����������滻���µ����
layers = [...
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];
functions = { ...
    @plotTraining, ...
    %@plotTrainingLoss,...
    @(info) stopTrainingAtThreshold(info,100)};
optionsTransfer = trainingOptions('sgdm', ...
    'MaxEpochs',1,...
    'MiniBatchSize',64, ...
    'InitialLearnRate',0.0001,...
    'ExecutionEnvironment','gpu',...
    'OutputFcn',functions);
% ѵ������
netTransfer = trainNetwork(trainDigitData,layers,optionsTransfer);

%% 
% ���Լ�׼ȷ��
YPred = classify(netTransfer,testDigitData);
YTest = testDigitData.Labels;
accuracy = sum(YPred==YTest)/numel(YTest);
fprintf("test accuracy=%.1f%%\n",accuracy*100);
%% 
% ��ʾ���в��Դ���Ľ��
figure
wrong=YPred~=YTest;
num=1;
for i = 1:numel(wrong)
    if wrong(i)==1
        subplot(4,8,num)
        num=num+1;
        I = readimage(testDigitData, i);
        label = strcat('yhat=',char(YPred(i)),' y=',char(YTest(i)));

        imshow(I)
        title(label)
    end
    if num>=32
        break
    end
end
%% 
function plotTraining(info)

persistent plotObj1
persistent plotObj2
persistent maxLoss
persistent maxaccuracy
persistent mLoss
persistent maccuracy
if info.State == "start"
    
    maxLoss=3;
    maxaccuracy=100;
    mLoss=0;
    maccuracy=0;
    plotObj1 = animatedline();
    xlabel("Iteration");
    yyaxis left
    ylabel("Training Accuracy");
    axis([0,300,0,maxaccuracy]);
    axis 'auto x'
    
    plotObj2 = animatedline;
    plotObj2.Color='blue';
    xlabel("Iteration")
    yyaxis right
    ylabel("Training Loss");
    axis([0,300,0,maxLoss]);
    axis 'auto x'
elseif info.State == "iteration"
    
    yyaxis left
    addpoints(plotObj1,info.Iteration,info.TrainingAccuracy)
    maccuracy=max(maccuracy,info.TrainingAccuracy);
    drawnow limitrate nocallbacks
    
    yyaxis right
    a=gather(info.TrainingLoss);
    a=double(a);
    mLoss=max(mLoss,a);
    yR=a*maxaccuracy/maxLoss;
    
    addpoints(plotObj2,info.Iteration,yR)
    drawnow limitrate nocallbacks
else
    %���ڷ�������ǰ��maxLoss��maxaccuracy����
    mLoss;
    maccuracy;
end

end

function stop = stopTrainingAtThreshold(info,thr)

stop = false;
if info.State ~= "iteration"
    return
end

persistent iterationAccuracy

% Append accuracy for this iteration
iterationAccuracy = [iterationAccuracy info.TrainingAccuracy];

% Evaluate mean of iteration accuracy and remove oldest entry
if numel(iterationAccuracy) == 50
    stop = mean(iterationAccuracy) > thr;

    iterationAccuracy(1) = [];
end

end
%% ͼƬ��ʽת��
function input = IMAGERESIZE(input)
    nums = numel(input.Files);
    for i=nums:-1:1
        filepathin=input.Files{i,1};
        Imagein = imread(filepathin);
        imshow(Imagein)
        if numel(size(Imagein)) == 2
            Imageout1 = cat(3,Imagein,Imagein,Imagein);% ���ڽ�ͼƬ��Ϊ3ͨ��
        end
        Imageout = imresize(Imageout1,[227,227]);
        imshow(Imageout)
        S = regexp(filepathin, '\', 'split');
        filepathouthead='C:\Users\coding\Desktop\matlab��ҵ\�����ҵ\ͼƬ��\';
        filepathout=strcat(filepathouthead,S(end-1),'\',S(end));
        filepathout=filepathout{1,1};
        imwrite(Imageout,filepathout);
        fprintf('%s is done\n',filepathout);
        %input.Files{i,1}=filepathout;
    end
end
