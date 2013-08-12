close all;clear all;


load 'c:\temp\dbDef_FRCT943_rangeOL'

noImages = size(dbFILES,2);

savePath = '.\frgcResults\';

for i  = 1:noImages
    range = dbFILES(i).rangeFile;
    texture = imread(dbFILES(i).textureFile);
    landmarks = dbFILES(i).landmarks;
    prn =  (landmarks(:,6));
    %%
    [X, Y, Z, fl] = absload(range);
    
    
    X(X<-1e5) = -inf;
    Y(Y<-1e5) = -inf;
    Z(Z<-1e5) = -inf;
    
    
    %%
    
    for f_iters = 1:2
        Z0 = Z;
        for jX = 3 : size(Z,2) - 2
            for jY = 3 : size(Z,1) - 2
                if isfinite( Z(jY, jX) )
                    localPatch = Z0(jY-2 : jY+2, jX-2: jX+2);
                    validPatch = localPatch( isfinite( localPatch ));
                    if not( isempty( validPatch ))
                        Z(jY, jX) = median( validPatch );
                    end
                end
            end
        end
    end
    
    %%
    Z1 = Z;
    Z1(Z1>-inf)= Z1(Z1>-inf) + abs(min(Z1(Z1>-inf)));
    Z1(Z1 == -inf) = 0;
    
    imageIn = Z1;
    imageIn2D = rgb2gray(im2double(texture));
    
    %%
    estimate = pixel2mm([335,243]);
    PRNLocation = localisePRN(imageIn,estimate,15,'false');
    
    %%
    %Change!
    [Output] = localiseAL_frgc(imageIn,PRNLocation,15,'false');
    
    ALLeftLocation = Output.ALLocation(1,:);
    ALRightLocation =Output.ALLocation(2,:);
    %EN localisation
    [Output] = localiseENLeft(imageIn,imageIn2D,PRNLocation,ALLeftLocation,ALRightLocation,'2D + 3D');
    ENLeftLocation = Output.EnLeftLocation;
    [Output] = localiseENright(imageIn,imageIn2D,PRNLocation,ALLeftLocation,ALRightLocation,'2D + 3D');
    ENRightLocation = Output.EnRightLocation;
    
    %M' Localisation
    MLocation  = (ENLeftLocation + ENRightLocation)./2;
    
    %EX localisation
    [Output] = localiseEXLeft(imageIn,imageIn2D,ENLeftLocation,ENRightLocation,'2D');
    EXLeftLocation = Output.ExLeftLocation;
    [Output] = localiseEXRight(imageIn,imageIn2D,ENLeftLocation,ENRightLocation,'2D');
    EXRightLocation = Output.ExRightLocation;
    
    %CH Localisation
    [Output] = localiseCHLeft(imageIn,imageIn2D,PRNLocation,ALLeftLocation,ALRightLocation,'2D + 3D');
    CHLeftLocation = Output.ChLeftLocation;
    [Output] = localiseCHRight(imageIn,imageIn2D,PRNLocation,ALLeftLocation,ALRightLocation,'2D + 3D');
    CHRightLocation = Output.ChRightLocation;
    
    results = [PRNLocation;ALLeftLocation;ALRightLocation;ENLeftLocation;ENRightLocation;MLocation;EXLeftLocation;EXRightLocation;CHLeftLocation;CHRightLocation];
    resultsFRGC = zeros(3,10);
    for y = 1:10
        currentResult = results(y,:);
        resultsFRGC(:,y) =  [X(mm2pixel(currentResult(2)),mm2pixel(currentResult(1)));...
            Y(mm2pixel(currentResult(2)),mm2pixel(currentResult(1)));...
            Z(mm2pixel(currentResult(2)),mm2pixel(currentResult(1)))];
    end
    
    locations.standard = results;
    locations.frgc = resultsFRGC;
    
    %Save result
    saveFileName = strcat(savePath,'frgc_',num2str(i));
     save(saveFileName,'locations');
end