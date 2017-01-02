function [ct] = how_many ( prefix, ct_f, num_f )
%prefix - name of video folder
%ct_f - vector of frames used for grading
%num_f - number of frames

%i is an array of integers from 1 to the number of frames
i = [1:num_f];

%load an image
fn = sprintf ( '%sFRM_%05d.png%', prefix, i);
img = imread ( fn );

[R , C , L] = size(img);
%num_f = 100;
imMean= (zeros(R , C , L));
%images = cell(num_f , 1);
sigma = .5;
%{%
for n=1:num_f
    fn = sprintf ( '%sFRM_%05d.png%', prefix, n);
  %images{n , 1} = im2double(imread(fn));
  tempImage = im2double(imread(fn));
  imMean = (imMean +  tempImage);
 %imMean = imMean + imgaussfilt(images{n , 1},sigma);
end

imMean = (imMean ./ num_f);
%}
%imMean = im2double(imread('sMean.jpg'));
%Some random numbers get returned

sz = size(imMean);
for x=1:numel(ct_f)
   % backSub = imMean - images{ct_f(x) , 1};
   sum = 0;
   range = 2;
  % for b = -range : range
      id = ct_f(x) ;%+ b ;
      %{
       if(id > num_f)
           id = ct_f(x) - b - b;
       end;
       if(id < 1)
           id = ct_f(x) + b + b;
       end;
      %}
     fn = sprintf ( '%sFRM_%05d.png%', prefix, id);
    im = im2double(imread(fn));
    border = 10;
    
    backSub = imMean - im;
    %backSub = imgaussfilt(backSub ,sigma);
    %{
    backSub(1 : border , : , :) = 0;
    backSub(sz(1)- border : sz(1) , : , :) = 0;
    backSub(: , 1 : border  , :) = 0;
    backSub(: , sz(2) - border :sz(2) , :  ) = 0;
    %}
    
    ch = 2;
   %cr = count(backSub , 1);
   cg = count(backSub , 2);
   %cb = count(backSub , 3);
   ct(x) = cg;%round((cr + cg + cb) / 3 );
    %cmap = rand(ct(x)  , 3); 
    % figure; imshow(bwLab , []); title(x);
     %colormap (cmap);
end

function c = count(backSub , ch)
    lev = graythresh(backSub(:,:,ch));
    binR = im2bw(backSub(:,:,ch) , lev);
    %binR = im2bw(backSub);
    mFsz = 3;
    midR = medfilt2(binR ,[mFsz ,mFsz]);
    st =  [1 0 0 ; 0 1 0 ; 0 0 1];
    st = [1 0; 0 1];
    st = strel('sphere',1);
    bwMor = midR;
    
  %  stats = regionprops(bwMor , 'Centroid');
    %bwMor = imerode(midR , st);
    
    %bwMor = bwmorph(midR , 'open');
    %bwMor = bwmorph(midR , 'thin');
    
    bwLab = uint8(bwlabel(bwMor));
    stats = regionprops(bwMor , 'Area' , 'Centroid' );
    ar = [stats.Area];
    mAr = mean(ar);
    [hsV , hsB] = hist(ar , size(ar,2));
    [vHs , idx ] = max(hsV(2:end));
    vMax = hsB(idx + 1);
    
     [vHs , idx ] = min(hsV(2:end));
    vMin = hsB(idx + 1);
    %{
    cr = [stats.Centroid];
    cr = reshape(cr  , 2 , uint8(size(cr ,2)/2))';
    vr = var(cr);
    %}
     %figure; imshow(bwLab , []); title(x);
    for i = 1 : numel(ar)
        if(ar(i) <=  85) %100 = 71  / 80 =  76/ 85 = 80
            bwLab(bwLab == i) = 0;
        end;
    end
    %bwLab = imdilate(bwLab , st);
   % bwLab = imerode(bwLab , st);
    %bwLab = bwmorph(bwLab , 'open');
     bwLab2 = (bwlabel(bwLab > 0));
    %bwLab = bwmorph(bwLab , 'majority');
    % sum = sum + max(max(bwLab));
   %end;
    %ct(x) = ceil(sum/(range + range + 1)) ;%randi(99)+1;
    %debug = true;
    if(x == 100)
    figure; imshow(backSub , []); title('backSub');
    figure; imshow(binR , []); title('binR');
    figure; imshow(midR , []); title('midR');
    figure; imshow(bwMor , []); title('morph');
     figure; imshow(bwLab , []); title('lebal 0');
    figure; imshow(bwLab2 , []); title(x);
    end;
    %figure; imshow(bwLab2 , []); title(x);
   c =  max(max(bwLab2));
end
end