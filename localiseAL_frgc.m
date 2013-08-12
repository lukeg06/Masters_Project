function [Output] = localiseAL_frgc(imageIn,prnLocation,sigma,show)

 error = 0;
    %Error codes
    %1 = search region two small
    %2 = left point not detected 1st time
    %3 = right point not detected 1st time
    %
 
     window = [50 42];
     window2 = [60 42];
    [Output] =localiseAL3_widest(imageIn,prnLocation,window,sigma,show,'right','false');
    ALLocation = Output.ALLocation;
    
%     
%     if ALLocation == 0
%         error = 1;
%         [Output] = localiseAL3_widest(imageIn,prnLocation,window2,sigma,'false','right','false');
%         ALLocation = Output.ALLocation;
%     end
%     
%     if ALLocation == 0
%         fprintf(test_localiseALRightResultsFileID,'%d\n',i);
%         fprintf(test_localiseALLeftResultsFileID,'%d\n',i);
%         fprintf('Error in image %d \n',i);
%         continue;
%         
%     end
%     
%     if isempty(ALLocation)
%          error = 1;
%         [Output] = localiseAL3_widest(imageIn,prnLocation,window2,sigma,'false','right','false');
%         ALLocation = Output.ALLocation;
%     end
%     
%     if isempty(ALLocation)
%         fprintf(test_localiseALRightResultsFileID,'%d\n',i);
%         fprintf(test_localiseALLeftResultsFileID,'%d\n',i);
%         fprintf('Error in image %d \n',i);
%         continue;
%     end
    
    % Try expanding search region. 5mm each side.
    if size(ALLocation,1) ~= 2
         error = 1;
        [Output] = localiseAL3_widest(imageIn,prnLocation,window2,sigma,show,'right','false');
        ALLocation = Output.ALLocation;
    end
    
    % If expanding didn't work then try looking searching for other
    % contour.
    
    if size(ALLocation,1) ~= 2
        
        if isequal(Output.errors,[0,1])
             error = 3;
            reverse = 'true';
            [Output] =localiseAL3_widest(imageIn,prnLocation,[50 42],sigma,show,'right',reverse);
            ALLocation = Output.ALLocation;
            leftAL = ALLocation;
            
            
            %left point detected. Get the right.
            [Output] = localiseAL3_widest(imageIn,prnLocation,[50 42],sigma,show,'right',reverse);
            rightAL = Output.ALLocation;
            ALLocation = [leftAL;rightAL];
        elseif isequal(Output.errors,[1,0])
             error = 2;
            reverse = 'true';
            [Output] =localiseAL3_widest(imageIn,prnLocation,[50 42],sigma,show,'right',reverse);
            ALLocation = Output.ALLocation;
            rightAL = ALLocation;
            %right detected. Get left.
            [Output] = localiseAL3_widest(imageIn,prnLocation,[50 42],sigma,show,'left',reverse);
            leftAL = Output.ALLocation;
            ALLocation = [leftAL;rightAL];

        end
    end
    
    