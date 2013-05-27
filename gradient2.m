%   function [gr, gc] = gradient(img, sigma)
%
% gr is the partial derivative of img in the vertical direction (down is
% positive); gc is the same in the horizontal direction (right is positive);
% sigma is the standard deviation of the Gaussian function used for
% differentiation; if left unspecified, sigma defaults to 1.
% Color images are converted to black and white before the gradient is
% computed (if you want the gradient of each band, call this function three
% times).

% This function is provided by Carlo Tomasi tomasi@cs.duke.edu.

function [gr, gc] = gradient2(img, sigma)

% Assign a default standard deviation if needed
if nargin < 2
    sigma = 1;
end

% Make the tails of the Gaussian long enough to make truncation
% unnoticeable
tail = ceil(3.5 * sigma);
x = -tail:tail;
x = x(:);

% A one-dimensional Gaussian and its derivative
g = gauss(x, 0, sigma, 1);
d = gaussDeriv(x, 0, sigma, 1);

% Convert to doubles if needed
img = double(img);

% Color-to-bw conversion, if needed
if ndims(img) == 3
    img = squeeze(img(:, :, 1) + img(:, :, 2) + img(:, :, 3)) / 3;
end

% Do the two separable convolutions
gr = conv2(d, g, img, 'valid');
gc = conv2(g, d, img, 'valid');

% Handle image boundaries appropriately. Cannot use 'same' option
% in conv2, because we don't want spurious edges
[rows, cols] = size(img);
gr = adjustSize(gr, rows, cols);
gc = adjustSize(gc, rows, cols);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% With normalized == 0, returns saamples of a 1D Gaussian with the given
% mean and standard deviation. With normalized == 1, adjusts normalization
% so that the sum of the samples is one.
function g = gauss(x, m, sigma, normalized)

if nargin < 4
    normalized = 0;
end

g = exp(- (((x - m)/ sigma) .^ 2) / 2) / sqrt(2 * pi) / sigma;

if normalized
    g = g / sum(g);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% With normalized == 0, returns saamples of the derivative of a 1D Gaussian
% with the given mean and standard deviation. With normalized == 1, adjusts
% normalization so that the inner product of the samples with a unit-slope
% ramp centered at the mean is minus one.
function d = gaussDeriv(x, m, sigma, normalized)

if nargin < 4
    normalized = 1;
end

d = (m - x) .* gauss(x, m, sigma, 0) / sigma^2;

if normalized
    ramp = m - x;
    d = d / sum(ramp .* d);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pads a with zeros symmetrically to obtain an image of size [rows, cols]
% (assumed to be no smaller than size(a)).

function b = adjustSize(a, rows, cols)

[aRows, aCols] = size(a);

rs = 1 + floor((rows - aRows) / 2);
re = rs + aRows - 1;

cs = 1 + floor((cols - aCols) / 2);
ce = cs + aCols - 1;

b = zeros(rows, cols);
b(rs:re, cs:ce) = a;
