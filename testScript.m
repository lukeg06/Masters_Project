try
      fprintf('Processing test_localiseEX_Right(3D)\n')
 test_localiseEX_Right('3D');
catch exception
    logError('EX Right 3D',exception,errorLogfilePath)
    
end

try
    fprintf('Processing test_localiseEN_Right(3D)\n')
 test_localiseEN_Right('3D');
catch exception
    logError('EN Right 3D',exception,errorLogfilePath)
    
end