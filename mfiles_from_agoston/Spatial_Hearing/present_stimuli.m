function present_stimuli(subj, run, setup, key, data, stim, time, debug, UD)

% Set up path
mypath = setup_dir(subj, setup.name);

% Make sure the script is running on Psychtoolbox-3 (PTB-3)
AssertOpenGL;

%% ----------- Initialize sound ---------------

% Set low level latency mode with possible compensation for hardwares's inherent latency
% (not used at the moment and needs to be calibrated with e.g. micro & photo diode)
stim.audio.lat.lev = 1;
stim.audio.lat.bias = 0;

% Initialize PsychPortAudio sound driver
InitializePsychSound(stim.audio.lat.lev);

% Open default sound device
% Office: Audio subsystem is Windows DirectSound, Audio device is Primary Sound Driver, device id is 8
pahandle = PsychPortAudio('Open', [], [], [], stim.audio.freq, 2);

% Control over volume and latency bias
PsychPortAudio('Volume', pahandle, stim.audio.vol);
PsychPortAudio('LatencyBias', pahandle, stim.audio.lat.bias);

%% ----------- Initialize screen ---------------

if debug
    PsychDebugWindowConfiguration % use transparent screen
    Screen('Preference', 'SkipSyncTests', 1); % skip screen synchronization, otherwise error due to PTB debug mode
    setup.old.verb = Screen('Preference', 'Verbosity', 1); % print only errors
else
    Screen('Preference', 'SkipSyncTests', 0); % synchronize screen
    setup.old.verb = Screen('Preference', 'Verbosity'); % print error+warning+status messages
    setup.old.visdeb = Screen('Preference', 'VisualDebugLevel', 3); % turn off PsychToolbox Welcome Sign
end

% Get screen id
setup.screen = max(Screen('Screens'));

% Load Gamma Table and define colours
if ~debug && strcmp(setup.name, 'lab')
    load(fullfile(mypath.misc, 'gamma correction', 'norm_gamma_table'))
    setup.old.lut = Screen('LoadNormalizedGammaTable', setup.screen, rgb_lum_corr);
end
[white, black] = deal(WhiteIndex(setup.screen), BlackIndex(setup.screen));
grey = round((white + black) * (1-stim.visual.contr));

% Set screen resolution and refresh rate
setup.old.res = SetResolution(setup.screen, setup.res(1), setup.res(2), setup.refresh);

% Open deafult window
if strcmp(setup.name, 'scanner') || strcmp(setup.name, 'mock')
    [win, rect] = Screen('OpenWindow', setup.screen, grey);
else
    [win, setup.rect] = Screen('OpenWindow', setup.screen, grey);
end
       
% Center coordinates of screen and fixation cross parameters (size, line width) in pixel
[xcenter, ycenter] = RectCenter(setup.rect);

% Set up priorities and query estimated duration of refresh interval
Priority(MaxPriority(win));
ifi = Screen('GetFlipInterval', win); % 1/refresh rate

% Set mac screen black if we are in the lab, otherwise it is good to have control
if strcmp(setup.name, 'lab') && ~debug
    Screen('ConfigureDisplay', 'Capture', 0);
end

% Set text font and size
Screen(win, 'TextFont', setup.text.font);
Screen(win, 'TextSize', setup.text.size);

%% ------------ Fixation cross and pre-final V stimulus --------------

% Fixation cross
[fixwidth, linewidth] = deal(1.0, 0.06); % visual degree
[image, rect] = makefixationcross(fixwidth, linewidth, setup.ppd, grey, white); % grey fixation cross
fixcross.texture = Screen(win, 'MakeTexture', image);
fixcross.rect = CenterRectOnPoint(rect, xcenter, ycenter);

% Generate Gaussian blob if needed
if strcmp(stim.visual.type, 'blob') % gaussian blob
    stim.visual.image = generate_gauss_blob(setup, stim, 0);
    stim.visual.texture = Screen(win, 'MakeTexture', stim.visual.image);
end

