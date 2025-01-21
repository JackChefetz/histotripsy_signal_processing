
%external function we are modifying
% This script is based on ORB algorithm <-----------
%This scripts takes an average of the Dataset being imported

function [tfm,pdeltaX,pdeltaZ,dXC,dZC]=ORB_FeatureTracking_2023August08v2_UR(RData, PData, Trans, move_UR)
persistent featuresOriginal
persistent validPtsOriginal
persistent fm1
%persistent URx
persistent prev_tranx 
persistent prev_tranz 
persistent trans_x_mm 
persistent trans_z_mm 
persistent count

% Image processing parameters
t1 = tic;
Size = PData.Size; 
Origin = PData.Origin;
pdeltaX = PData.PDelta(1);
pdeltaZ = PData.PDelta(3);                                                            
speedOfSound = 1540;
InterpFactor = 1;
Bx_lam = (0:Size(2)*InterpFactor-1)*pdeltaX/InterpFactor + Origin(1);
Bx_mm = Bx_lam / Trans.frequency * speedOfSound/1000;
Bz_lam = (0:Size(1)*InterpFactor-1)*pdeltaZ/InterpFactor + Origin(3);
Bz_mm = Bz_lam / Trans.frequency * speedOfSound/1000;
dZC = mean(diff(Bz_mm));
dXC = mean(diff(Bx_mm));
toc(t1)


% h = fspecial('disk', 1);
% process RData
% RData = imfilter(mean(squeeze(RData), 3),h);
RData = mean(squeeze(RData), 3);
dBR = 20; 

%log compress for standard US imaging, reduce dynamic range of pixel vals

tfm = 10*log10(RData/max(RData(:))); tfm(tfm < -dBR) = -dBR;
tfm = (tfm - min(tfm(:)))/(max(tfm(:)) - min(tfm(:)));
tfm = mat2gray(tfm); % frame index in greyscale

% imshow(tfm);
% pause

%Creating new baseline
% if BL_ID ==1
%     fm1 = tfm;
%     ptsOriginal =detectORBFeatures(fm1);
%     
%     [featuresOriginal, validPtsOriginal] = extractFeatures(fm1, ptsOriginal);
% 
% end



if count == 1
    prev_tranx=trans_x_mm;
    prev_tranz=trans_z_mm;
end 




if isempty(featuresOriginal) % if baseline already exists

    fm1 = tfm;
    ptsOriginal =detectORBFeatures(fm1);
    
    [featuresOriginal, validPtsOriginal] = extractFeatures(fm1, ptsOriginal);

    % figure; imshow(fm1); 
    % hold on;
    % plot(ptsOriginal);
    

else % if baseline does not exist, then create 
    % feature extraction
    ptsDistorted = detectORBFeatures(tfm);
    [featuresDistorted, validPtsDistorted] = extractFeatures(tfm, ptsDistorted);
   
    
    % Index pairs of points 
    % Recording
    indexPairs = matchFeatures(featuresOriginal, featuresDistorted,"Unique",true,"MatchThreshold",100,'MaxRatio',0.9); 
    matchedOriginal = validPtsOriginal(indexPairs(:,1));
    matchedDistorted = validPtsDistorted(indexPairs(:,2));
   
    FT_movement=matchedDistorted.Location -matchedOriginal.Location;

    FT_movement_X= FT_movement(:,1);
    FT_movement_Z= FT_movement(:,2);

    FT_movement_X= sort(FT_movement_X);
    FT_movement_Z= sort(FT_movement_Z);

    trans_x= median(FT_movement_X);
    trans_z= median(FT_movement_Z);
    trans_x_mm= trans_x*dXC;
    trans_z_mm= trans_z*dZC;
    
    
    count= 1;
    
    % Output translation
    display(sprintf('Movement along azimuth is %f mm and along range is %f mm.',trans_x_mm,trans_z_mm));
    
    % 
    figure(4);
    showMatchedFeatures(fm1,tfm,matchedOriginal,matchedDistorted);
    % % pause
    
    
    
    % Move robotic arm. Assumes we have already connected to the cobot
%     if isempty(URx) == 1
%         URx = -1;
%     else
%         URx = -1*URx;
%     end
    
    if move_UR == 1
%         % Connect to cobot
%         if ~ur.is_connected()
%             ur.connect()
% %             ur.gui_positioning()
% %             connect2UR()
%         end
        
        % Let's not move more than like 10 mm total
        if sqrt( trans_x_mm^2 +  trans_z_mm^2) < 10
            ur.move_relative([trans_x_mm 0 trans_z_mm 0 0 0]/1000);
%             ur.move_relative([URx 0 URx 0 0 0]/1000);
        else
            fprint('\nToo far out of range');
        end
    end
    
    
    
%       if abs(prev_tranx - trans_x_mm) > 0.50 | abs(prev_tranz - trans_z_mm) > 0.50
%          ur.move_relative([trans_x 0 trans_z 0 0 0]/1000)
% 
%       end 

  


      
end

end
