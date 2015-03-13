function varargout = cg_mantis(cmd, job)
% Execution file for MANTIS
%_______________________________________________________________________
% Jian Chen
% $Id: cg_mantis.m 2014-02-18 14:25:20 $
switch lower (cmd)
    case {'segrun1'}
        idir = job.idir{1};
        spm_segrun1(fullfile(idir, 'spm_run1'));
        
    case {'segcsf'}
        idir = job.idir{1};
        if exist(fullfile (idir, 'WS_seg'), 'dir');
            warning('exist');
        else
            mkdir(idir, 'WS_seg');
        end
        WS_seg(fullfile (idir, 'spm_run1'), [idir '/WS_seg/']);
        
    case {'wmclean'}
        idir = job.idir{1};
        if exist(fullfile (idir, 'spm_run2'), 'dir')
            warning('exist');
        else
            mkdir(idir, 'spm_run2');
        end
        wmclean(idir);
        %wmclean(fullfile (idir, 'spm_run1'), fullfile (idir, 'spm_run2'));
        
    case {'hardlabel'}
        idir = job.idir{1};
        make_hard_label(idir);
        
    case {'calvol'}
        idir = job.idir{1};
        calvol(idir);
        
    case {'batchrun'}
        idir = job.idir{1};
        batch_run(idir);
    otherwise
        disp('Unknown method.')
end

if nargout > 0
    varargout{1} = out;
end
return
