function rangeLmks = facialLandmarks_Segundo2010 (X, Y, Z, varargin)
% rangeLmks = facialLandmarks_Segundo2010 (X, Y, Z, [options])
% Facial landmarks localization using the method by Segundo et al. 2010
% "Automatic Face Segmentation and Facial Landmark Detection in Range
% Images", IEEE Trans. Systems, Man and Cybernetics - Part B
% 
% INPUT: A pro-processed range image (only an elliptic region containing
% the face is acceptable). All pre-processing steps detailed in the paper
% have been skipped (it is assumed the detection has been successfully done
% in advance), except a 5x5 median filter applied twice to the depth data
% to remove noise.
%
% OPTIONS:
% 'nofilter', skip the median filtering step
% 'kh_thresholds', thresh_H, thresh_K
% Specify the thresholds to use for segging H and K to zero
% If not specified, thresholds are determined by outlier analysis
% Some suggestions:
% - Segundo et al. used 0.003 for both thresh_H and thresh_K
% - Colombo et al. (2006) suggest thresh_H = 0.04 and thresh_K = 0.0005
% - Basl and Jain (1988) used larger values, probably due to noisier data
% (notice the year): thresh_H = 0.03 and thresh_K = 0.015
%
% 'xNose_rows', N
% Number of rows to use as 'neighboring rows' for the detection of the NOSE
% TIP x-coordinate (actually 2 * N + 1 is used). Default = 12
%
% 'xEyes_rows', N
% Number of rows to use as 'neighboring rows' for the detection of
% EYE-CORNERS x-coordinate (actually 2 * N + 1 is used). Default = 5
%
% 'triangle_mask', b
% Enable (b = 1) or Disable (b = 0) the use of a triangular mask cenetered at
% the nose tip to down-weight possible peaks on the sides of the face.
% Default is ENABELED
%

% Default settings and input arguments
% -------------------------------------------------------------
thresh_H = 0;
thresh_K = 0;
xNose_rows = 12;
xEyes_rows = 5;
use_triangle_mask = true;
do_filtering = true;

while not( isempty( varargin ))
    if strcmpi( varargin(1), 'kh_thresholds' )
        if length( varargin ) < 3
            error('Two thresholds are needed for kh_thresholds');
        end
        thresh_H = varargin{2};
        thresh_K = varargin{3};
        fprintf(1, '\tK-H thresholds set to %f, %f\n', ...
            thresh_H, thresh_K);
        varargin(1:3) = [];
    else
        if strcmpi( varargin{1}, 'xNose_rows' )
            xNose_rows = varargin{2};
            fprintf(1, '\tNose-neighboring rows set to %d\n', ...
                xNose_rows);
            varargin(1:2) = [];
        else
            if strcmpi( varargin{1}, 'xEyes_rows' )
                xEyes_rows = varargin{2};
                fprintf(1, '\tEyes-neighboring rows set to %d\n', ...
                    xEyes_rows);
                varargin(1:2) = [];
            else
                if strcmpi( varargin{1}, 'triangle_mask' )
                    if varargin{2} == 0
                        use_triangle_mask = false;
                    end
                    fprintf(1, '\tUse of triangle mask: ');
                    if use_triangle_mask
                        fprintf(1, 'Enabeled\n');
                    else
                        fprintf(1, 'Disabeled\n');
                    end
                    varargin(1:2) = [];
                else
                    if strcmpi( varargin{1}, 'nofilter' )
                        do_filtering = false;
                        varargin(1) = [];
                    else
                        fprintf(1, 'Unrecognized parameter: %s\n', varargin{1});
                        error('Function aborted');
                    end
                end
            end
        end
    end
end


rangeLmks = struct();


% ----------------------------------------------------------
%
% 0.- Apply a 5x5 median filter (twice)
%
% ----------------------------------------------------------
fprintf(1, '\tMedian filtering');
if do_filtering
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
else
    fprintf(1, ' \t Skipped');
