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
