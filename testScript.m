% Script to run en calc;
close all
clear all

% Test EN localisations. Should takes 24hrs.
try
 test_localiseEN_Left('2D')
catch exception
    fprintf('Error left \n')
    
end

try
 test_localiseEN_Left('3D')
catch exception
    fprintf('Error left \n')
    
end


try
 test_localiseEN_Right('3D');
catch exception
    fprintf('Error right\n')
    
end