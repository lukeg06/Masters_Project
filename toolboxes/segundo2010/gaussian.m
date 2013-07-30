function G = gaussian (varargin)

% 1D-Gaussian and derivatives
%
% G = gaussian (x, media, sigma)
% G = gaussian (x, media, sigma, 'dx')
% G = gaussian (x, media, sigma, 'dx2')
% G = gaussian (x, media, sigma, 'ds')
%
% G = gaussian (x, media, sigma)
%
% Returns the Gaussian Function with mean MEDIA and std SIGMA
% evaluated in X
%               1                   (x-M)^2
% G(x) = ---------------- exp ( - ----------- )
%         S (2*PI)^(1/2)             2 * S^2
%
%
% G = gaussian (x, media, sigma, 'dx')
% Returns the 1st derivative of the Gaussian Function with mean MEDIA and std SIGMA
% evaluated in X
%
% G = gaussian (x, media, sigma, 'dx2')
% Returns the 2nd derivative of the Gaussian Function with mean MEDIA and std SIGMA
% evaluated in X
%
% G = gaussian (x, media, sigma, 'ds')
% Returns the 1st derivative of the Gaussian Function with mean MEDIA and std SIGMA
% WITH RESPECT TO SIGMA evaluated in X
%
% REMARK: In the cases of the derivatives, the continuous function is 
% derived and then sampled.
%

if length(varargin) < 3 | length(varargin) > 4
    error ('Incorrect number of parameters');
end

x = varargin{1};
media = varargin{2};
sigma = varargin{3};

if length(varargin) > 3
    typeOfFunction = varargin{4};
else
    typeOfFunction = '00';
end
    
switch typeOfFunction
case '00' % Gaussian
    G = 1 / (sigma * sqrt(2*pi)) * exp (-(x-media).^2 / (2 * sigma^2));
    
case 'dx' % First Derivative
    G = (1 / (sigma ^ 3 * sqrt(2*pi))) * (media - x) .* exp (-(x-media).^2 / (2 * sigma^2));
    
case 'dx2' % Second Derivative
    G = (-1 / (sigma ^ 3 * sqrt(2*pi))) * (1 - (x - media).^2 / (sigma^2)) .*...
        exp (-(x-media).^2 / (2 * sigma^2));

case 'ds' % First Derivative ON SIGMA
    G = (1 / (sigma ^ 2 * sqrt(2*pi))) * exp (-(x-media).^2 / (2 * sigma^2)) .*...
        (...
        (x - media).^2 / (sigma^2) - 1 ...
    );  
    
otherwise
    errorString = sprintf ('Unsupported parameter %s', typeOfFunction);
    error ( errorString );
end

