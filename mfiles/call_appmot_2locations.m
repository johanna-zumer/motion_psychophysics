% call_appmot_2location

close all;
clear all;
% timing between auditory cue and auditory stimulus is confirmed at exactly 1 second (plus or minus less than 1ms)

%% changeable params per experiment

setup.subid='test';
% setup.headwidth=.155; % in m     % JZ=.145        % These 4 params were used by Rohe 2015 with CIPIC
% setup.headdepth=.195;             % JZ=.18
% setup.headcircumference=.59;     % JZ=.56
% setup.headheight=.225;           % JZ=.215

setup.vlocation='office'; % 'office' or 'mri' or 'mock' or '313a' or 'mac' or 'meg'
setup.alocation='office'; % 'office' or 'mri' or 'mock' or '313a' or 'mac' or 'meg'
setup.lj=0;  % =1 for yes use Labjack, and =0 for no don't use Labjack

setup.paradigm='cued'; % 'nocue' or 'cued'
setup.cuetype='aud'; % aud or vis
stim.cueprob=[3/10 6/10]; % only for 'cued' condition; percentages (0-1) of congruency likelihood % cue percentages best if such that numerators stay small  (e.g. not 7/10)
stim.cuedaudonly=1/10;  % percentage of cued trials which are aud-only; set to zero if all cued trials are AV
setup.cueord=[1 2]; % [1 2] or [2 1]


stim.isi_flip=[3];  % titrate this with piloting, but leave fixed for final; (1 flip is 16.7ms); [1 2 3 4]
stim.dur_flip=[7];  % 3 means 50ms; 6 means 100ms [ 2 3 4]
stim.asynch=[0]; % seconds; negative means visual first e.g. [-.1 0 .1]

stim.block='av'; % blocktype: 'av' or 'visonly' or 'audonly';
% stim.block='audonly'; % blocktype: 'av' or 'visonly' or 'audonly';
% stim.block='visonly'; % blocktype: 'av' or 'visonly' or 'audonly';

setup.mtrlpercnd=3; % multisensory trials per condition
setup.atrlpercnd=3; % auditory only trials per condition
setup.vtrlpercnd=0; % visual only trials per condition

stim.audio.stim='brownnoise'; % 'tone' or 'whitenoise' or 'noisytone'
stim.backepi=0; % is background EPI noise playing?
stim.audio.type='MIT'; % 'ITD' or 'ILD' or 'ILDITD' or 'cipic' or 'MIT' or 'rec'

stim.loc=sort([-1 1]); % degrees; rest of code assumes this is sorted left to right

stim.feedback=[0 0];  % [0 0] for no feedback; [X Y] means skip X trials then do feedback based on Y trials

setup.timingtesting=0;

setup.av.askfmdcs=1; % =0 means ask FMD, =1 means ask CS, =2 means Both FMD & CS

setup.includeintro=0;

if setup.timingtesting
  stim.vis.diam=0.8;  % degrees
else
%   stim.vis.diam=0.2;  % 1.5 or 0.2 degrees
%   stim.vis.diam=0.8;  % 1.5 or 0.2 degrees
  stim.vis.diam=1.0;  % 1.5 or 0.2 degrees
end

% setup.avaudalone=.1; %  percentage of trials: should an AV block also contain some auditory only trials?

%% Open labjack

if setup.lj
  if ~exist('lj')
    lj = labJack('deviceID', 3, 'verbose', true); %open a U3 with verbose logging on
  end
  if strfind(lj.version,'FAILED')
    error('opening labjack failed');
  end
end


%% Paths
% Debug mode
% dbstop if error % MATLAB
setup.debug = 0; % PTB.  May be overwritten below depending on computer

setup.save=1;

try
    [ret,setup.name]=system('hostname');
    setup.name=strtrim(setup.name);
%  setup.name=getenv('computername');
catch
  setup.name=setup.vlocation;
end
    

