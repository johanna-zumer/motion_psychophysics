function mypath = setup_dir(subj, flag)
% mypath = setup_dir(subj, flag)

if ~exist('flag', 'var')
   flag = ''; 
end

% Root folder
[pathname, filename, ext] = fileparts(which('setup_dir.m')); 
mypath.root = fullfile(pathname, filesep, '..', filesep, '..');

% Add miscellaneous script folder to the path
mypath.misc = fullfile(mypath.root, '_miscellaneous');
if isdir(mypath.misc)
   addpath(mypath.misc) 
else
    error('Miscellaneous folder is not found.')
end

% Experiment folder
mypath.exp = fullfile(mypath.root, 'My projects', 'Spatial_Hearing');

% Main data folder
mypath.data = fullfile(mypath.exp, 'data');

% Pilot and session data folder
folder = {'data'};
for i=1:length(folder)
    if isfield(subj, 'pilot')
        mypath.(folder{i}) = fullfile(mypath.(folder{i}), sprintf('pilot_%d', subj.pilot), subj.id);
    else
        mypath.(folder{i}) = fullfile(mypath.(folder{i}), subj.id);
    end
    if isfield(subj, 'session')
        session = getfname(mypath.data, '201*');
        if subj.session <= length(session) % session already exists
            mypath.(folder{i}) = fullfile(mypath.(folder{i}), session{subj.session});
        else
            mypath.(folder{i}) = fullfile(mypath.(folder{i}), datestr(now, 'yyyy_mm_dd'));
        end
    end
    if ~isdir(mypath.(folder{i}))
        mkdir(mypath.(folder{i}))
    end
end

% Analysis folder if needed
if strcmp(flag, 'anal')
    plot2svgdir = fullfile(mypath.misc, 'plot2svg_20120915');
    if isdir(plot2svgdir)
        addpath(plot2svgdir) % to enable svg export
    end
    mypath.anal = fullfile(mypath.data, 'analysis');
    if ~isdir(mypath.anal)
        mkdir(mypath.anal)
    end
end

% Additional dropbox folders if needed
if strcmp(flag, 'lab')
    mypath.dropbox = fullfile(mypath.root, '..', 'Dropbox', 'MATLAB');
    mypath.copydata = fullfile(mypath.dropbox, 'data', subj.id);
    if ~isdir(mypath.copydata)
        mkdir(mypath.copydata)
    end
end

% Add scanner scripts if needed
if strcmp(flag, 'scanner')
    scannerdir = fullfile(mypath.misc, 'scanner');
    if isdir(scannerdir)
        addpath(scannerdir)
    else
        error('Scanner scripts do not exist.')
    end
end