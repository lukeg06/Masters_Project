function peak_idxs = peakFind_1d( x, g_sigma )
% peak_idxs = peakFind_1d( x, g_sigma )
%
% Find the peak (positive maximum) of a 1D signal using a Gaussian filter
% to better approximate the derivatives. 
%

half_gX = ceil( 4 * g_sigma );

dG = gaussian ([-half_gX : half_gX], 0, g_sigma, 'dx');
dx = conv( dG, x );
dx = dx(half_gX + 1 : end - half_gX);

dG2 = gaussian ([-half_gX : half_gX], 0, g_sigma, 'dx2');
d2x = conv( dG2, x );
d2x = d2x(half_gX + 1 : end - half_gX);

% Zero-crossings imply neighbors with opposite signs
% (notice the 1-offset: the crossing will be between the detected index and
% the immediate next-one)
peak_idxs = find(...
    sign(dx(2:end)) .* sign(dx(1:end-1)) == -1);

% For a maximum, the 2nd derivative must be negative to both sides of the
% peak, then we would attempt:
%     d2_sign_left = sign( d2x( peak_idxs ) );
%     d2_sign_right = sign( d2x( peak_idxs + 1 ));
%     peak_idxs( d2_sign_left + d2_sign_right > -2 ) = [];
% However, in this way we can miss some peaks because of the instability of
% the second derivative (and the discretization). Hence, we just ask that
% the average second derivative is not positive, as follows:
d2_left = sign( d2x( peak_idxs ) );
d2_right = sign( d2x( peak_idxs + 1 ));
peak_idxs( d2_left + d2_right > 0 ) = [];

