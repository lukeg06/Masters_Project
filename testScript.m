% Script to run en calc;
close all
clear all


% try
%  test_localiseEX_Left('2D + 3D')
% catch exception
%     fprintf('Error left \n')
%     
% end
errorLogfilePath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\log_testScript.txt';

try
 test_localiseEX_Right('2D + 3D');
catch exception
    logError('EX Right 2D + 3D',exception,errorLogfilePath)
    
end


% 
% try
%  test_localiseEX_Left('2D')
% catch exception
%     fprintf('Error left \n')
%     
% end
% 
% try
%  test_localiseEX_Left('3D')
% catch exception
%     fprintf('Error left \n');
%     
% end

% 
try
 test_localiseEX_Right('2D');
catch exception
    logError('EX Right 2D',exception,errorLogfilePath)
    
end

try
 test_localiseEX_Right('3D');
catch exception
    logError('EX Right 3D',exception,errorLogfilePath)
    
end