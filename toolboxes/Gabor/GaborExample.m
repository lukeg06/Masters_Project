
% Author : Chai Zhi  
% e-mail : zh_chai@yahoo.cn

close all;
clear all;
clc;

% Parameter Setting
R = 128;
C = 128;
Kmax = pi / 2;
f = sqrt( 2 );
Delt = 2 * pi;
Delt2 = Delt * Delt;

GW = zeros(R,C,40);
% Show the Gabor Wavelets
for v = 0 : 4
    for u = 1 : 8
        GW(:,:,u+v*8) = GaborWavelet ( R, C, Kmax, f, u, v, Delt2 ); % Create the Gabor wavelets
    end
  
end



