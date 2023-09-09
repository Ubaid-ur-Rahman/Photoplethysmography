function [result, HR_PPG, HR_RPPG] = getHRFromPulse(varargin)
    % Extract HR from pulse trace
    % contact: yannick.benezeth@u-bourgogne.fr
     
    result = [];
    HR_PPG = [];
    HR_RPPG = [];
    HR_sensor = [];
    
    tic
    close all;

    addpath('./tools/BlandAltman/');

    %%%%%%%%%%%
    % Parameters
    %%%%%%%%%%%
    
    i = 1;
    while(nargin > i)
        if(strcmp(varargin{i},'VIDFOLDER')==1)
            VIDFOLDER=varargin{i+1};
        end
        if(strcmp(varargin{i},'VERBOSE')==1)
            VERBOSE=varargin{i+1};
        end
        i = i+2;
    end

    matFileName = 'pulseTrace'; % input file
    
    pulseFile = [VIDFOLDER matFileName '.mat'];
    if(exist(pulseFile, 'file') == 2)
        load(pulseFile);
    else
        disp('oops, no input file');
        return;
    end
    
    fprintf('Processing...');
        
    traceSize = length(timeTrace);
    
    % get exact Fs
    Fs = 1/mean(diff(timeTrace));
        
    % load PPG
    [gtTrace, gtHR, gtTime] = loadPPG(VIDFOLDER);

    if(VERBOSE == 2)
        figure(1);
        hold on;
        p1 = plot(gtTime, gtTrace/max(gtTrace), 'k');
        p2 = plot(timeTrace, pulseTrace/max(pulseTrace), 'b', 'Linewidth', 1.5);
        xlim([5 25]),
        title('Final rPPG trace');
        legend([p1 p2], 'PPG', 'rPPG');
        hold off;
        pause(0.1)
    end

    winLengthSec = 15; % length of the sliding window (in seconds) for the FFT
    stepSec = 0.5; % step between 2 sliding window position (in seconds)
    winLength = round(winLengthSec*Fs); % length of the sliding window for FFT
    step = round(stepSec*Fs);

    ind = 1;
    halfWin = (winLength/2);
    for i=halfWin:step:traceSize-halfWin

        %%%%%%%%%%%%%%
        % Get current windows
        %%%%%%%%%%%%%%
        % get start/end index of current window
        startInd = i-halfWin+1;
        endInd = i+halfWin;
        startTime = timeTrace(startInd);
        endTime = timeTrace(endInd);

        % get current pulse window
        crtPulseWin = pulseTrace(startInd:endInd);
        crtTimeWin = timeTrace(startInd:endInd);

        % get current PPG window
        [~, startIndGt] = min(abs(gtTime-startTime));
        [~, endIndGt] = min(abs(gtTime-endTime));
        crtPPGWin = gtTrace(startIndGt:endIndGt);
        crtTimePPGWin = gtTime(startIndGt:endIndGt);
        

        if (VERBOSE == 2)
            fig2 = figure(2);
            clf(fig2);
            hold on;
            plot(crtTimePPGWin, crtPPGWin/max(crtPPGWin), 'k')
            plot(crtTimeWin, crtPulseWin/max(crtPulseWin), 'b', 'Linewidth', 1.5);
            legend('PPG', 'Pulse trace'),
            hold off;
            pause(0.1);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Your code here %%%%%%%%%

        hr_ppg = 60;
        hr_rppg = 60;

                
         %%% end of your code here %%%
         %%%%%%%%%%%%%%%%%%%%%%*******




        %%%%%%%%%%%%%%%%%%
        % save estimations
        %%%%%%%%%%%%%%%%%%
        % time
        crtTime =  (startTime + endTime)/2;
        time(ind) = crtTime;
        
        % HR from PPG
        HR_PPG(ind) = hr_ppg;
        [~, crtTimeInd] = min(abs(gtTime-crtTime));
        HR_sensor(ind) = gtHR(crtTimeInd);
         
        % HR from rPPG
        HR_RPPG(ind) = hr_rppg;
               
        ind=ind+1;
    end

    
  
    %%%%%%%%%%%%%%%%%%
    % metrics
    %%%%%%%%%%%%%%%%%
    
    showBlandAltman(HR_PPG, HR_RPPG);

    if (VERBOSE >= 1)
        
        fig5 = figure(5);
        hold on;grid on;
        plot(time,HR_PPG, 'b-*', 'MarkerSize',5);
        plot(time,HR_RPPG, 'r-*','MarkerSize',5);
        plot(time,HR_sensor, 'k-*', 'MarkerSize',5);
        legend('PPG', 'RPPG', 'sensor')
        ylim([40, 140]);
        title('HR values'), xlabel('time');
        hold off;

    end

        
    fprintf('done in %i seconds\n', round(toc));
end
