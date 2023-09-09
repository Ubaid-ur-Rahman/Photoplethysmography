function getPulseSignalFromTrace(varargin)
% Get pulse trace from RGB traces
% contact: yannick.benezeth@u-bourgogne.fr

tic
close all;
clc;

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
    if(strcmp(varargin{i},'METHOD')==1)
        METHOD=varargin{i+1};
    end
    i = i+2;
end

matFileName = 'rgbTraces'; % input file

fprintf('Get pulse from RGB trace: %s%s.mat \n',VIDFOLDER, matFileName);
fprintf('METHOD=%s \n',METHOD);
fprintf('VERBOSE=%i \n',VERBOSE);
fprintf('Processing...');

% load PPG
[gtTrace, gtHR, gtTime] = loadPPG(VIDFOLDER);

% load RGB traces
if(exist([VIDFOLDER matFileName '.mat'], 'file') == 2)
    load([VIDFOLDER matFileName '.mat']);
else
    disp('oops, no input file');
    return;
end

% get current traces
timeTrace = rgbTraces(end,:);
timeTrace = timeTrace/1000; % in second
crtTrace = rgbTraces(1:3,:);
traceSize = size(crtTrace,2);

if (VERBOSE == 2)
    figure(1);
    hold on
    plot(timeTrace,crtTrace(1,:),'Color',[.8,.1,.3], 'Linewidth', 1.5);
    plot(timeTrace,crtTrace(2,:),'Color',[.1,.8,.3], 'Linewidth', 1.5);
    plot(timeTrace,crtTrace(3,:),'Color',[.1,.1,.8], 'Linewidth', 1.5);
    title('Traces RGB');
    ylim([0 255]);
    legend('R','G', 'B');
    xlabel('Secondes') 
    ylabel('RGB values') 

    figure(2)
    plot(gtTime,gtTrace, 'Color', 'k')
    legend('PPG');
    xlabel('Secondes') 
    ylabel('PPG values') 
end

% normalization
crtTrace = (crtTrace-mean(crtTrace, 2))./std(crtTrace, 0, 2);


if (VERBOSE == 2)
    figure(3);
    hold on
    p1 = plot(timeTrace,crtTrace(2,:)/std(crtTrace(2,:)),'Color',[.1,.8,.3], 'Linewidth', 1.);
    p2 = plot(gtTime, gtTrace/std(gtTrace), 'k');
    legend([p1,p2],'Green channel', 'PPG');
    xlim([5, 25]);
    title('Normalized green');
end


% channel combination
switch METHOD
    case 'Green'
        % Method 1: Green channel
        pulseTrace = crtTrace(2,:);
        
    case 'G-R'
        % Method 2: G-R (to be implemented)
        pulseTrace = crtTrace(2,:);
        
    case 'Chrom'
        % Method 3: CHROM (to be implemented)
        pulseTrace = crtTrace(2,:);
        
    otherwise
        warning('invalid method name');
end

% plot traces
if(VERBOSE >= 1)
    figure(5),hold on;  
    plot(gtTime, gtTrace/max(gtTrace), 'k');  
    plot(timeTrace, pulseTrace/max(pulseTrace), 'b', 'Linewidth', 1.1);  
    xlim([5 25]),  
    title('Signal rPPG');
     xlabel('Secondes')  
end


% save to mat files
save([VIDFOLDER 'pulseTrace.mat'], 'pulseTrace', 'timeTrace');

%close all
fprintf('\n');
fprintf('done in %i seconds\n', round(toc));
