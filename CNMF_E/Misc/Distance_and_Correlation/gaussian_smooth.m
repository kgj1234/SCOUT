function yfilt=gaussian_smooth(y)
sigma = 10;
sz = 100;    % length of gaussFilter vector
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter); % normalize
yfilt = conv (y, gaussFilter, 'same');