end
fprintf(1, '\n');


% ----------------------------------------------------------
%
% 1.- NOSE TIP y-coordinate
%
% ----------------------------------------------------------
% Project depth data into Y axis: for all pixels sharing the same y value,
% get the maximum (max-profile) and the median (median-profile) range values. 
% Compute the difference between them and look for the maximum. 
% The local peak of the max-profile curve that is closest to the maximum
% difference (max-profile - median-pdofile) is the located y-coordinate for
% the nose tip

fprintf(1, '\tDepth y-profile');
maxY = -inf * ones(1, size(Z, 1));
medY = maxY;

for jY = 1 : size( Z, 1 )
    temp_y = Z(jY, :);
    valid_idx = find( isfinite( temp_y ));
    if not( isempty( valid_idx ))
        maxY( jY ) = max( temp_y( valid_idx ));
        medY( jY ) = median( temp_y( valid_idx ));
    end
end

max_to_med = ( maxY - medY );

% ----- /////////////////////////////////////////////////////// -------
% ----- THIS PART IS AN AD-HOC ADDITION TO HANDLE THE FACT THAT -------
% ----- WE DON'T REALLY HAVE A DETECTION STEP AND THE UPPER AND -------
% ----- LOWER PARTS OF THE FACE GENERATE STRONG FALSE PEAKS -----------

% Discard the region that is too close to the borders
not_face = find( medY <= 0 );
d_not_face = not_face(2:end) - not_face(1:end-1);
forehead_lim = not_face( find( d_not_face > 1, 1, 'first' ) );
chin_lim = not_face( find( d_not_face > 1, 1, 'last' ) + 1 );

% The nose tip is not at an exterme of the face, so we set a conservative
% criterion to discard anything within 1/6 of the face extent from the
% borders
face_extent = abs( chin_lim - forehead_lim );
max_to_med( 1 : forehead_lim + round( face_extent / 6 )) = 0;
max_to_med( chin_lim - round( face_extent / 6 ) : end) = 0;

% ----- /////////////////////////////////////////////////////// -------


% Get max difference 
[nada, y_maxDiff] = max( max_to_med );

% Compute local peaks of maxY
% ---------------------------
zero_cross = peakFind_1d(maxY, 1.0);


% Find the zero-cross closest to the maximum of maxY - medY
[nada, best_corss] = min( abs( zero_cross - y_maxDiff ));

% Determine which of the two pixels involved has the max value
y_bestCross_left = zero_cross( best_corss );
[nada, left_right] = max( maxY( y_bestCross_left + [0 1] ));
y_NOSE = y_bestCross_left + left_right - 1;

fprintf(1, '\n');

% ----------------------------------------------------------
%
% 2.- EYES, NOSE BASE and MOUTH y-coordinate
%
% ----------------------------------------------------------
% Mean (H) and Gaussian (K) curvatures are computed using bi-quadric
% fitting to the surface in a neighborhood of (11 * 11) and taking the
% partial derivatives. 
% Then, a Y-projection is computed based on curvature. This is done by
% determining the percentage of PIT curvature points (H > 0, K < 0) for 
% every set of points with the same y-coordinate. Segundo et al. indicate
% that this should lead to 3 peaks: nose base (the peak closest to the nose
% tip y-coordinate, that we already know), eye corners and mouth corners.
% (in reallity....we know the orientation and keep 3 peaks, so no need to
% have the nose-tip beforehand). Later on I found that it is useful to do
% the search for the 3 peaks referring to the nose-tip: 2 lower, 1 higher;
% otherwise we may get a high peak at one edge taking over on one of the
% peaks we really need. 
%
% Something not indicated in the paper is what threshold is used to 
% determine K,H = 0. And the issue is not minor as this threshold really 
% determines if we can find a few peaks or a noisy continuon 
% of curvature points (in the paper a very nice smooth curve is showed).
% To solve the problem, I use an outlier threshold (based on the
% inter-quartile distance) with a variable factor starting at k = 2. I leep
% increasing it (at steps of 2) untill no more PIT points are detected. I
% accumulate the curves produced at every step (after a Gaussian filtering
% with \sigma = 2 pixels to get a smoother curve, more like the one
% reported in the paper). In the end I get a curve that has very celar
% peaks: I take the 3 hihest peaks. An interesting point is that the
% nose-base peak tends to shift significantly as the threshold increases
% (it seems to shift 'upwards' the nose). Eyes and mouth coordinates seem
% to be more stable with respect to this threshold. 
%
% An interesting point is that Segundo et al. project the percentage of PIT
% points instead of their sum. This normalization is useless, as the face
% width between eyes and mouth does not change much, but it does toward the
% chin (especially if enclosing it in an ellipse, as the authors do).
% Therefore, the normalization only helps to leverage possible peaks in the
% chin region, which we don't want. So, I use the count of PIT points,
% without any normalization.
%
% A re-scaling triangular factor centered on the nose tip had to be
% introduced to avoid some peaks detected in the borders (for example, the
% eyes detected elseware up)

