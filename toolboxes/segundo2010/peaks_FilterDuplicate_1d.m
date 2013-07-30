function zero_cross = peaks_FilterDuplicate_1d (...
    x, in_zero_cross, peak_values, nPeaksToTest, valley_max_rel_height)
%
% zero_cross    are the positions of the peaks
% peak_values   are the values of the peaks (in corresp with zero_cross) 
% valley_max_rel_height 
%               indicates the fraction of the height ot the peak that the
%               valley must pass (downwards) so that two peaks are
%               considered separate. Typical value is 1/3
%
% The idea is that there cannot be two peaks that are
% very close (they would most likely be the same). However, it is difficult
% to define a threshold of proximity, so we proceed as follows:
% 1) For each peak (starting from the highest) find the two closest peaks
% (to either side).
% 2) Find the minimum value from the central peak to each of the nearest
% neighbors: if the minimum is above (1/3) of the peak value, then eliminate
% the neighbor 
% We do this only for the first N peaks, following he ordering of the input
% data (no re-ordeting is done in any sense).
%

zero_cross = in_zero_cross;

jP = 1;
while jP <= nPeaksToTest
    repeat_this_peak = false;
    
    if length( zero_cross ) < jP
        break;
    end
    
    dist_to_centre = zero_cross - zero_cross(jP);
    neg_idxs = find(dist_to_centre < 0);
    if not( isempty( neg_idxs ))
        [nada, min_neg] = max( dist_to_centre( neg_idxs ));
        p_neg = neg_idxs( min_neg );
        % Only revise the neighbor peak if it is smaller (otherwise it was
        % revised already)
        if x( zero_cross(p_neg)) < x (zero_cross(jP))
            peak_to_peak = x( zero_cross(p_neg) : zero_cross(jP));
            % If the valley is not deep enough, delete peak
            if min( peak_to_peak ) > valley_max_rel_height * peak_values(jP)
                peak_values(p_neg) = [];
                zero_cross(p_neg) = [];
                repeat_this_peak = true; % Must check again for next one
            end
        end
    end

    dist_to_centre = zero_cross - zero_cross(jP);    
    pos_idxs = find(dist_to_centre > 0);    
    if not( isempty( pos_idxs ))
        [nada, min_pos] = min( dist_to_centre( pos_idxs ));
        p_pos = pos_idxs( min_pos );
        % Only revise the neighbor peak if it is smaller (otherwise it was
        % revised already)
        if x(zero_cross(p_pos)) < x(zero_cross(jP))
            peak_to_peak = x( zero_cross(jP) : zero_cross(p_pos) );
            % If the valley is not deep enough, delete peak
            if min( peak_to_peak ) > valley_max_rel_height * peak_values(jP)
                peak_values(p_pos) = [];
                zero_cross(p_pos) = [];
                repeat_this_peak = true; % Must check again for next one
            end
        end
    end       

    if not( repeat_this_peak )
        % Both neighbors of this peaks are ok
        jP = jP + 1;
    end
end