% write this later
% mypath=setupdirs(subid);
switch setup.name
  case 'COLLES-140591'
    setup.rdir='C:\Users\zumerj\Documents\motion_psychophysics\';
  case 'PSYCHL-132432'
    setup.rdir='D:\motion_psychophysics\';
    setup.debug = 1; % PTB
  case 'NopBook03.local'
    setup.rdir='/Users/zumerj/Documents/MATLAB/motion_psychophysics/';
  case 'NopBook2.local'
    setup.rdir='/Users/zumerj/Documents/MATLAB/motion_psychophysics/';
  case 'PPPMEGSTIM'
      setup.rdir='C:\Users\MEGuser\Documents\Johanna\MultSens_ISMINO\motion_psychophysics\';
  otherwise
    error('what computer are you on?')
end
if ispc
  bdir=[setup.rdir 'behav_data\'];
  pdir=[setup.rdir 'behav_data\presentation\'];
  mjdir=[setup.rdir 'behav_data\presentation\MatlabGarbageCollector'];
else
  bdir=[setup.rdir 'behav_data/'];
  pdir=[setup.rdir 'behav_data/presentation/'];
  mjdir=[setup.rdir 'behav_data/presentation/MatlabGarbageCollector'];
end


% Adding MatlabGarbageCollector.jar to the dynamic java path
% javaaddpath(fullfile(mypath.root,'presentation','MatlabGarbageCollector.jar'));
javaaddpath(mjdir);
cd(bdir)

addpath(genpath(setup.rdir));

%%
if setup.timingtesting
  stim.cueprob=[2/10 8/10]; % only for 'cued' condition; percentages (0-1) of congruency likelihood % cue percentages best if such that numerators stay small  (e.g. not 7/10)
  stim.cuedaudonly=0;  % percentage of cued trials which are aud-only; set to zero if all cued trials are AV
end

switch stim.block
  case 'av'
    if any(setup.mtrlpercnd*2./stim.cueprob~=round(setup.mtrlpercnd*2./stim.cueprob))
      error('adjust stim.cueprob and/or setup.mtrlpercnd')
    end
end

if round((sum(stim.cueprob)+stim.cuedaudonly)*1000)/1000~=1
  error('incorrect values for stim.cueprob and/or stim.cuedaudonly')
end

% switch stim.audio.type
%   case {'cipic' 'MIT'}
%     if any(rem(stim.loc,5))
%       error(['The ' stim.audio.type ' database must have a stim.loc divisible by 5'])
%     end
% end

%% expt settings
stim.time_to_onset = 0.6; % seconds
stim.time_to_onset_addedrange=0.2; % seconds
% setup.type='two'; % or 'three' (locations of stimulus)
stim.mixblock=0;  % mixblock=1 is mix multiensory and unisensory; mixblock=0 separate blocks for aud,vis,ms



%% general

% Here we call some default settings for setting up Psychtoolbox
try
PsychDefaultSetup(2); % maybe 2 for colour range?
catch
    
end

% Make sure the script is running on Psychtoolbox-3 (PTB-3)
AssertOpenGL;


%% Keyboard
% Specify keyboards for the operator as well as for the participant
setup.kb.op = min(GetKeyboardIndices); % operator
setup.kb.subj = max(GetKeyboardIndices); % participant

% always needs to be put if using KbName!!!!!
KbName('UnifyKeyNames');

% % Inter Stimulus Interval
% time.ISI = 2.4;
% 
% % Buffer time from response collection to next stimulus presentation
% time.buff = 0.4;

%% Screen/display

setup = setup_screen(setup);

setup.trigger = 0;
if strcmp(setup.name, 'scanner')
  str = input('Do you want to use labjack? y/n ', 's');
  if strcmp(str, 'y')
    setup.trigger = 1;
  end
end

% Text font and size
setup.text.font = 'Arial';
setup.text.size = 26;

% Get the screen numbers. This gives us a number for each of the screens attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external screen.
setup.screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
setup.white = WhiteIndex(setup.screenNumber);
setup.black = BlackIndex(setup.screenNumber);
% grey = white / 2;
% grey = black + round((white - black)*0.5);
setup.grey = setup.black + (setup.white - setup.black)*0.5;
setup.red=[setup.white 0 0];


%% AV Stimulus settings

stim.time_to_response=1;
stim.time_endResponse=1;
switch setup.paradigm
  case 'cued'
    if stim.cuedaudonly>0
      cueuse=[stim.cueprob stim.cuedaudonly];
      [minoutcomeval,minoutcome]=min(min(cueuse,1-cueuse));
      [mincueval,mincue]=min(min(stim.cueprob,1-stim.cueprob));
      if minoutcomeval>mincueval
        error('rewrite code or adjust stim.cueprob and stim.cuedaudonly')
      end
      cueratios(:,1)=round(1000*stim.cueprob/minoutcomeval)/1000;
      cueratios(:,2)=round(1000*(1-stim.cueprob-stim.cuedaudonly)/minoutcomeval)/1000;
      cueratios(:,3)=1;
      if any(cueratios(:)~=round(cueratios(:)))
        error('adjust stim.cueprob and stim.cuedaudonly')
      end
      if min(mincueval,1-mincueval)==mincueval
        stim.mreps(mincue,1)=setup.mtrlpercnd*2*length(stim.asynch)*cueratios(mincue,1);
        stim.mreps(mincue,2)=setup.mtrlpercnd*2*length(stim.asynch)*cueratios(mincue,2);
      else
        stim.mreps(mincue,1)=setup.mtrlpercnd*2*length(stim.asynch)*cueratios(mincue,2);
        stim.mreps(mincue,2)=setup.mtrlpercnd*2*length(stim.asynch)*cueratios(mincue,1);
      end
      stim.mreps(:,3)=setup.mtrlpercnd*2*length(stim.asynch);
      stim.mtotpercue=sum(stim.mreps(mincue,:));
      for cc=setdiff(1:length(stim.cueprob),mincue)
        stim.mreps(cc,1)=stim.cueprob(cc)*stim.mtotpercue;
        stim.mreps(cc,2)=(1-stim.cueprob(cc)-stim.cuedaudonly)*stim.mtotpercue;
      end
      stim.mreps(:,3)=setup.mtrlpercnd*2*length(stim.asynch);
      stim.mreps=round(stim.mreps);
      stim.mtot=stim.mtotpercue*length(stim.cueprob);
      %       stim.onsetjitter=stim.time_to_onset_addedrange*rand(1,stim.mtot);
    else
      [mincueval,mincue]=min(min(stim.cueprob,1-stim.cueprob));
      if min(mincueval,1-mincueval)==mincueval
        stim.mreps(mincue,1)=setup.mtrlpercnd*2*length(stim.asynch);
        stim.mreps(mincue,2)=setup.mtrlpercnd*2*length(stim.asynch)/stim.cueprob(mincue)*(1-stim.cueprob(mincue));
        cueratios(:,1)=round(1000*stim.cueprob/mincueval)/1000;
        cueratios(:,2)=round(1000*(1-stim.cueprob)/mincueval)/1000;
      else
        stim.mreps(mincue,1)=setup.mtrlpercnd*2*length(stim.asynch)/stim.cueprob(mincue)*(1-stim.cueprob(mincue));
        stim.mreps(mincue,2)=setup.mtrlpercnd*2*length(stim.asynch);
      end
      stim.mtotpercue=sum(stim.mreps(mincue,:));
      for cc=setdiff(1:length(stim.cueprob),mincue)
        stim.mreps(cc,1)=stim.cueprob(cc)*stim.mtotpercue;
        stim.mreps(cc,2)=(1-stim.cueprob(cc))*stim.mtotpercue;
      end
      stim.mreps=round(stim.mreps);
      stim.mtot=stim.mtotpercue*length(stim.cueprob)*setup.mtrlpercnd;
      %       stim.onsetjitter=stim.time_to_onset_addedrange*rand(1,stim.mtot);
    end
  case 'nocue'
    stim.motcnd=size(stim.loc,2)^2; % 4 multsens motion conditions for 2 locations
    stim.mreps=setup.mtrlpercnd*stim.motcnd*length(stim.asynch);
    %     stim.onsetjitter=stim.time_to_onset_addedrange*rand(1,stim.mreps);
end





%% visual settings

stim.vis.stimcolour=setup.white; % or black?
stim.vis.backcolour=setup.grey;
% if strcmp(setup.type,'two')
stim.vis.vreps=setup.vtrlpercnd*2*length(stim.isi_flip)*length(stim.dur_flip); % 2 visual conditions
% elseif strcmp(setup.type,'three')
% end

%% auditory settings

if setup.timingtesting
  stim.audio.stim='tone';
end
% if strcmp(setup.type,'two')
stim.audio.areps=setup.atrlpercnd*2*length(stim.isi_flip)*length(stim.dur_flip); % 2 aud motion directions
% elseif strcmp(setup.type,'three')
% end

% Sound sampling frequency
stim.audio.freq = 192000; % 44100
stim.audio.freq = 88200; % necessary for 'COLLES-140591'
stim.audio.freq = 96000; % necessary for 'COLLES-140591'
% warning('ask why I cannot use higher than 88200 Hz audio freq?')

% Volume adjustment
if strcmp(setup.name, 'scanner')
  stim.audio.vol = 1.0; % 82 dB
elseif strcmp(setup.name, 'mock')
  stim.audio.vol = 0.3; % 82 dB
elseif strcmp(setup.name, 'COLLES-140591')
  if setup.timingtesting
    stim.audio.vol = 1; % for Audio calibration timing with microphones!  with computer volume set to halfway
    stim.audio.vol = 0.01; % for in-ear microphones binaural;   with computer volume set to halfway
  else
    stim.audio.vol = 0.05; % with computer volume set to halfway
  end
elseif strcmp(setup.name, 'NopBook03.local') || strcmp(setup.name, 'NopBook2.local')
  if setup.timingtesting
    stim.audio.vol = 2;
  else
    stim.audio.vol = 0.3;
  end
else
  warning('using default volume')
  %     stim.audio.vol = 0.06; % 0.08->75 dB 0.18
  stim.audio.vol = 0.3; % 0.08->75 dB 0.18
end
switch setup.alocation
  case 'meg'  % with Notts tubes
    if setup.timingtesting
      stim.audio.vol = 60*stim.audio.vol; 
    else
      stim.audio.vol = 20*stim.audio.vol;
    end
end


switch stim.audio.type % note: these values obtained using 'brownnoise' (as actually presented).  if 'tone' for testing used, then these will be wrong.
  case 'cipic'
    stim.audio.vol=0.35*stim.audio.vol;
  case 'MIT'
    stim.audio.vol=0.075*stim.audio.vol;
  otherwise
    % ITD, ILD, and ILDITD are all the same as each other
end    

% Sound ramp on-off
if setup.timingtesting
  stim.audio.ramp = 0;
else
  stim.audio.ramp = 0.005;
end
stim.audio.tone=1000; % Hz

% Generate (ITD) or get (recording) audio data
stim.ITD.soundspeed = 343; % in m/sec at 20C temperature
switch stim.audio.type
  case {'ITD' 'ILDITD'}
    stim.ITD.level = sind(unique(abs(stim.loc))) * setup.headwidth / stim.ITD.soundspeed;
end

if strcmp(stim.audio.type, 'rec')
  %     stim.rec.cutoff = 0.6;
  %     stim.rec.bp = {1800 15000};
  [subj, stim] = getaudio(subj, bdir, stim, 'rec');
end

stim.audio.lat.lev = 1;
stim.audio.lat.bias = 0;

switch stim.audio.type
  case {'ILD' 'ILDITD'}
    setup.headradius=mean([setup.headwidth setup.headdepth])/2;
end

setup.cipicfit=1;  % set to 1 for normal use of fitting headsize to database; =0 for testing a specific predefined entry in the database
setup.cipicsub='165';  % must match one of cipic subject indices

%% Generate trial sequence

% data = generate_data_motion(setup, stim);
% Number of stimulus locations
nlocs = length(stim.loc);
if nlocs~=2
  error('setup.type and stim.loc do not match');
end
switch stim.block
  case 'av'
    
    % establish all possible conditions
    switch setup.paradigm
      case 'cued'
        savc=[];
        for cc=1:length(stim.cueprob)
          for cong=1:size(stim.mreps,2) % cong =1 means congruent; cong=2 means incongruent; cong=3 means aud-alone
            if stim.cuedaudonly>0
              motcndtmp=stim.mreps(cc,cong)/cueratios(cc,cong)/2/length(stim.asynch); % should equal setup.mtrlpercnd ?
              cue=cc*ones(1,stim.mreps(cc,cong)); % length setup.mtrlpercnd*2 ?
            else
              motcndtmp=stim.mreps(cc,cong)/2/length(stim.asynch);
              cue=cc*ones(1,stim.mreps(cc,cong)*cueratios(cc,cong));
            end
            asynch=[];
            for ss=1:length(stim.asynch)
              asynch=[asynch ss*ones(1,2*motcndtmp*cueratios(cc,cong))]; % index for possible temporal asynchronies
            end
            if cong==1 % congruent
              vstim=repmat([1 2],1,motcndtmp*length(stim.asynch)*cueratios(cc,cong));
              astim=repmat([1 2],1,motcndtmp*length(stim.asynch)*cueratios(cc,cong));
            elseif cong==2 % incongruent
              vstim=repmat([2 1],1,motcndtmp*length(stim.asynch)*cueratios(cc,cong));
              astim=repmat([1 2],1,motcndtmp*length(stim.asynch)*cueratios(cc,cong));
            elseif cong==3 % aud-alone
              vstim=repmat([0 0],1,motcndtmp*length(stim.asynch)*cueratios(cc,cong));
              astim=repmat([1 2],1,motcndtmp*length(stim.asynch)*cueratios(cc,cong));
            end
            congseq=vstim==astim;
            savc=[savc, [asynch; astim; vstim; congseq; cue]];
            %             savc=[savc, repmat([asynch; astim; vstim; congseq; cue],[1 setup.mtrlpercnd])];
          end
        end
        savc=repmat(savc,[1 length(stim.isi_flip)]);
        savc(size(savc,1)+1,:)=sort(repmat(1:length(stim.isi_flip),[1 size(savc,2)/length(stim.isi_flip)]));
        savc=repmat(savc,[1 length(stim.dur_flip)]);
        savc(size(savc,1)+1,:)=sort(repmat(1:length(stim.dur_flip),[1 size(savc,2)/length(stim.dur_flip)]));
        stim.mtot=size(savc,2);
        morder=randperm(stim.mtot);
        stim.av.asynchseq=savc(1,morder);
        stim.av.atrialseq=savc(2,morder);
        stim.av.vtrialseq=savc(3,morder);
        stim.av.congseq=savc(4,morder);
        stim.av.cueseq=savc(5,morder);
        stim.isiseq=savc(6,morder);
        stim.durseq=savc(7,morder);
        stim.onsetjitter=stim.time_to_onset_addedrange*rand(1,stim.mtot);
      case 'nocue'
        asynch=[];
        for ss=1:length(stim.asynch)
          asynch=[asynch ss*ones(1,stim.motcnd)];
        end
        if length(stim.loc)==2
          astim=repmat([1 2 1 2],1,length(stim.asynch));
          vstim=repmat([1 2 2 1],1,length(stim.asynch));
        else
          error('write stim sequence for other than 2 stim locations')
        end
        congseq=vstim==astim;
        savc=repmat([asynch; astim; vstim; congseq],[1 setup.mtrlpercnd]);
        savc=repmat(savc,[1 length(stim.isi_flip)]);
        savc(size(savc,1)+1,:)=sort(repmat(1:length(stim.isi_flip),[1 size(savc,2)/length(stim.isi_flip)]));
        savc=repmat(savc,[1 length(stim.dur_flip)]);
        savc(size(savc,1)+1,:)=sort(repmat(1:length(stim.dur_flip),[1 size(savc,2)/length(stim.dur_flip)]));
        stim.mreps=size(savc,2);
        morder=randperm(stim.mreps);
        stim.av.asynchseq=savc(1,morder);
        stim.av.atrialseq=savc(2,morder);
        stim.av.vtrialseq=savc(3,morder);
        stim.av.congseq=savc(4,morder);
        stim.isiseq=savc(5,morder);
        stim.durseq=savc(6,morder);
        stim.av.congseq=stim.av.vtrialseq==stim.av.atrialseq;
        stim.onsetjitter=stim.time_to_onset_addedrange*rand(1,stim.mreps);
    end
  case 'visonly'
    savc=[];
    for isi=1:length(stim.isi_flip)
      for dur=1:length(stim.dur_flip)
        vstim=1:nlocs;
        isiind=isi*ones(1,nlocs);
        durind=dur*ones(1,nlocs);
        savc=[savc, repmat([vstim; durind; isiind],[1 setup.vtrlpercnd])];
      end
    end
    morder=randperm(stim.vis.vreps);
    stim.vis.trialseq=savc(1,morder);
    stim.durseq=savc(2,morder);
    stim.isiseq=savc(3,morder);
    stim.onsetjitter=stim.time_to_onset_addedrange*rand(1,stim.vis.vreps);
    %     stim.vis.trialseq=[];
    %     for tr=1:setup.vtrlpercnd
    %       stim.vis.trialseq=[stim.vis.trialseq randperm(nlocs)];
    %     end
    %     stim.vis.trialseq=Shuffle(stim.vis.trialseq);
  case 'audonly'
    savc=[];
    for isi=1:length(stim.isi_flip)
      for dur=1:length(stim.dur_flip)
        astim=1:nlocs;
        isiind=isi*ones(1,nlocs);
        durind=dur*ones(1,nlocs);
        savc=[savc, repmat([astim; durind; isiind],[1 setup.atrlpercnd])];
      end
    end
    morder=randperm(stim.audio.areps);
    stim.audio.trialseq=savc(1,morder);
    stim.durseq=savc(2,morder);
    stim.isiseq=savc(3,morder);
    stim.onsetjitter=stim.time_to_onset_addedrange*rand(1,stim.audio.areps);
    %     stim.audio.trialseq=[];
    %     for tr=1:setup.atrlpercnd
    %       stim.audio.trialseq=[stim.audio.trialseq randperm(nlocs)];
    %     end
    %     stim.audio.trialseq=Shuffle(stim.audio.trialseq);
end

%%  Questions / responses
setup.pauseb4q1=1;
setup.maxtime4motdir=5;
setup.maxtime4motper=5;
setup.maxtime4comsrc=5;
setup.cueduration=0.5;
setup.postcue=1;


% if setup.timingtesting
%   setup.askmotdir=1;
%   setup.askmotper=1;
%   setup.askcomsrc=0;
% else
  setup.askmotdir=1;
  setup.askmotper=1;
  setup.askcomsrc=1;
% end

% irrespective, we don't need motion percept for AV trials
switch stim.block
  case 'av'
    if setup.av.askfmdcs==0; % =0 means ask FMD, =1 means ask CS
      setup.askcomsrc=0;
      setup.askmotper=1;
    elseif setup.av.askfmdcs==1; % =0 means ask FMD, =1 means ask CS
      setup.askcomsrc=1;
      setup.askmotper=0;
    elseif setup.av.askfmdcs==2; % =0 means ask FMD, =1 means ask CS
      setup.askcomsrc=1;
      setup.askmotper=1;
    end
end    



setup.cuesym=Shuffle([{'*'} {'#'} {'@'} {':'}]);
if setup.timingtesting
  cues=[900 1100]; % Hz
else
  cues=[400 1600]; % Hz
end
setup.cuefreq=cues(setup.cueord); 

if length(stim.cueprob)>length(setup.cuesym) || length(stim.cueprob)>length(setup.cuefreq)
  error('create more cue symbols')
end

% if strcmp(setup.cuetype,'aud') && length(setup.cuefreq)~=length(stim.cueprob)
%   error('stim.ave.cuefreq and stim.cueprob must be same length')
% end


%% run experiment
if setup.lj
  [resp,stim,setup] = appmot_2locations(setup,stim,lj);
else
  [resp,stim,setup] = appmot_2locations(setup,stim);
end  

if setup.save
  save([setup.subid '_' stim.block '_' resp.timestamp],'setup','stim','resp');
end

% display on screen the results
appmot_assessment
