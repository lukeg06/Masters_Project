function [bin9_KH, kH_idx, kG_idx] = curvKH_bin9( kh, kg, varargin )
%
% bin9_KH = curvKH_bin9( kh, kg [,outlier_thresh] )
% [bin9_KH, kh_idx, kg_idx] = curvKH_bin9( kh, kg [,outlier_thresh] )
% [bin9_KH, kh_idx, kg_idx] = curvKH_bin9( kh, kg [,thresh_H, thresh_K] )
% 
% Divide curvature of points into 9 bins based on the signs of 
% mean (kh) and gaussian (kg) curvatures
%              kG < 0    kG = 0     kG > 0
% kH < 0          -4       -3         -2
% kH = 0          -1        0          1
% kH > 0           2        3          4
%
% The optional parameter 'outlier_thresh' determines when a curvature value
% is considered non-zero:
% non_zero = |curvature - Q| >= outlier_thresh * inter_quartile_dist
% Default is 1.5 
% If zero is specified, then half the points are considered to have zero
% curvature
%
% It is also possible to get the indexes for high and low curvatures for kh
% and kg into kh_odx and kg_idx structures
%

% Determine outlier threshold
% ---------------------------
oLT = 1.5;
use_OLT = true;
thresh_H = 0;
thresh_K = 0;

if not( isempty( varargin ))
    if length( varargin ) > 2
        error('Too many input arguments');
    end
    if length( varargin ) > 1
        use_OLT = false;
        thresh_H = varargin{1};
        thresh_K = varargin{2};
    else
        oLT = varargin{1};
    end
end

% H
if use_OLT
    q123 = quantile( kh(:), [.25 .5 .75]);
    if q123(1) == 0
        q123(1) = quantile( kh(abs(kh) > 0),.25);
    end
    if q123(3) == 0
        q123(3) = quantile( kh(abs(kh) > 0),.75);
    end

    oL_H = oLT * (q123(3) - q123(1)) + q123(3);
    oL_L = -oLT * (q123(3) - q123(1)) + q123(1);
    kH_idx = struct('high', find(kh > oL_H),...
        'low', find(kh < oL_L) );
else
    kH_idx = struct('high', find(kh > thresh_H),...
        'low', find(kh < -thresh_H) );
end
    
% K  
if use_OLT
    q123 = quantile( kg(:), [.25 .5 .75]);
    if q123(1) == 0
        q123(1) = quantile( kg(abs(kg) > 0),.25);
    end
    if q123(3) == 0
        q123(3) = quantile( kg(abs(kg) > 0),.75);
    end

    oL_H = oLT * (q123(3) - q123(1)) + q123(3);
    oL_L = -oLT * (q123(3) - q123(1)) + q123(1);
    kG_idx = struct('high', find(kg > oL_H),...
        'low', find(kg < oL_L) );
else
    kG_idx = struct('high', find(kg > thresh_K),...
        'low', find(kg < -thresh_K) );
end

bin9_KH = zeros( size( kh ) );
bin9_KH( kH_idx.high ) = 3;
bin9_KH( kH_idx.low ) = -3;
bin9_KH( kG_idx.high ) = bin9_KH( kG_idx.high ) + 1;
bin9_KH( kG_idx.low ) = bin9_KH( kG_idx.low ) - 1;


