function varargout = mantis_segrun2(cmd, job)
% Execution file for MANTIS
%_______________________________________________________________________
% Jian Chen
% $Id: mantis_segrun2.m 2014-02-18 14:25:20 $

idir=job.idir{1};
switch cmd
    case 'maketemp'
       if exist([idir 'spm_run2'], 'dir');
            warning('exist spm_run2');
            %rmdir([idir 'spm_run2'], 's');
       end
       mkdir(idir, 'spm_run2/subjtemplate')
       make_temp(idir)
       
    case 'seg2'
       if ~exist([idir 'spm_run2/subjtemplate'], 'dir');
            warning('subjtemplate does exist, please run maketemp first');
            return;
       end
       seg2(idir);      
    otherwise
        return;
end

if nargout > 0
    varargout{1} = out;
end
return