function [f_remaining_time] = est_remaining_time( kmin, kmax )
%EST_RESTTIME return the function for estimating remaining time
    start=tic;
    function [remaining,elapsed] = proto_f_remaining_time(k)
        elapsed=toc(start);
        remaining=elapsed/(k-kmin+1)*(kmax-k);
        if nargout==0
            fprintf('%d/%d (%4.1f%%) Done.\t',...
                k-kmin+1,kmax-kmin+1,...
                (k-kmin+1)/(kmax-kmin+1)*100);
            fprintf('Elapsed %.1f sec, Remaining %.1f sec.\n',elapsed,remaining);
        end
    end
    f_remaining_time=@proto_f_remaining_time;
end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.