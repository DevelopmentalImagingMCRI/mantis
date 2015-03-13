function segrun2 = cg_mantis_segrun2
% Call for SPM second run processes
%
%_______________________________________________________________________
% Jian Chen
% $Id: cg_mantis_segrun2.m 7 2014-05-06 14:39:07Z chen $

%rev = '$Rev: 415 $';

%_______________________________________________________________________

data = cfg_files;
data.tag  = 'data';
data.name = 'Volumes';
data.filter = 'image';
data.ufilter = '.*';
data.num     = [1 Inf];
data.help = {[...
'Select raw data (e.g. T1 images) for processing. ',...
'This assumes that there is one scan for each subject. ',...
'Note that multi-spectral (when there are two or more registered ',...
'images of different contrasts) processing is not yet implemented ',...
'for this method.']};


% ---------------------------------------------------------------------   
% idir Input Directory   
% ---------------------------------------------------------------------   
idir   = cfg_files; 
idir.tag     = 'idir';    
idir.name    = 'Subject Directory';    
idir.val = {{'.'}}; 
idir.help    = {    
    'This defaults to the current work directory. It is, however, a good '
    'idea to create a separate directory with a meaningful name for each project.'    
   }'; 
idir.filter = 'dir';
idir.ufilter = '.*';
idir.num     = [1 1];     


% ---------------------------------------------------------------------   
% Make custom template   
% ---------------------------------------------------------------------   
maketemp   = cfg_exbranch; 
maketemp.tag     = 'maketemp';    
maketemp.name    = 'Make custom template';    
maketemp.val     = {idir};
maketemp.help    = {'Make custom template.'};   
maketemp.prog = @(job)mantis_segrun2('maketemp',job);  

seg2   = cfg_exbranch; 
seg2.tag     = 'seg2';    
seg2.name    = 'Segmentation second run';    
seg2.val     = {idir};
seg2.help    = {'Segmentation second run.'}; 
seg2.prog = @(job)mantis_segrun2('seg2',job);  


segrun2 = cfg_choice;
segrun2.name = 'segrun2';
segrun2.tag  = 'segrun2';
segrun2.values = {maketemp, seg2};


return

%_______________________________________________________________________

