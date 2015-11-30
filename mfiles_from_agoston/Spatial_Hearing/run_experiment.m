function run_experiment

% Initial clean up (of command window, figures, variables etc.)
clc;
close all;
clear all;

% Debug mode
dbstop if error % MATLAB 
debug = 0; % PTB

%% --------- Request parameters and setup path ----------

prompt = {'Setup name', 'Subject id', 'Pilot id', 'Session id', 'Run type', 'Run id', 'Audio type'};
title = 'Input parameters';
lines = [1 35]; % 1 row, 35 chars in each line
default = {'office', '234', '1', '1', 'A', '1', 'ITD'}; % 149, 16, 2 3 5
params = inputdlg(prompt, title, lines, default);
if ~isempty(params) % ok is pressed
    [setup.name, subj.id, run.type] = params{[1 2 5]};
    if strcmp(params{end}, 'ITD')
        stim.audio.type = 'ITD';
        stim.ITD.id = 1;
    elseif ~isempty(str2num(params{end}))
        stim.audio.type = 'rec';
        stim.rec.id = str2num(params{end});
    end
    params = cellfun(@str2num, params([3 4 6]), 'UniformOutput', false);
    [subj.pilot, subj.session, run.id] = params{:};
else % cancel is pressed
    fprintf('Run has been aborted...\n')
    return
end

% Set up path
mypath = setup_dir(subj, setup.name);

% Add palamedes toolbox to the path
if strcmp(run.type, 'P')
    addpath(fullfile(mypath.root, '_toolbox', 'Palamedes'));
end

%% ---------- Setup and screen parameters ------------

% Setup screen
setup = setup_screen(setup);

% Use trigger if needed
if strcmp(setup.name, 'scanner')
    str = input('Do you want to use labjack? y/n ', 's');
    if strcmp(str, 'y')
        setup.trigger = 1;
    end
end
if ~ismember('trigger', fieldnames(setup))
    setup.trigger = 0;
end

% Text font and size
setup.text.font = 'Arial';
setup.text.size = 26;

%% ---------- Keyboard and timing variables ------------

% Specify keyboards for the operator as well as for the participant
setup.kb.op = min(GetKeyboardIndices); % operator
setup.kb.subj = max(GetKeyboardIndices); % participant

% Keys and basic instrucions for subjects response 
if ~ismember(setup.name, {'mock ''scanner'})
%     key.str = {'H' 'K'};
    key.str = {'F' 'G' 'J' 'K'};
end
key.instruction = {'LEFT' 'CENTER LEFT' 'CENTER RIGHT' 'RIGHT'};

% Key for quit
key.quit = KbName('q');

% Inter Stimulus Interval
time.ISI = 2.4;

% Buffer time from response collection to next stimulus presentation
time.buff = 0.4;

%% ------------ AV stimulus parameters and design ---------------

% Stimulus duration
stim.dur = 0.05;

% Stimulus cue space (both A and V)
if strcmp(run.type, 'P')
    stim.loc = -10:0.5:10;
else
%     stim.loc = [-10 -7 -5:5 7 10]';
%     stim.loc = [-12 -9 -7 -5 -3:3 5 7 9 12]';
    stim.loc = [-3 -1 1 3]';
end

% Design for staircase
if strcmp(run.type, 'P')
    trialtype = [1 0 0 1]; % staircase id for particular trialtypes: left-side stimuli (col 1-2), right-side stimuli (col 3-4)
    stim.azimuth = 1; % +-azimuth for non-staircase trials
    stim.nreps = 20; % repetition per trialtype
    PAL.method = 'weighted'; % weighted->0.6, transformed->0.7, transformed_weighted->0.5,0.8,0.9, test->0.5
    PAL.stop.criterion = 'joint'; % reversals, trials or joint
    PAL.stop.rule = [10 15]; % XY reversals (1) in the last XY trials (2)
    PAL.stop.min = 15;
end

% Stimulus repetition for A/V runs
if ismember(run.type, {'A' 'V'})
    stim.visual.nreps = 5; % 5
    stim.audio.nreps = 10; % 9 15
    if strcmp(stim.audio.type, 'rec')
        nreps = stim.audio.nreps / length(stim.(stim.audio.type).id);
        if round(nreps) ~= nreps
            error('Number of trials is not appropriate for the number of recordings.')
        end
    end
end

%% ---------- Visual stimulus parameters ------------

% Visual stimulus parameters
stim.visual.type = 'blob';
if strcmp(stim.visual.type, 'blob') % gaussian blob
    stim.visual.xstd = 7;
    stim.visual.ystd = 2;
elseif strcmp(stim.visual.type, 'cloud') % gaussian cloud of dots
    stim.visual.num = 20;
    stim.visual.diam = 0.4; % 0.2
    stim.visual.xstd = 2;
    stim.visual.ystd = 2;
end
stim.visual.contr = 0.7;

%% ---------- A stimulus parameters ------------

% Sound sampling frequency
stim.audio.freq = 192000; % 44100

% Volume adjustment
if strcmp(setup.name, 'scanner')
    stim.audio.vol = 1.0; % 82 dB
elseif strcmp(setup.name, 'mock')
    stim.audio.vol = 0.3; % 82 dB
else
    stim.audio.vol = 0.06; % 0.08->75 dB 0.18
end

% Sound ramp on-off
stim.audio.ramp = 0.005;

% Generate (ITD) or get (recording) audio data
if strcmp(stim.audio.type, 'ITD')
    stim.ITD.soundspeed = 340; % in m/sec
    stim.ITD.eardist = 0.2; % in m
    stim.ITD.level = sind(unique(abs(stim.loc))) * stim.ITD.eardist / stim.ITD.soundspeed;
elseif strcmp(stim.audio.type, 'rec')
%     stim.rec.cutoff = 0.6;
%     stim.rec.bp = {1800 15000};
    [subj, stim] = getaudio(subj, mypath, stim, 'rec');
end

%% ------------ Generate data and present stimuli --------------

% Generate data
if strcmp(run.type, 'P')
    [data, UD] = generate_data(run.type, stim, trialtype, PAL);
elseif ismember(run.type, {'A' 'V'})
    data = generate_data(run.type, stim);
end

% Present stimuli
if strcmp(run.type, 'P')
    present_stimuli(subj, run, setup, key, data, stim, time, debug, UD);
elseif ismember(run.type, {'A' 'V'})
    present_stimuli(subj, run, setup, key, data, stim, time, debug);
end
% Clear matlab debug mode
dbclear if error
