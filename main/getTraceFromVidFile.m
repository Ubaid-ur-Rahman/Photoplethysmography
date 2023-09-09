function getTraceFromVidFile(varargin)
% extract RGB traces from vid file
% contact: yannick.benezeth@u-bourgogne.fr

    tic
    close all;
    clc;
    
    addpath('./tools/skindetector');
    
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
    
    DoSkinDetection = 0; % 0: ROI is the face, 1: ROI is the skin mask
   
    vidFileName='vid.avi';
    
    fprintf('Get RGB traces from: %s%s \n',VIDFOLDER,vidFileName);
    fprintf('VERBOSE=%i \n',VERBOSE);
    fprintf('Processing...');  
    
    %Default filename for the full face without skin or crop
    outFileName ='rgbTraces';
    
    % Create a cascade detector object.
    faceDetector = vision.CascadeObjectDetector('ClassificationModel','FrontalFaceCART','MinSize',[100 100]);
    % Create the point tracker object.
    pointTracker = vision.PointTracker('MaxBidirectionalError', 5);
    
    if (exist([VIDFOLDER outFileName '.mat'], 'file') == 2)
        clc;
        fprintf('rgbTraces file exists, just skip getTraceFromVidFile()... \n');
        return;
    end
    
    % Video Handler
    vidObj = VideoReader([VIDFOLDER vidFileName]);
    fps = vidObj.FrameRate;
    
    nbFrame = vidObj.FrameRate * vidObj.Duration;
    rgbTraces = zeros(4, nbFrame);
    
    numPts = 0;
    n=0;
    tic;
    
    while hasFrame(vidObj)
        
        n=n+1;
        % read frame by frame 
        img = readFrame(vidObj);
        img_copy = img;
        
        % face localisation by detection then tracking
        if numPts < 10
            % Detection mode.
            bbox  = step(faceDetector, img);
            fprintf('\n face detection \n');
            
            bbox = bbox(1,:); % if we have several faces
            
            scaleX = 1;
            scaleY = 1.5;
            offsetX = 0.;
            offsetY = 0.1;
            bbox2(1) = max(1, bbox(1) + bbox(3) * (offsetX + (1 - scaleX) / 2));
            bbox2(2) = max(1, bbox(2) + bbox(4) * (offsetY + (1 - scaleY) / 2));
            bbox2(3) = bbox(3) * scaleX;
            bbox2(4) = bbox(4) * scaleY;
            bbox = bbox2;
                
            % initialize tracker
            % Find corner points inside the detected region.
            points = detectMinEigenFeatures(rgb2gray(img), 'ROI', bbox(1, :));
            
            % Re-initialize the point tracker.
            xyPoints = points.Location;
            numPts = size(xyPoints,1);
            release(pointTracker);
            initialize(pointTracker, xyPoints, img);
            
            % Save a copy of the points.
            oldPoints = xyPoints;
            
            % Convert the rectangle represented as [x, y, w, h] into an
            % M-by-2 matrix of [x,y] coordinates of the four corners. This
            % is needed to be able to transform the bounding box to display
            % the orientation of the face.
            x = bbox(1, 1);
            y = bbox(1, 2);
            w = bbox(1, 3);
            h = bbox(1, 4);
            bboxPoints = [x,y;x,y+h;x+w,y+h;x+w,y];
            
            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);
            
            % Display a bounding box around the detected face.
            img = insertShape(img, 'Polygon', bboxPolygon);
            
            % Display detected corners.
            img = insertMarker(img, xyPoints, '+', 'Color', 'white');
            
        else
            % Tracking mode.
            [xyPoints, isFound] = step(pointTracker, img);
            %fprintf('%i %f\n', n, xyPoints(1))
            visiblePoints = xyPoints(isFound, :);
            oldInliers = oldPoints(isFound, :);
            
            numPts = size(visiblePoints, 1);
            %fprintf('%i %f\n', n, numPts)
            
            if numPts >= 10
                % Estimate the geometric transformation between the old points
                % and the new points.
                [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
                    oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
                
                % Apply the transformation to the bounding box. [xi yi], 4x2
                bboxPoints = transformPointsForward(xform, bboxPoints);
                Min=min(bboxPoints);
                Max=max(bboxPoints);
                
                bbox=[Min(1) Min(2) Max(1)-Min(1) Max(2)-Min(2)];
                % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
                % format required by insertShape.
                bboxPolygon = reshape(bboxPoints', 1, []);
                
                %Save to bbox [x1 y1 w h]
                % Display a bounding box around the face being tracked.
                img = insertShape(img, 'Polygon', bboxPolygon);
                
                % Display tracked points.
                img = insertMarker(img, visiblePoints, '+', 'Color', 'white');
                
                % Reset the points.
                oldPoints = visiblePoints;
                setPoints(pointTracker, oldPoints);
            end
        end
        
        % once we have the face location -> we extract the RGB value
        if ~isempty(bbox)
          
            if(VERBOSE == 2)
                figure(1), imshow(img), title('Detected Face 1');
            end
            
            imgROI = imcrop(img_copy,bbox(1,:));
    
            if(VERBOSE == 2)
                figure(2), imshow(imgROI), title('Detected Face 2');
            end
            
            if (DoSkinDetection)

               
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%% Your code here %%%%%%%%%


                
                %%% end of your code here %%%
                %%%%%%%%%%%%%%%%%%%%%%*******

            else
                avg = mean(mean(imgROI, "omitnan"), "omitnan");
               
            end
            
            
            if(VERBOSE == 2)
                figure (3), imshow(imgROI), title('Detected Face + skin');
                pause(0.1);
            elseif ((mod(n,50) == 0)||(n==2))
                if (VERBOSE == 1)
                    figure(1), imshow(imgROI), title('Detected Face + skin');
                    pause(.01);
                end
            end
        end
        
        
        
        %get timestamp from fps
        time = n/fps*1000;
        rgbTraces(1:3,n) = avg;
        rgbTraces(4,n) = time;   
        
        
        % verbose stuff
        if (mod(n,50) == 0)
            if (VERBOSE >= 1)
                fprintf('\n %.2f sur %.2f sec', time/1000,vidObj.Duration);
            else
                fprintf('.');
            end
        end
    end
    
    save([VIDFOLDER outFileName '.mat'], 'rgbTraces');
    
    toc;
    close all;
    fprintf('\n');
    fprintf('done in %i seconds\n', round(toc));
end