fprintf(1, '\tCurvature computation ');
[H, K] = rangeCurvature_biQuadric( X, Y, Z, 5, 5);  
K = -K; % The signs of K in the paper are wrong!
        % so we set it wrong and do as they say

% If H,K thresholds not set, perform automatic computation
fprintf(1, '\tPit-points Y-projection');
if thresh_H * thresh_K == 0
    fprintf(', k = %4d', 0);
    % clf; colorV = ['mbcgyrk'];

    avg_pitY = 0;
    kZero = 2;

    keey_adding = true;
    while keey_adding      
        bin9_KH = curvKH_bin9( H, K, kZero);
        % The vallue assigned for PIT points is bin9_KH = 2
        pitY = sum( bin9_KH == 2, 2 );

        if sum( pitY ) < 3 
            keey_adding = false;
        else
            kZero = kZero + ceil( kZero * .02 );
            filt_pitY = conv( pitY, gaussian ((-8 : 8), 0, 2));
            avg_pitY = avg_pitY + filt_pitY(9 : end - 8);            
        end

        % plot( avg_pitY ); hold on   
        fprintf(1, '\b\b\b\b%4d', kZero);
    end

else
    % Use externally indicated thresholds
    bin9_KH = curvKH_bin9( H, K, thresh_H, thresh_K);
    % The vallue assigned for PIT points is bin9_KH = 2
    pitY = sum( bin9_KH == 2, 2 );
    filt_pitY = conv( pitY, gaussian ((-8 : 8), 0, 2));
    avg_pitY = filt_pitY(9 : end - 8);                
end 
    
% Add a triangular re-scaling centered at the nose tip
if use_triangle_mask
    d_to_noseTip = [1 : size(Z, 1)] - y_NOSE;
    avg_pitY = avg_pitY .* [...
        (2/3) : (1/3) / max(-d_to_noseTip) : 1,...
        1 - (1/3) / max(d_to_noseTip) : -(1/3) / max(d_to_noseTip) : (2/3)]';
end

% Determine maximum points 
% ------------------------
zero_cross = peakFind_1d( avg_pitY, 1.0);

% Sort the peaks in descending order
peak_values = avg_pitY( zero_cross );
[peak_values, s_idx] = sort(peak_values, 'descend');
zero_cross = zero_cross( s_idx );

% Filter 'duplicate peaks'
zero_cross = peaks_FilterDuplicate_1d (...
    avg_pitY, zero_cross, peak_values,...
    length( zero_cross ) - 1, 1/3);

% Now we start from the nose-tip and look for 
% - 2 peaks lower (higher y-values) and 
% - 1 peak higher (lower y-values)
if thresh_H * thresh_K == 0
    bin9_KH = curvKH_bin9( H, K, 2.0);
    % If thresholds are set, no need to recompute bin9_KH ever
