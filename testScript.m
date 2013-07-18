% Script to run en calc;

try
 test_localiseEN_Left
catch exception
    fprintf('Error left \n')
    
end

try
 test_localiseEN_Right;
catch exception
    fprintf('Error right\n')
    
end