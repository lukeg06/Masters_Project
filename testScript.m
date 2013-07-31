close all;clear all;

errorLogfilePath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\ERROR.log.txt';

try
      fprintf('Processing test_localiseCH_Left(2D3D)\n')
 test_localiseCH_Left('2D + 3D');
catch exception
    logError('CH Left 2D + 3D',exception,errorLogfilePath)
    
end


try
      fprintf('Processing test_localiseCH_Right(2D3D)\n')
 test_localiseCH_Right('2D + 3D');
catch exception
    logError('CH Right 2D + 3D',exception,errorLogfilePath)
    
end

% try
%       fprintf('Processing test_localiseCH_Left(3D)\n')
%  test_localiseCH_Left('3D');
% catch exception
%     logError('CH Left 3D',exception,errorLogfilePath)
%     
% end
% try
%       fprintf('Processing test_localiseCH_Left(2D)\n')
%  test_localiseCH_Left('2D');
% catch exception
%     logError('CH Left 2D',exception,errorLogfilePath)
%     
% end
% 
% 