end

n_y_lower = 0;
n_y_higher = 0;
j_scan = 1;

while n_y_lower + n_y_higher < 3
    if zero_cross( j_scan ) > y_NOSE
        if n_y_higher < 2
            n_y_higher = n_y_higher + 1;
            j_scan = j_scan + 1;
        else
            % Delete this peak
            zero_cross(j_scan) = [];
        end
    else
        if n_y_lower < 1            
            % ATTENTION: 
            % Here we find another problem, if the y-coord of the eyes is
            % wrong, there won't be PIT-points for the x-coordinate and the
            % method fails. Hence, we test that now and discard peaks that
            % do not produce PIT points for the eyes
            % The vallue assigned for PIT points is bin9_KH = 2
            ye_try = zero_cross(j_scan);
            m1 = min( find( isfinite (Z( ye_try, : ))));
            m2 = max( find( isfinite (Z( ye_try, : ))));
            eye_maskX = zeros(1, size(X, 2));
            eye_maskX(m1 + floor((m2 - m1) / 10) : m2 - floor((m2 - m1) / 10)) = 1;
            
            xPitEyes = sum(...
                bin9_KH( ye_try - xEyes_rows : ye_try + xEyes_rows, :) == 2,...
                1 ) .* eye_maskX;
            if sum( xPitEyes ) < 3
                fprintf(1, '\n\tWARNING: False eye-peak at %d eliminated',...
                    zero_cross( j_scan ));
                zero_cross(j_scan) = [];
            else
                n_y_lower = 1;
                j_scan = j_scan + 1;
            end
        else
            % Delete this peak
            zero_cross(j_scan) = [];
        end
    end
end

% Finally, keep the first three peaks, and sort them
% by y-value (eyes, noseBase, mouth)
zero_cross = sort( zero_cross(1:3), 'ascend' );    
    
% For each peak, determine which of the two pixels involved has the max value
y_P1 = zero_cross( 1 );
[nada, left_right] = max( avg_pitY ( y_P1 + [0 1] ));
y_EYES = y_P1 + left_right - 1;

y_P2 = zero_cross( 2 );
[nada, left_right] = max( avg_pitY ( y_P2 + [0 1] ));
y_NBASE = y_P2 + left_right - 1;

y_P3 = zero_cross( 3 );
[nada, left_right] = max( avg_pitY ( y_P3 + [0 1] ));
y_MOUTH = y_P3 + left_right - 1;

fprintf(1, '\n');

