classdef  FilterBank < handle
    
    properties( Access =  private)
        R = 128;
        C = 128;
        Kmax = pi / 2;
        f = sqrt( 2 );
        Delt = 2 * pi;
        Delt2;
        GW;
        
    end
    
    
    methods
        function this = FilterBank()
            addpath('.\toolboxes\Gabor\');
            this.Delt2 = this.Delt*this.Delt;
            this.GW =  zeros(this.R,this.C,40);
            this.generateFilterBank();
        end
        
        function generateFilterBank(this)
            for v = 0 : 4
                for u = 1 : 8
                    this.GW(:,:,u+v*8) = GaborWavelet ( this.R, this.C, this.Kmax, this.f, u, v, this.Delt2 ); % Create the Gabor wavelets
                end
                
            end
            
        end
    end
    
    methods (Access = public)
        function filterOut = getFilter(this,j)
            filterOut = this.GW(:,:,j);
        end
        
        function response = filterImage(this,imageIn)
            response = zeros(size(this.GW,3),size(imageIn,1),size(imageIn,2));
            for i = 1:size(this.GW,3)
                currentFilter = this.getFilter(i);
                response(i,:,:) = conv2(imageIn,currentFilter,'same');
           
                
            end
            
        end
        
    end
    
    
end