function [H, K] = rangeCurvature_biQuadric( X, Y, Z, halfNX, halfNY)
% Compute the curvature on the depth map Z by fitting a biquadric to each
% point using a neighorhood of size (2 * halfNX + 1) * (2 * halfNY + 1)
% 
% The implementation is based on Colombo et al (2006), 
% Pattern Recognition 39 (2006) 444 – 455
%



% Initialize curvatures to zero
H = zeros( size( Z ));
K = zeros( size( Z ));

for jX = 1 + halfNX :size(Z,2) - halfNX
    if mod( 40 * jX, size(Z,2) ) == 0
        fprintf(1, '.');
    end
    
    for jY = 1 + halfNY : size(Z,1) - halfNY
        x0 = X(jY, jX);
        y0 = Y(jY, jX);

        if not( x0 > -inf )
            continue;
        else
            if not( y0 > -inf )
                continue;
            end
        end
        
        % Define a biquadric in a neighborhood of (x0, y0)
        % s(x,y) = a + b*(x-x0) + c*(y-y0) + d*(x-x0)*(y-y0) + ...
        %    + e*(x-x0)^2 + f(y-y0)^2
        %
        % LINSOLVES: olve linear system A*X=B.
        % [1 difX difY difXY difYY difXX] * Matrix_abcdef = SURF_VALUES
        %
        tX = jX - halfNX : jX + halfNX;
        tY = jY - halfNY : jY + halfNY;
        patch_X = X(tY, tX) - x0;
        patch_Y = Y(tY, tX) - y0;
        patch_Z = Z(tY, tX);
        
        % BB = zeros((1 + 2 * halfNX) * (1 + 2 * halfNY), 1);        
        AA = ones((1 + 2 * halfNX) * (1 + 2 * halfNY), 6);
        BB = patch_Z(:);

        AA(:, 2) = patch_X(:);
        AA(:, 3) = patch_Y(:);
        AA(:, 4) = patch_X(:) .* patch_Y(:);
        AA(:, 5) = patch_X(:) .^ 2;
        AA(:, 6) = patch_Y(:) .^ 2;
                
%         jG = 0;
%         
%         for jGX = jX - halfNX : jX + halfNX
%             for jGY = jY - halfNY : jY + halfNY
%                 jG = jG + 1;
%                 x_x0 = X(jGY, jGX) - x0;
%                 y_y0 = Y(jGY, jGX) - y0;
% 
%                 AA(jG, 1) = 1;
%                 AA(jG, 2) = x_x0;
%                 AA(jG, 3) = y_y0;
%                 AA(jG, 4) = x_x0 * y_y0;
%                 AA(jG, 5) = x_x0 ^ 2;
%                 AA(jG, 6) = y_y0 ^ 2;
% 
%                 BB(jG) = Z(jGY, jGX);
%                 
%             end % jGY
%         end % jGX
               
        % 
        undef_flag = isinf( BB );
        aux_A = sum(isfinite( AA ), 2);
        undef_flag( aux_A < 6 ) = 1;
                
%         % Remove any -inf values
%         undef_flag = zeros(1, length(BB));
%         for jAux = 1 : length( BB )
%             if isinf( BB(jAux) )
%                 undef_flag(jAux) = 1;
%             else
%                 if prod(double( isfinite( AA(jAux, :) ) )) == 0
%                     undef_flag(jAux) = 1;
%                 end
%             end
%         end
        
        BB(undef_flag == 1) = [];
        AA(undef_flag == 1, :) = [];
        
        % Continue processing only if there are enough points 
        if length(BB) >= 6
            %jX 
            %jY
 
            % Least squares estimation of the quadric parameters
            [abcdef, estim_rank] = linsolve(AA,BB);
            if estim_rank >= 6

                % Now the partial derivatives are 
                % fX = b     fXX = 2e     fXY = d
                % fY = c     fYY = 2f
                fX = abcdef(2);
                fY = abcdef(3);
                fXY = abcdef(4);
                fXX = 2 * abcdef(5);
                fYY = 2 * abcdef(6);        

                %
                % And the curvatures can be computed as (always from Colombo 2006)
                %
                %      (1 + fY^2) * fYY - 2 * fX * fY * fXY  + (1 + fX^2) * fYY
                % H = ------------------------------------------------------------
                %                  2 * (1 + fX^2 + fY^2)^(3/2)
                %
                %       fXX * fYY - fXY ^ 2         
                % K = -----------------------
                %      ((1 + fX^2 + fY^2)^2       
                %

                H(jY, jX) = (...
                    (1 + fY^2) * fXX - 2 * fX * fY * fXY + (1 + fX^2) * fYY...
                    ) / (2 * (1 + fX^2 + fY^2)^(3/2));
                K(jY, jX) = ...
                    (fXX * fYY - fXY ^ 2) /...
                    ((1 + fX^2 + fY^2)^2);
                
            end % IF rank ok (6)
        end % IF length(BB) >= 6 
    end % jY    
end % jX

fprintf(1,' \n');
