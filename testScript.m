close all;clear all;

errorLogfilePath = 'C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\ERROR.log.txt';
testLog = fopen('C:\Documents and Settings\Luke\My Documents\Masters_Project\Results\testLog','w');
ans_out = inputdlg({'Please enter test description'},'Test',1,{'0'});
fprintf(testLog,ans_out{:});

try
     
 frgctest;
catch exception
   
    
end

% 
% try
%       fprintf('Processing test_localiseCH_Right(2D3D)\n')
%  test_localiseCH_Right('2D + 3D');
% catch exception
%     logError('CH Right 2D + 3D',exception,errorLogfilePath)
%     
% end
% 
% % 
% 
% 
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
% 
% 
% try
%       fprintf('Processing test_localiseCH_Right(3D)\n')
%  test_localiseCH_Right('3D');
% catch exception
%     logError('CH Right 3D',exception,errorLogfilePath)
%     
% end
% try
%       fprintf('Processing test_localiseCH_Right(2D)\n')
%  test_localiseCH_Right('2D');
% catch exception
%     logError('CH Right 2D',exception,errorLogfilePath)
%     
% end
% 
% try
%       fprintf('Processing test_localiseCH_Right(2D)\n')
%  testLocalisePRNSegundo;
% catch exception
%    
%     
% end


clear all;
close all;

zipFile = strcat('C:\Documents and Settings\Luke\My Documents\Dropbox\Project results\Results_Zips\results',datestr(now,30));
zip(zipFile,'./Results')


