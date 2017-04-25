function [newXs, newYs] = predictTranslation(startXs, startYs, im0,im1)

N = length(startXs);
window = 15;
half_size = (window-1)/2;
window_length = window^2;

[rows, cols] =size(im0);

rows = rows-half_size;
cols = cols-half_size;

newXs=startXs;
newYs=startYs;

%%Find Ix and Iy of im0
dx =[-0.5 0 0.5];
dy =[-0.5 ;0 ;0.5];
Ix = imfilter(im0,dx);
Iy = imfilter(im0,dy);

for i=1:1:N
      
    if(floor(newXs(i))>half_size & floor(newYs(i))>half_size & ceil(newYs(i))<=rows & ceil(newXs(i))<=cols)
       
    range_x =(floor(newXs(i))-half_size):(ceil(newXs(i))+half_size);
    range_y =(floor(newYs(i))-half_size):(ceil(newYs(i))+half_size);
    [back_x, back_y] =meshgrid(range_x,range_y);
    
    [mesh_x, mesh_y] =meshgrid((startXs(i)-half_size):(startXs(i)+half_size),(startYs(i)-half_size):(startYs(i)+half_size));
    
   
    Ix_sub = reshape(interp2(back_x,back_y,Ix(range_y,range_x),mesh_x,mesh_y),[window_length 1]);
    Iy_sub = reshape(interp2(back_x,back_y,Iy(range_y,range_x),mesh_x,mesh_y),[window_length 1]);
    im0_sub = reshape(interp2(back_x,back_y,im0(range_y,range_x),mesh_x,mesh_y),[window_length 1]);
    im1_sub = reshape(interp2(back_x,back_y,im1(range_y,range_x),mesh_x,mesh_y),[window_length 1]);
    
    
    A = [Ix_sub Iy_sub];
    b = -(im1_sub - im0_sub);
    uv = pinv(A'*A)*(A'*b);

    
    newXs(i) = newXs(i)+uv(1);
    newYs(i) = newYs(i) +uv(2);
    val = sum(abs(uv));
    j=1;
    while(val<10^-5 && j<30)
        if(newXs(i)>half_size && newYs(i)>half_size && newYs(i)<=rows && newXs(i)<=cols)
            
            range_x =(floor(newXs(i))-half_size):(ceil(newXs(i))+half_size);
            range_y =(floor(newYs(i))-half_size):(ceil(newYs(i))+half_size);
            [back_x, back_y] =meshgrid(range_x,range_y);
            [mesh_x, mesh_y] =meshgrid((startXs(i)-half_size):(startXs(i)+half_size),(startYs(i)-half_size):(startYs(i)+half_size));
            
            im1_sub = reshape(interp2(back_x,back_y,im1(range_y,range_x),mesh_x,mesh_y),[window_length 1]);
            
            A = [Ix_sub Iy_sub];
            b = -(im1_sub - im0_sub);
            uv = pinv(A'*A)*(A'*b);
            
            newXs(i) = newXs(i)+uv(1);
            newYs(i) = newYs(i) +uv(2);
            val = sum(abs(uv));
            j =j+1;
            
        else
            newXs(i) =-1;
            newYs(i) =-1;
        end
    end
    
    else
    newXs(i) = -1;
    newYs(i) = -1;
    end
   
end

% plot_pointX = find(newXs>0);
% figure
% imshow(im1);hold on;
% plot(newXs(plot_pointX),newYs(plot_pointX),'g.', 'MarkerSize',5);

end