% ----------------------------------------------------------
%
% 3.- NOSE TIP x-coordinate
%
% ----------------------------------------------------------
% The percentage of PEAK points (K < 0, H < 0) for every column is
% computed (projection into x-axis). Only rows neighboring the y-coordinate
% of the nose tip are considered. The number of neighbors is not specified
% in the pape, hence I tested between 2mm and 10mm (half to each side),
% which means 5 to 25 pixels (2 and 12 to each side, resp), with the latest
% being the one that seemed most appropriate (5 were certainly too few, and
% a 1-cm band (25 pixels) seems narrow enough.
% Regarding the sign of K and H, again there is no indication of the
% threshold used (to determine where they are considered ZERO), so an
% analogous procedure as the one used for the y-projections of PIT points
% was used. Again, no normalization to percentage of points was used as it
% doesn't seem to be of any use.

% clf; hold on;
fprintf(1, '\tPeak-points X-projection for NOSE TIP ');
if thresh_H * thresh_K == 0
    
    acc_peakX = 0;
    kZero = 2;

    keep_adding = true;
    while keep_adding
        bin9_KH = curvKH_bin9( H, K, kZero);

        % The vallue assigned for PEAK points is bin9_KH = -4
        peakX = sum(...
            bin9_KH(y_NOSE - xNose_rows : y_NOSE + xNose_rows, :) == -4, 1 );

        if sum( peakX ) < 3
            keep_adding = false;
        else
            kZero = kZero + ceil( kZero * .02 );
            filt_peakX = conv( peakX, gaussian ((-8 : 8), 0, 2));
            acc_peakX = acc_peakX + filt_peakX(9 : end - 8);
        end

        % plot( acc_peakX );
    end
else
    peakX = sum(...
        bin9_KH(y_NOSE - xNose_rows : y_NOSE + xNose_rows, :) == -4, 1 );
    while sum( peakX ) < 3
        fprintf(1, '\n\t *** Reducing thresholds for K,H 1.41 times');
        thresh_H = thresh_H / sqrt(2);
        thresh_K = thresh_K / sqrt(2);
        bin9_KH = curvKH_bin9( H, K, thresh_H, thresh_K);
        peakX = sum(...
            bin9_KH(y_NOSE - xNose_rows : y_NOSE + xNose_rows, :) == -4, 1 );            
    end
    filt_peakX = conv( peakX, gaussian ((-8 : 8), 0, 2));
    acc_peakX = filt_peakX(9 : end - 8);
end

[nada, x_NOSE] = max( acc_peakX );
fprintf(1, '\n');


% ----------------------------------------------------------
%
% 4.- NOSE BASE corners (x-coord)
%
% ----------------------------------------------------------
% The depth information is projected into the x-axis, but only using the
% points with y-coordinate equal to the nose tip. The nose corners are
% identified as the points of maximum gradient of this profile curve.

fprintf(1, '\tDepth x-profile at nose tip ');
valid_mask = isfinite( Z(y_NOSE, : ));

% There is a tendency to find high gradients near the edges: we know this
% is incorrect, so we filter 10% to each side as invalid points (a very
% conservative value, as the nose is unlikely to reach even 50% of the face
% width)
m1 = min( find( valid_mask == 1 ));
m2 = max( find( valid_mask == 1 ));
mask_width = m2 - m1;
valid_mask( m1 : m1 + floor( mask_width / 10 )) = 0;
valid_mask( m2 - floor( mask_width / 10) : m2) = 0;

xProfNose = Z(y_NOSE, :);

% Gradient
dG = gaussian ([-4 : 4], 0, 1, 'dx');
d_xProfNose = conv( dG, xProfNose );
d_xProfNose = d_xProfNose(5 : end-4);

% Filter invalid values
d_xProfNose( isnan( d_xProfNose )) = 0;
d_xProfNose( isinf( d_xProfNose )) = 0;
d_xProfNose = d_xProfNose .* valid_mask;

% Find the 2 highest gradient points (one to each side of the nose tip)
[R_max, x_NBASE_R] = max( abs (d_xProfNose(1 : x_NOSE) ));
[L_max, x_NBASE_L] = max( abs (d_xProfNose(x_NOSE : end) ));
x_NBASE_L = x_NBASE_L + x_NOSE - 1;

fprintf(1, '\n');

% ----------------------------------------------------------
%
% 5.- EYES x-coordinate
%
% ----------------------------------------------------------
% An x-projection of the percentage of PIT points is computed in a set of
% neighboring rows from the y-coordinate already detected for the eyes. The
% authors indicate thet this calculation should produce 2 peaks, and set te
% x-coordinates for the inner-eye corners as the beginning of the first
% peak and the end of the last peak. Of course this doesn't seem very
% robust and can potentially be strongly affected by the choice of a
% threshold to determine where the beginning and end of peaks are. Also, no
% Gaussian filtering can be applied to smooth the signal, as this would
% distort the values that we want to measure.
% The number of neighboring rows is also not indicated. I use 11, as this
% would imply 2mm to each side and increasing this value is risky due to
% the possible inclusion of PIT-points from the upper or lower parts of the
% eye sochets. 
% The threshold to set K, H to zero is more complicated here. I use again
% an approac baed on an outlier threshold, and keep increasing it until
% there are only 2 dominant peaks. The peaks are assumed to be dominant if
% there's no other peak of at least 1/3 ot the top two, or if the first two
% pekas concentrate at least 90% of the non-zero values of the profile
% curve.


fprintf(1, '\tPit-points x-projection for EYES x-coordinate ');

% Mask to avoid false detectinos near the borders
m1 = min( find( isfinite (Z( y_EYES, : ))));
m2 = max( find( isfinite (Z( y_EYES, : ))));
eye_maskX = zeros(1, size(X, 2));
eye_maskX(m1 + floor((m2 - m1) / 10) : m2 - floor((m2 - m1) / 10)) = 1;

if thresh_H * thresh_K == 0
    kZero = 2;
    % clf; hold on;
    keep_adding = true;
    MIN_PERCENT_2HP = 100 * 2 / 3 ;

    while keep_adding
        bin9_KH = curvKH_bin9( H, K, kZero);

        % The vallue assigned for PIT points is bin9_KH = 2
        xPitEyes = ...
            sum( bin9_KH(y_EYES - xEyes_rows : y_EYES + xEyes_rows, :) == 2,...
            1 ) .* eye_maskX;

        % Find the two highest peaks
        zero_cross = peakFind_1d( xPitEyes, 1.0 );
        [peak_values, s_idx] = sort( xPitEyes(zero_cross), 'descend' );
        zero_cross = zero_cross( s_idx );    

        if length( peak_values ) < 2
            % Start over
            kZero = 2;
            MIN_PERCENT_2HP = MIN_PERCENT_2HP - 1;
            fprintf(1, '.');
        else
            peakVals_12 = mean( peak_values(1:2) );

            % If no other peaks within 1/3 of amplitude, these are the ones
            validPeaks = find( peak_values > (1/3) * peakVals_12);
            peak_values = peak_values( validPeaks );
            zero_cross = zero_cross( validPeaks );

            % Filter 'duplicate peaks'
            zero_cross = peaks_FilterDuplicate_1d (...
            xPitEyes, zero_cross, peak_values, 2, 1/3);

            if length( zero_cross ) <= 2
                keep_adding = false;
                break;
            else        
                % Determine the number of pixels involved in each peak, defined as
                % the non-zero neighbors
                peaksWidth = zeros( 1, length( zero_cross) );
                for jP = 1 : length( zero_cross )
                    % Test to the right
                    jTest = zero_cross(jP);
                    while jTest <= length( xPitEyes )
                        if xPitEyes(jTest) > 0
                            peaksWidth(jP) = peaksWidth(jP) + 1;
                            jTest = jTest + 1;
                        else
                            break;
                        end
                    end

                    % Test to the left            
                    jTest = zero_cross(jP);
                    while jTest > 0
                        if xPitEyes(jTest) > 0
                            peaksWidth(jP) = peaksWidth(jP) + 1;
                            jTest = jTest - 1;
                        else
                            break;
                        end
                    end           
                end % FOR jP

                % Now compute the percentage of non-zero points that 
                % these two peaks concentrate        
                percent_in_2HP = 100 * sum( peaksWidth(1:2) ) /...
                    sum( peaksWidth );
                if percent_in_2HP > MIN_PERCENT_2HP
                    break;
                end

            end % IF more than 2 peaks

            kZero = kZero + ceil( kZero * .01 );

        %     hold off;
        %     plot( xPitEyes );
        %     title( sprintf('%d Peaks, %f %%', ...
        %         length(zero_cross), percent_in_2HP));
        %     getframe;
        %     pause;
        end
    end
    
    [peak_values, s_idx] = sort( xPitEyes(zero_cross), 'descend' );
    zero_cross = zero_cross( s_idx(1:2) ); 

else
    % Thresholds for H,K defined externally
    peak_values = 0;
    while length( peak_values ) < 2
        xPitEyes = ...
            sum( bin9_KH(y_EYES - xEyes_rows : y_EYES + xEyes_rows, :) == 2,...
            1 ) .* eye_maskX;

        % Find the two highest peaks
        zero_cross = peakFind_1d( xPitEyes, 1.0 );
        [peak_values, s_idx] = sort( xPitEyes(zero_cross), 'descend' );
        zero_cross = zero_cross( s_idx );

        if length( peak_values ) > 1        
            peakVals_12 = mean( peak_values(1:2) );
            
            % Filter anything below 1/3 of amplitude of these two
            validPeaks = find( peak_values > (1/3) * peakVals_12);
            peak_values = peak_values( validPeaks );
            zero_cross = zero_cross( validPeaks );
            
            % Filter 'duplicate peaks'
            zero_cross = peaks_FilterDuplicate_1d (...
                xPitEyes, zero_cross, peak_values, 2, 1/3);
        end
        
        if length( peak_values ) < 2        
            fprintf(1, '\n\t *** Reducing thresholds for K,H 1.41 times');
            thresh_H = thresh_H / sqrt(2);
            thresh_K = thresh_K / sqrt(2);
            bin9_KH = curvKH_bin9( H, K, thresh_H, thresh_K);
        end        
    end

    % Determine the number of pixels involved in each peak, defined as
    % the non-zero neighbors
    peaksArea = zeros( 1, length( zero_cross) );
    for jP = 1 : length( zero_cross )
        % Test to the right
        jTest = zero_cross(jP);
        while jTest <= length( xPitEyes )
            if xPitEyes(jTest) > 0
                peaksArea(jP) = peaksArea(jP) + xPitEyes(jTest);
                jTest = jTest + 1;
            else
                break;
            end
        end

        % Test to the left
        jTest = zero_cross(jP);
        while jTest > 0
            if xPitEyes(jTest) > 0                    
                peaksArea(jP) = peaksArea(jP) + xPitEyes(jTest);
                jTest = jTest - 1;
            else
                break;
            end
        end
    end % FOR jP

    % Now, keep the peaks with the highest area
    [nada, s_idx] = sort( peaksArea, 'descend' );
    zero_cross = zero_cross( s_idx(1:2) );
    
end

% The peaks are 
% - 'at the beginning' of the left-hand peak (right eye)
% - 'at the end' of the right-hand peak (left_eye) 

[nada, p_L_EYE] = max( zero_cross );
[nada, p_R_EYE] = min( zero_cross );

% Start at the peak value and move right till zero is found
x_EYE_L = zero_cross( p_L_EYE );
while x_EYE_L < length( xPitEyes )    
    x_EYE_L = x_EYE_L + 1;
    if xPitEyes( x_EYE_L ) == 0
        break;
    end
end

% Start at the peak value and move left till zero is found
x_EYE_R = zero_cross( p_R_EYE );
while x_EYE_L > 0
    x_EYE_R = x_EYE_R - 1;
    if xPitEyes( x_EYE_R ) == 0
        break;
    end
end


fprintf(1, '\n');

% -----------------------------------------------------
% Store results in 2D (Y,X) format
% -----------------------------------------------------
rangeLmks(1).landmarks2D_YX = [y_NOSE, x_NOSE;...
    y_NBASE, x_NBASE_L;...
    y_NBASE, x_NBASE_R;...
    y_EYES, x_EYE_L;...
    y_EYES, x_EYE_R];

rangeLmks(1).mouth_Y = y_MOUTH;

% -----------------------------------------------------
% Compute 3D positions of the points
% -----------------------------------------------------
rangeLmks(1).lmk_ordering = {
    'NTip', 'NBase_L', 'NBase_R', 'innerEYE_L', 'innerEYE_R'};
rangeLmks(1).landmarks3D = zeros(1, 15);
rangeLmks(1).landmarks3D = [...
    X( y_NOSE, x_NOSE ), Y( y_NOSE, x_NOSE ), Z( y_NOSE, x_NOSE ),...
    X( y_NBASE, x_NBASE_L ), Y( y_NBASE, x_NBASE_L ), Z( y_NBASE, x_NBASE_L ),...
    X( y_NBASE, x_NBASE_R ), Y( y_NBASE, x_NBASE_R ), Z( y_NBASE, x_NBASE_R ),...
    X( y_EYES, x_EYE_L ), Y( y_EYES, x_EYE_L ), Z( y_EYES, x_EYE_L ),...
    X( y_EYES, x_EYE_R ), Y( y_EYES, x_EYE_R ), Z( y_EYES, x_EYE_R )];   

% There could be cases where the identified x,y coordinates retrieve a -inf
% (no range information present). In those cases we do bi-linear
% interpolation to the 4-nearest neighvors
for jL = 1 : 5
    point_3d = rangeLmks(1).landmarks3D(jL*3-2: jL*3);
    if not( isfinite( point_3d(3) ))
        y0 = rangeLmks(1).landmarks2D_YX(jL, 1);
        x0 = rangeLmks(1).landmarks2D_YX(jL, 2);
        
        % Fine x/y Lower and Higher finite neighbors
        yL = y0;
        
        while not( isfinite(Z(yL, x0)))
            yL = yL - 1;
            if yL < 2
                yL = 1;
                break;
            end
        end
                        
        yH = y0;
        while not( isfinite(Z(yH, x0)))
            yH = yH + 1;
            if yH >= size(Z, 1)
                yH = size(Z, 1);
                break;
            end
        end
        
        xL = x0;
        while not( isfinite(Z(y0, xL)))
            xL = xL - 1;
            if xL < 2
                xL = 1;
                break;
            end
        end
        
        xH = x0;
        while not( isfinite(Z(y0, xH)))
            xH = xH + 1;
            if xH >= size(Z, 2)
                xH = size(Z, 2)
                break;
            end
        end
        
        if isfinite( Z(y0, xL) )
            x0L = X(y0, xL) / (x0 - xL);
            y0L = Y(y0, xL) / (x0 - xL);
            z0L = Z(y0, xL) / (x0 - xL);
            invDXL = x0 - xL;
        else
            x0L = 0;
            y0L = 0;
            z0L = 0;            
            invDXL = 0;
        end
        if isfinite( Z(y0, xH) )
            x0H = X(y0, xH) / (xH - x0);
            y0H = Y(y0, xH) / (xH - x0);
            z0H = Z(y0, xH) / (xH - x0);
            invDXH = xH - x0;
        else
            x0H = 0;
            y0H = 0;
            z0H = 0;            
            invDXH = 0;
        end
        
        if isfinite( Z(yL, x0) )
            xL0 = X(yL, x0) / (y0 - yL);
            yL0 = Y(yL, x0) / (y0 - yL);
            zL0 = Z(yL, x0) / (y0 - yL);
            invDYL = y0 - yL;
        else
            xL0 = 0;
            yL0 = 0;
            zL0 = 0;            
            invDYL = 0;
        end
        if isfinite( Z(yH, x0) )
            xH0 = X(yH, x0) / (yH - x0);
            yH0 = Y(yH, x0) / (yH - x0);
            zH0 = Z(yH, x0) / (yH - x0);
            invDYH = yH - y0;
        else
            xH0 = 0;
            yH0 = 0;
            zH0 = 0;
            invDYH = 0;
        end
        
        new_X = ( x0L + x0H + xL0 + xH0 ) /...
            (invDXL + invDXH + invDYL + invDYH);
        new_Y = ( y0L + y0H + yL0 + yH0 ) /...
            (invDXL + invDXH + invDYL + invDYH);
        new_Z = ( z0L + z0H + zL0 + zH0 ) /...
            (invDXL + invDXH + invDYL + invDYH); 
        
        rangeLmks(1).landmarks3D(jL*3-2: jL*3) = [...
            new_X, new_Y, new_Z];
    end
end
    













