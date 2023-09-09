function [gtTrace, gtHR, gtTime] = loadPPG(vidFolder)
% load PPG recorded with pulse oximeter

gtHR = [];
gtTrace = [];
gtTime = [];

gtfilename=[vidFolder 'gtdump.xmp'];
if exist(gtfilename, 'file')==2
    gtdata=csvread(gtfilename);
    
    gtTrace=gtdata(:,4);
    gtTime=gtdata(:,1)/1000;
    gtHR = gtdata(:,2);
    
    % normalize data (zero mean and unit variance)
    gtTrace = gtTrace - mean(gtTrace,1);
    gtTrace = gtTrace / std(gtTrace);
        
else 
    gtfilename=[vidFolder 'ground_truth.txt'];
    if exist(gtfilename, 'file')==2
        gtdata=dlmread(gtfilename);
        gtTrace=gtdata(1,:)';
        gtTime=gtdata(3,:)' - gtdata(3,1); % TO REMOVE
        gtHR = gtdata(2,:)';
        
        % normalize data (zero mean and unit variance)
        gtTrace = gtTrace - mean(gtTrace,1);
        gtTrace = gtTrace / std(gtTrace);
      
    else
        gtfilename=[vidFolder 'Pulse Rate_BPM.txt']; 
        if exist(gtfilename, 'file')==2
            fileID = fopen(gtfilename,'r');
            gtHR = fscanf(fileID,'%f');
            fclose(fileID);
            gtTime = 0:numel(gtHR)-1;
            gtTime = gtTime(:)/1000;
            gtfilename=[vidFolder 'BP_MMHG.txt'];
            if exist(gtfilename, 'file')==2
                fileID = fopen(gtfilename,'r');
                gtTrace = fscanf(fileID,'%f');
                gtTrace = gtTrace - mean(gtTrace,1);
                gtTrace = gtTrace / std(gtTrace);
            end
            
        else
            fprintf('oops, no PPG file...\n');
        end
    end
end