% Calculate pixel positions of spheres/blob
ntrials = size(data, 1);
for i=1:ntrials
    if strcmp(stim.visual.type, 'blob') % gaussian blob
        stim.visual.loc(:,i) = [xcenter ycenter];
        xdiam = 6 * floor(stim.visual.xstd * setup.ppd);
        ydiam = 6 * floor(stim.visual.ystd * setup.ppd);
        stim.visual.rect(i,:) = CenterRectOnPoint([0 0 xdiam ydiam], stim.visual.loc(1,i), stim.visual.loc(2,i));
    elseif strcmp(stim.visual.type, 'cloud') % gaussian cloud of dots
        spheres = generatespheres(stim, '2-fold', 0);
        stim.visual.loc(:,1,i) = round(xcenter + spheres(:,1) * setup.ppd);
        stim.visual.loc(:,2,i) = round(ycenter + spheres(:,2) * setup.ppd);
        xydiam = stim.visual.diam * setup.ppd;
        stim.visual.rect(:,:,i) = CenterRectOnPoint([0 0 xydiam xydiam], stim.visual.loc(:,1,i), stim.visual.loc(:,2,i));
    end
end

% Block start id if needed
blockid = unique([1; find(data.blocktype ~= circshift(data.blocktype, 1))]);

%% ------------- Initializing keyboard and mouse ----------------

% Get access to any keyboard
KbName('UnifyKeyNames');

% Define key responses
if ismember(setup.name, {'mock' 'scanner' 'mac'})
    for i=1:length(key.instruction)
        WaitSecs(1);
        DrawFormattedText(win, sprintf('Please, choose key for %s source', key.instruction{i}), 'center', 'center', white);
        Screen(win, 'Flip');
        [secs, keycode] = KbWait(setup.kb.subj);
        key.code(i) = find(keycode);
        Screen(win, 'FillRect', grey);
        Screen(win, 'Flip');
    end
else
    key.code = KbName(key.str);
end
key.list = zeros(1, 256);
key.list(key.code) = 1;
find(key.list);
key.quit = KbName('q'); % key for quit

% Start KbQueue (to back-up responses) and suppress key presses at command window
if ~strcmp(setup.name, 'office')
    KbQueueCreate(setup.kb.subj);
    KbQueueStart;
    ListenChar(2);
end

% Hide mouse cursor when not debugging
if ~debug
    HideCursor;
end

%% ------------ Timing variables and trigger if needed --------------

% Preallocate stimulus onsets and offsets
time.predonset = time.ISI:time.ISI:ntrials*time.ISI;
[time.vonset, time.voffset, time.aonset, time.aoffset] = deal(zeros(ntrials, 1));

% Receive trigger and save start time
if strcmp(setup.name, 'scanner') && setup.trigger
    %     labjack = MyLabJack; % default fio4 is LOW
    %     labjack.verbose = false;
    lj = labJack('verbose', false);
    while 1
        lj.getDIO(4); % update fio4
        if lj.fio4
            time.start = GetSecs;
            break % break if fio4 is HIGH
        end
    end
    lj.close
else
    time.start = GetSecs;
end
time.predonset = time.predonset + time.start;

