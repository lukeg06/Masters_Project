function logError(CustomMessage,err_exception,errorLogfilePath)


fopen(errorLogfilePath,'a');
fprintf(errorLogfilePath,'%s\n\n',datestr(clock));

fprintf(errorLogfilePath,'%s\n',CustomMessage);
fprintf(errorLogfilePath,'%s\n','Error when trying to process scipt.');
fprintf(errorLogfilePath,'%s\n',err_exception.identifier);