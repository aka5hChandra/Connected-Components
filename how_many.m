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

imMean= (zeros(R , C , L));

%Obtain Background
for n=1:num_f
  fn = sprintf ( '%sFRM_%05d.png%', prefix, n);
  tempImage = im2double(imread(fn));
  imMean = (imMean +  tempImage);
end

imMean = (imMean ./ num_f);


for x=1:numel(ct_f)
   range = 8;
   allCount = zeros(1 , 5);
   c = 1;
   for b = -range : 4 : range
      id = ct_f(x) + b ;
       if(id > num_f)
           if(c == 4)
                id = ct_f(x) - 2 ;%- b - b;
           else 
                 id = ct_f(x) - 6 ;
           end;
       end;
       if(id < 1)
           if(c == 2)
            id = ct_f(x)  + 2;%+ b + b;
           else
               id = ct_f(x)  + 6; 
           end;
       end;
     fn = sprintf ( '%sFRM_%05d.png%', prefix, id);

    im = im2double(imread(fn));  
    backSub = imMean - im;
    [R , C] = size(backSub);
    border = 30;%50;
    
    backSub(1 : border , : ) = 0;
    backSub(R - border : R, : ) = 0;
    backSub( : , 1 : border ) = 0;
    backSub( : , C -  border: C ) = 0;
    
    ch = 2;
    cg = count(backSub , ch);
    allCount(c) = cg;
    c = c + 1;
    end;
     
     ct(x) = ceil(mean(allCount));
end

%background substraction
function c = count(backSub , ch)
    lev = graythresh(backSub(:,:,ch));
    binR = im2bw(backSub(:,:,ch) , lev);
    mFsz = 3;
    midR = medfilt2(binR ,[mFsz ,mFsz]);
    bwMor = midR;
    bwLab = uint8(bwlabel(bwMor));
    stats = regionprops(bwMor , 'Area' , 'Centroid' );
    ar = [stats.Area];
 
    for w = 1 : numel(ar)
        if(ar(w) <=  85) %100 = 71  / 80 =  76/ 85 = 80
            bwLab(bwLab == w) = 0;
        end;
    end
     bwLab2 = (bwlabel(bwLab > 0));
    debug = false;
    if(debug)
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