%% ------- Loop of trials ----------
for i=1:ntrials
    
    % Abort the experiment by the operator at any time
    [pressed, secs, keycode, deltasecs] = KbCheck(setup.kb.op);
    if pressed && keycode(key.quit)
        break
    end
    
    % Subject instructions at the beginning of blocks
    if ismember(i, blockid)
        timebreak = GetSecs;
        WaitSecs(1); % a bit of extra time
        if ismember(data.blocktype(blockid), {'A' 'P'})
            line{1} = 'Localize the sound';
        elseif strcmp(data.blocktype(blockid), 'V')
            line{1} = 'Localize the visual stimulus';
        end
        if length(key.str) == 2
            line{2} = sprintf('Press %s for LEFT and %s for RIGHT', key.str{:});
        elseif length(key.str) == 4
            line{2} = sprintf('Press %s, %s, %s, %s from LEFT to RIGHT, respectively', key.str{:});
        end
        line{3} = 'Press any button to start!';
        
        % Display instructions
        Screen(win, 'FillRect', grey);
        DrawFormattedText(win, sprintf('%s\n\n%s\n\n\n\n%s', line{:}), 'center', 'center', white);
        Screen(win, 'Flip');
        
        % Wait for response
        KbWait(setup.kb.subj);
        Screen(win, 'FillRect', grey);
        Screen(win, 'Flip');
        
        % Update stimulus onset
        time.predonset(i:end) = time.predonset(i:end) + GetSecs - timebreak;
    end
    
    % Palamedes operations
    if strcmp(run.type, 'P') && data.trialtype(i)
        if UD{data.trialtype(i)}.stop
            % Use the treshold estimate from now on
            UD{data.trialtype(i)}.treshold = PAL_AMUD_analyzeUD_Ago(UD{data.trialtype(i)}, 'reversals', UD{data.trialtype(i)}.stopRule(1));
            data.aloc(i) = data.aloc(i) * round(UD{data.trialtype(i)}.treshold);
            
            % Check if there is any on-going staircase, otherwise break
            trialtype = setdiff(unique(data.trialtype), [0 data.trialtype(i)]);
            isstop = true;
            for j=1:length(trialtype)
                if ~UD{trialtype(j)}.stop
                    isstop = false;
                end
            end
            if isstop
                break
            end
        else
            % Update A loc based on the corresponding staircase
            data.aloc(i) = data.aloc(i) * UD{data.trialtype(i)}.xCurrent;
        end
    end
    
    % Fixation cross
    Screen(win, 'DrawTexture', fixcross.texture, [], fixcross.rect);
    Screen(win,'Flip');
    
    if ismember(data.blocktype(i), {'A' 'P'})
        % Calculate final audio stimulus with ramp on-off
        if strcmp(stim.audio.type, 'ITD')
            whitenoise = randn(round(stim.audio.freq * stim.dur), 1) / 3; % gaussian white noise
            whitenoise(whitenoise>1) = 1; % cutoff above +3std
            whitenoise(whitenoise<-1) = -1; % cutoff below -3std
            timeshift = round(stim.audio.freq * stim.ITD.level(abs(data.aloc(i))==unique(abs(stim.loc)))); % time shift for ITD manipulation
            if data.aloc(i) > 0
                stim.audio.loc(:,1,i) = [zeros(timeshift, 1); whitenoise(1:end-timeshift)];
                stim.audio.loc(:,2,i) = whitenoise;
            elseif data.aloc(i) < 0
                stim.audio.loc(:,1,i) = whitenoise;
                stim.audio.loc(:,2,i) = [zeros(timeshift, 1); whitenoise(1:end-timeshift)];
            else
                stim.audio.loc(:,1:2,i) = repmat(whitenoise, 1, 2);
            end
        elseif strcmp(stim.audio.type, 'rec')
            stim.audio.loc(:,1,i) = subj.recL{stim.aloc==data.aloc(i),data.rec(i)};
            stim.audio.loc(:,2,i) = subj.recR{stim.aloc==data.aloc(i),data.rec(i)};
        end
        stim.audio.loc(:,:,i) = stim.audio.loc(:,:,i) / max(max(abs(stim.audio.loc(:,:,i)))); % normalize to be within [-1 1]
        ramp = round(stim.audio.freq * stim.audio.ramp); % calculate ramp
        stim.audio.loc(1:ramp,:,i) = stim.audio.loc(1:ramp,:,i) .* repmat((1:ramp)', 1, 2) / ramp; % add ramp on
        stim.audio.loc(end-ramp+1:end,:,i) = stim.audio.loc(end-ramp+1:end,:,i) .* repmat((ramp:-1:1)', 1, 2) / ramp; % add ramp off
        
        % Buffer the  sound
        PsychPortAudio('FillBuffer', pahandle, stim.audio.loc(:,:,i)');
        
        % Display audio data
        PsychPortAudio('Start', pahandle, 1, time.predonset(i));
        [time.aonset(i), endsecs, xruns, time.aoffset(i)] = PsychPortAudio('Stop', pahandle, 1);
        
    elseif strcmp(data.blocktype(i), 'V')
        % Calculate final visual stimulus
        if strcmp(stim.visual.type, 'blob') % gaussian blob
          stim.visual.rect(i,[1 3]) = stim.visual.rect(i,[1 3]) + data.vloc(i) * setup.ppd;
        elseif strcmp(stim.visual.type, 'cloud') % gaussian cloud of dots
          stim.visual.rect(:,[1 3],i) = stim.visual.rect(:,[1 3],i) + data.vloc(i) * setup.ppd;
        end
        
        % Prepare visual data
        Screen(win, 'DrawTexture', fixcross.texture, [], fixcross.rect);
        if strcmp(stim.visual.type, 'blob') % gaussian blob
            Screen(win, 'DrawTexture', stim.visual.texture, [], stim.visual.rect(i,:));
        elseif strcmp(stim.visual.type, 'cloud') % gaussian cloud of dots
            Screen(win, 'FillOval', white, stim.visual.rect(:,:,i)');
        end
        
        % Display visual data
        [vblvonset, time.vonset(i), fliptimestamp, missed, beampos] = Screen(win, 'Flip', time.predonset(i) - ifi/2);
        
        % Draw fixation cross, stop visual stimulus
        Screen(win, 'DrawTexture', fixcross.texture, [], fixcross.rect);
        [vblvoffset, time.voffset(i), fliptimestamp, missed, beampos] = Screen(win, 'Flip', time.vonset(i) + stim.dur - ifi/2);
    end
    
    % Collect responses
    while 1
        [pressed, secs, keycode, deltasecs] = KbCheck(setup.kb.subj);
        keyid = find(keycode);
        if pressed && length(keyid) == 1 % multiple responses are excluded
            if keycode(key.quit)
                break
            elseif ismember(keyid, key.code)
                time.RT(i) = secs - time.aonset(i);
                data.resp(i) = find(keyid==key.code);
                if strcmp(run.type, 'P') && data.trialtype(i)
                    if length(key.str) == 2
                        aloc = [-abs(data.aloc(i)) abs(data.aloc(i))]; 
                    elseif length(key.str) == 4
                        aloc = [-abs(data.aloc(i)) -stim.azimuth stim.azimuth abs(data.aloc(i))];
                    end
                    UD{data.trialtype(i)} = PAL_AMUD_updateUD_Ago(UD{data.trialtype(i)}, aloc(data.resp(i))==data.aloc(i)); % update palamedes
                end
                break
            end
        end
        if GetSecs > time.predonset(i) + time.ISI - time.buff;
            break
        end
    end  
end

%% ---------------- Save data and clean up ------------------

% End of the experiment
time.end = GetSecs;
    
% Save all key presses for back-up
try
    KbQueueStop;
    key.all = [];
    while KbEventAvail
        key.all = [key.all KbEventGet];
    end
catch
    fprintf('Back-up saving of key presses was not successful.\n')
end

% Save data
fname = fullfile(mypath.data, sprintf('%s_run%d_%s.mat', subj.id, run.id, datestr(now, 'mm_dd_HH_MM')));
if strcmp(run.type, 'P')
    save(fname, 'subj', 'data', 'setup', 'stim', 'time', 'key', 'UD')
else
    save(fname, 'subj', 'data', 'setup', 'stim', 'time', 'key')
end
% if ismember('copydata', fieldnames(mypath)) && ~strcmp(setup.name, 'mac')
%     fname = fullfile(mypath.copydata, sprintf('%s_run%d_%s.mat', subj.id, run.id, datestr(now, 'mm_dd_HH_MM')));
%     try
%         save(fname, 'subj', 'data', 'setup', 'stim', 'time', 'key')
%     catch
%         fprintf('Data could not be saved to Dropbox.\n')
%     end
% end

% Clean up screen
sca
if strcmp(setup.name, 'lab')
    Screen('ConfigureDisplay', 'Release', 0);
end
if ~debug
    ShowCursor;
    Screen('Preference', 'VisualDebugLevel', setup.old.visdeb);
    if strcmp(setup.name, 'lab')
        Screen('LoadNormalizedGammaTable', setup.screen, setup.old.lut);
    end
end
Screen('Preference', 'Verbosity', setup.old.verb);
SetResolution(setup.screen, setup.old.res);
Priority(0);

% Clean up keyboard
if ~strcmp(setup.name, 'office')
    WaitSecs(1); % to avoid displaying last key press in the command window
    KbQueueStop;
    KbQueueRelease;
    ListenChar(0);
end

PsychPortAudio('Close', pahandle);

end