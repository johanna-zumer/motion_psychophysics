function [resp,stim,setup] = appmot_2locations(setup,stim,varargin)

%% Labjack
if setup.lj && ~isempty(varargin)
  lj=varargin{1};
else
  lj=[];
end

%% screen

disp('debug1')
if setup.debug
  PsychDebugWindowConfiguration % use transparent screen
  Screen('Preference', 'SkipSyncTests', 1); % skip screen synchronization, otherwise error due to PTB debug mode
  setup.old.verb = Screen('Preference', 'Verbosity', 1); % print only errors
else
  Screen('Preference', 'SkipSyncTests', 0); % synchronize screen
  setup.old.verb = Screen('Preference', 'Verbosity'); % print error+warning+status messages
  setup.old.visdeb = Screen('Preference', 'VisualDebugLevel', 3); % turn off PsychToolbox Welcome Sign
end
disp('debug2')

shifttext=200;

% Open an on screen window using PsychImaging and color it grey.
PsychImaging('PrepareConfiguration');
switch setup.name
  case 'PSYCHL-132432'
    % for testing on office computer with 2 screens
    % rect=[1100 100 2124 868]; % modify with Agoston's setup_screen
    rect=[500 100 1724 1068]; % modify with Agoston's setup_screen
    [win, winrect] = PsychImaging('OpenWindow', setup.screenNumber, setup.grey, rect);
  otherwise
    if setup.timingtesting
      [win, winrect] = PsychImaging('OpenWindow', setup.screenNumber, setup.black);
    else
      [win, winrect] = PsychImaging('OpenWindow', setup.screenNumber, setup.grey);
      %       [win, winrect] = PsychImaging('OpenWindow', setup.screenNumber, setup.black);
    end
end
disp('debug3')

HideCursor;

% Measure the vertical refresh rate of the monitor
setup.ifi = Screen('GetFlipInterval', win);
% Retreive the maximum priority number
topPriorityLevel = MaxPriority(win);
% Numer of frames to wait when specifying good timing
% waitframes = 1;

% Define window width and height.
% win_w = (winrect(3)-winrect(1));
% Define window center.
[win_center_x,win_center_y] = RectCenter(winrect);

%     ppd = round(win_w/S.maxVisAngle);

% Use sugLat seconds minimum latency on Windows to not overload the
% system:
if IsWin
  % According to the PsychPortAudioTimingTest I specify 0.015 s for
  % suggested latency.
  sugLat = 0.015;
else
  sugLat = [];
end
% audioOnsetBuffer = ceil((2*sugLat)/setup.ifi)+1;

stim.isi=stim.isi_flip*setup.ifi;
stim.dur=stim.dur_flip*setup.ifi;


%% visual stimulus test / params

% try
%   [fixWidth,lineWidth] = deal(round(posdeg2pix(1.6,setup.mon.dist,setup.screenres)),...
%     round(posdeg2pix(0.1,setup.mon.dist,S.screenres)));
% catch
%   warning('ask Mate for posdeg2pix')
fixWidth=0.5;
lineWidth=0.1;
% end

[fixWhiteImage,fixWhiteRect] = makefixationcross(fixWidth,lineWidth,setup.ppd,setup.grey,setup.white);
fixCrossWhite.texture = Screen('MakeTexture',win,fixWhiteImage);
fixCrossWhite.rect = CenterRectOnPoint(fixWhiteRect,win_center_x,win_center_y);
[fixRedImage,fixRedRect] = makefixationcross(fixWidth,lineWidth,setup.ppd,setup.grey,setup.red);
fixCrossRed.texture = Screen('MakeTexture',win,fixRedImage);
fixCrossRed.rect = CenterRectOnPoint(fixRedRect,win_center_x,win_center_y);


leftsphere=CenterRectOnPoint([0 0 stim.vis.diam*setup.ppd stim.vis.diam*setup.ppd],...
  win_center_x+(stim.loc(1).*setup.ppd),...
  win_center_y+(0.*setup.ppd));

rightsphere=CenterRectOnPoint([0 0 stim.vis.diam*setup.ppd stim.vis.diam*setup.ppd],...
  win_center_x+(stim.loc(2).*setup.ppd),...
  win_center_y+(0.*setup.ppd));

switch setup.name
  case {'NopBook03.local' 'NopBook2.local'  'nopbook2.local' 'nopbook03.local'}
    macshift=.65*shifttext;
  otherwise
    macshift=0;
end


%% audio setup

switch stim.block
  case {'av' 'audonly'}
    % Initialize PsychPortAudio sound driver
    InitializePsychSound(stim.audio.lat.lev);
    
    % Initialize PsychPortAudio sound driver
    InitializePsychSound(1); % level latency mode
    disp('debug4')
    
    % The measured visuo-audio delay (visual onset minus auditory onset
    % mesured with PsycPortAudioTimingTest) of the system depends on the
    % setup we use.
    % It is around: -10.25 ms on setup 'COLLES-140591' (Hills 3.16)
    %               -25 ms on setup 'COLLES-140561' (Hills 3.13)
    % This means that the visual onset is 11 ms ahead of the auditory
    % onset. This sets the auditory onset 11 ms ahead to compensate for the
    % delay.
    if strcmpi(setup.name,'COLLES-140591')
      latBias = -0.008;
    elseif strcmpi(setup.name,'COLLES-140561') || strcmpi(setup.name,'PSYCHL-132432')% NOT RECOMMENDED FOR EEG!!!
      warning('Psychophysics only, not EEG!');
      latBias = -0.025;
    elseif strcmpi(setup.name,'NopBook03.local') || strcmpi(setup.name,'NopBook2.local') || strcmpi(setup.name, 'nopbook2.local') || strcmpi(setup.name,'nopbook03.local')
      switch setup.alocation
        case 'meg'
          latBias = -0.009; % from before 2016
          latBias = -0.016;
        case 'mac_hp' % using electronic headphoens
          latBias = -0.017;
        case 'mac_et' % using Nop EArTone
          latBias = -0.016;
        otherwise
          error('please specify either meg, mac_hp, or mac_et')
      end
    elseif strcmpi(setup.name,'PPPMEGSTIM')
      latBias = -0.008;
      warning('Test PPPMEGSTIM timing')
    else
      warning('Unrecognized setup, stimulus timing might be inaccurate! ');
      latBias = 0;
    end
    
    % reqLatencyClass level 2 means: Take full control over the audio
    % device, even if this causes other sound applications to fail or
    % shutdown.
    %     if strcmp(S.expMode,'test')
    if setup.debug
      reqLatencyClass = 0;
    else
      reqLatencyClass = 2;
    end
    % Number of audio channels.
    nAudioChannels = 2;
    
    % Open default sound device
    audiomode=8; % must be 8 to be used as 'master'
    % unfortunately this doesn't work on any OS/computer I tried.
    audiomode=1;
    % Office: Audio subsystem is Windows DirectSound, Audio device is Primary Sound Driver, device id is 8
    % pamaster = PsychPortAudio('Open', [], audiomode, [], stim.audio.freq, 2);
    % Open audio device.
    
    
    devices = PsychPortAudio('GetDevices',3); % setting '3' means Windows/ASIO
    if length(devices)>1
      error('which audio device to use?')
    elseif length(devices)<1
      warning('no Windows ASIO here')
      pamaster = PsychPortAudio('Open',[],audiomode,reqLatencyClass,stim.audio.freq,nAudioChannels,[],sugLat);
    else
      pamaster = PsychPortAudio('Open',devices.DeviceIndex,audiomode,reqLatencyClass,stim.audio.freq,nAudioChannels,[],sugLat);
    end
    disp('debug5')
    
    %  Audio stim creation
    switch stim.audio.type
      case {'ITD' 'ILDITD'}
        timeshift = round(stim.audio.freq * stim.ITD.level); % time shift for ITD manipulation
      otherwise
        timeshift = 0;
    end
    
    % Make audio stim in matrix
    for dur=1:length(stim.dur)
      whitenoise = randn(round(stim.audio.freq * stim.dur(dur)), 1) / 3; % gaussian white noise
      whitenoise(whitenoise>1) = 1; % cutoff above +3std
      whitenoise(whitenoise<-1) = -1; % cutoff below -3std
      tone = sin(2*pi*stim.audio.tone*(1/stim.audio.freq:1/stim.audio.freq:stim.dur(dur)))';
      %       timeshift = round(stim.audio.freq * stim.ITD.level(abs(data.aloc(i))==unique(abs(stim.loc)))); % time shift for ITD manipulation
      noisytone=conv(whitenoise,tone,'same');
      noisytone=noisytone./max(abs(noisytone));
      
      switch stim.audio.stim
        case 'tone'
          audstim=tone;
          if ~setup.timingtesting
            error('code so randomise exact realisation of this stim; see brownnoise');
          end
        case 'whitenoise'
          audstim=whitenoise;
          error('code so randomise exact realisation of this stim; see brownnoise');
        case 'noisytone'
          audstim=noisytone;
          error('code so randomise exact realisation of this stim; see brownnoise');
        case 'brownnoise'
          try
            switch setup.name
              case 'PPPMEGSTIM'
                brownnoise=load('C:\Users\MEGuser\Documents\Johanna\MultSens_ISMINO\sounds_wavfiles\brownnoise.mat');
              otherwise
                brownnoise=load([setup.rdir(1:end-21) 'sounds_wavfiles\brownnoise.mat']);
            end
          catch
            brownnoise=load('/Users/zumerj/Documents/MATLAB/sounds_wavfiles/brownnoise.mat');
            addpath(genpath('/Applications/MATLAB_R2011b.app/toolbox/signal/signal/'))
          end
          brownresamp=resample(brownnoise.y,stim.audio.freq,brownnoise.Fs);
          setup.brownnoisestart=round(rand*10000);  % randomise initial position of brownnoise file, so diff stims used each block; introduced 18/4/16 (thus, after 
          audstim=brownresamp( (setup.brownnoisestart+1) : (setup.brownnoisestart+round(stim.dur(dur)*stim.audio.freq)) );
        otherwise
          error('please specify appropriate auditory stimulus type')
      end
      
      switch stim.audio.type
        case {'ILD' 'ILDITD'}
          audstimfft=fft(audstim,4*length(audstim));
          freq=linspace(0,stim.audio.freq/2,length(audstimfft)/2);
          %         freqall=[freq -fliplr(freq)];
          % can't compute where the denominator goes through a pole
          %         Hl=[(1+cosd(max(stim.loc)+90))*freqall+2*stim.ITD.soundspeed/setup.headradius]./[freqall+2*stim.ITD.soundspeed/setup.headradius];
          %         Hr=[(1+cosd(max(stim.loc)-90))*freqall+2*stim.ITD.soundspeed/setup.headradius]./[freqall+2*stim.ITD.soundspeed/setup.headradius];
          for ss=1:length(stim.loc)
            Hl=[(1+cosd(stim.loc(ss)+90))*freq+2*stim.ITD.soundspeed/setup.headradius]./[freq+2*stim.ITD.soundspeed/setup.headradius];
            Hr=[(1+cosd(stim.loc(ss)-90))*freq+2*stim.ITD.soundspeed/setup.headradius]./[freq+2*stim.ITD.soundspeed/setup.headradius];
            Hlf=[Hl fliplr(Hl)];
            Hrf=[Hr fliplr(Hr)];
            
            audstiml=real(ifft(Hlf'.*audstimfft));
            audstimr=real(ifft(Hrf'.*audstimfft));
            audstimlear(:,ss)=audstiml(1:length(audstim));
            audstimrear(:,ss)=audstimr(1:length(audstim));
          end
        case {'ITD'}
          audstimlear=repmat(audstim,[1 length(stim.loc)]);
          audstimrear=repmat(audstim,[1 length(stim.loc)]);
      end
      
      % go through all cases here
      % (:,1) is left channel; (:,2) is right channel
      switch stim.audio.type
        case {'ITD' 'ILD' 'ILDITD'}
          %           stim.audio.right{dur}(:,1) = [zeros(timeshift, 1); audstim(1:end-timeshift)];
          %           stim.audio.right{dur}(:,2) = audstim;
          %           stim.audio.left{dur}(:,1) = audstim;
          %           stim.audio.left{dur}(:,2) = [zeros(timeshift, 1); audstim(1:end-timeshift)];
          %           stim.audio.centre{dur}(:,1:2) = repmat(audstim, 1, 2);
          
          stim.audio.left{dur}(:,1) = audstimlear(:,1); % left ear; left sound
          stim.audio.left{dur}(:,2) = [zeros(timeshift, 1); audstimrear(1:end-timeshift,1)]; % right ear; left sound
          stim.audio.right{dur}(:,1) = [zeros(timeshift, 1); audstimlear(1:end-timeshift,2)]; % left ear; right sound
          stim.audio.right{dur}(:,2) = audstimrear(:,2); % right ear; right sound
          stim.audio.centre{dur}(:,1:2) = repmat(audstim, 1, 2);  % both ears; central sound
        case 'cipic'
          switch setup.name
            case 'PSYCHL-132432'
              cdir='D:\Matlab\cipIC_hrtf_database\';
            case 'COLLES-140591'
              cdir='C:\Users\zumerj\Documents\motion_psychophysics\CIPIC_hrtf_database\';
            otherwise
              error('where is CIPIC on this computer?')
          end
          addpath([cdir 'standard_hrir_database\show_data']);
          % copied from show_data.m
          A = [-80 -65 -55 -45:5:45 55 65 80];   % Azimuths
          E = -45:(360/64):235;                  % Elevation
          fs         = 44100;                    % Sampling frequency in Hz
          T = (0:(1/fs):((200-1)/fs))*1000;      % Times in ms
          euse=dsearchn(E',0);  % elevation zero degrees
          ause=dsearchn(A',stim.loc');  % elevation zero degrees
          
          xsub=nan(1,17);
          xsub(1)= setup.headwidth;
          xsub(2)= setup.headheight;
          xsub(3)= setup.headdepth;
          xsub(16) = setup.headcircumference;
          xsub=xsub*100; % convert m to cm
          
          % cipic was made at 1m distance. subtract off delay in hrir for this distance if different than from screen.
          hrirshift=(1-setup.mon.dist/100)/stim.ITD.soundspeed; % time (s) to cut off hrir.  if negative, then add it on as padding
          % but hrirshift is too large!  1.5ms
          
          
          if setup.cipicfit
            [hrir,dist]=choose_cipic_subject(xsub,cdir,1);
            setup.cipicsub=hrir.name(end-2:end);
          else
            hrir=load([cdir 'standard_hrir_database\subject_' setup.cipicsub '\hrir_final.mat']);
          end
          
          % 'standard' for volume calibration
          hrir061=load([cdir 'standard_hrir_database\subject_061\hrir_final.mat']);
          
          % Volume across different database participants is not equal.
          % Must normalise first, to be equivalent to other audio.types
          if 1
            hrir.hrir_r(ause,euse,:)=hrir.hrir_r(ause,euse,:).*repmat(rms(rms(hrir061.hrir_r(ause,euse,:),3))./rms(rms(hrir.hrir_r(ause,euse,:),3)),[2 1 200]);
            hrir.hrir_l(ause,euse,:)=hrir.hrir_l(ause,euse,:).*repmat(rms(rms(hrir061.hrir_l(ause,euse,:),3))./rms(rms(hrir.hrir_l(ause,euse,:),3)),[2 1 200]);
            
          else  % this had been created using recordings but then didn't perceptually work
            switch hrir.name
              case 'subject_003'
                stim.audio.vol=1.6*stim.audio.vol; % 1.9
              case 'subject_010'
                stim.audio.vol=2.4*stim.audio.vol;
              case 'subject_018'
                stim.audio.vol=1.3*stim.audio.vol;
              case 'subject_020'
                stim.audio.vol=0.45*stim.audio.vol;
              case 'subject_021'
                stim.audio.vol=2.7*stim.audio.vol;
              case 'subject_027'
                stim.audio.vol=1.9*stim.audio.vol;
              case 'subject_040'
                stim.audio.vol=1.2*stim.audio.vol;
              case 'subject_044'
                stim.audio.vol=1.0*stim.audio.vol;
              case 'subject_050'
                stim.audio.vol=0.8*stim.audio.vol;
              case 'subject_051'
                stim.audio.vol=2.4*stim.audio.vol;
              case 'subject_058'
                stim.audio.vol=1.0*stim.audio.vol;
              case 'subject_059'
                stim.audio.vol=0.8*stim.audio.vol;
              case 'subject_060'
                stim.audio.vol=0.95*stim.audio.vol;
              case 'subject_061' % this was the 'standard'
                stim.audio.vol=1.0*stim.audio.vol;
              case 'subject_065'
                stim.audio.vol=0.6*stim.audio.vol;
              case 'subject_119'
                stim.audio.vol=0.95*stim.audio.vol;
              case 'subject_131'
                stim.audio.vol=1.4*stim.audio.vol; % 2.4
              case 'subject_133'
                stim.audio.vol=2.4*stim.audio.vol;
              case 'subject_134'
                stim.audio.vol=0.95*stim.audio.vol;
              case 'subject_147'
                stim.audio.vol=1.85*stim.audio.vol;
              case 'subject_148'
                stim.audio.vol=2.6*stim.audio.vol;
              case 'subject_153'
                stim.audio.vol=2.3*stim.audio.vol;
              case 'subject_154'
                stim.audio.vol=2.5*stim.audio.vol;
              case 'subject_156'
                stim.audio.vol=2.8*stim.audio.vol;
              case 'subject_165'
                stim.audio.vol=3.0*stim.audio.vol;
              otherwise
                error('we do not have the correct volume for this cipic subject')
            end
          end
          
          error('check if this should be conv or filter; see documentation')
          cutconv=80;
          learlstim=conv(audstim,resample(squeeze(hrir.hrir_l(ause(1),euse,:)),stim.audio.freq,fs));
          learlstim=learlstim(cutconv+1:cutconv+length(audstim));
          rearlstim=conv(audstim,resample(squeeze(hrir.hrir_r(ause(1),euse,:)),stim.audio.freq,fs));
          rearlstim=rearlstim(cutconv+1:cutconv+length(audstim));
          
          learrstim=conv(audstim,resample(squeeze(hrir.hrir_l(ause(2),euse,:)),stim.audio.freq,fs));
          learrstim=learrstim(cutconv+1:cutconv+length(audstim));
          rearrstim=conv(audstim,resample(squeeze(hrir.hrir_r(ause(2),euse,:)),stim.audio.freq,fs));
          rearrstim=rearrstim(cutconv+1:cutconv+length(audstim));
          
          stim.audio.left{dur}(:,1) = learlstim;
          stim.audio.left{dur}(:,2) = rearlstim;
          stim.audio.right{dur}(:,1) = learrstim;
          stim.audio.right{dur}(:,2) = rearrstim;
          stim.audio.centre{dur}(:,1:2) = repmat(audstim, 1, 2);  % both ears; central sound
        case 'MIT'
          
          switch setup.name
            case 'PSYCHL-132432'
              mitdir='D:\motion_psychophysics\mit_hrtf\elev0\';
            case 'COLLES-140591'
              mitdir='C:\Users\zumerj\Documents\motion_psychophysics\mit_hrtf\elev0\';
            case {'NopBook03.local' 'NopBook2.local'  'nopbook2.local' 'nopbook03.local'}
              mitdir='/Users/zumerj/Documents/MATLAB/motion_psychophysics/mit_hrtf/elev0/';
            case 'PPPMEGSTIM'
              mitdir='C:\Users\MEGuser\Documents\Johanna\MultSens_ISMINO\mit_hrtf\elev0\';
            otherwise
              error('where is MIT HRTF on this computer?')
          end
          
          % L is 'normal' size pinna; 'R' is 2*std larger sized pinna
          if max(stim.loc)==10
            learlwav=audioread([mitdir 'L0e350a.wav']);
            rearlwav=audioread([mitdir 'L0e010a.wav']);
            learrwav=audioread([mitdir 'L0e010a.wav']); % instead of R0e350a, as recommended by documentation
            [rearrwav,fs]=audioread([mitdir 'L0e350a.wav']);
            
            learlwav_resamp=resample(learlwav,stim.audio.freq,fs);
            learrwav_resamp=resample(learrwav,stim.audio.freq,fs);
            rearlwav_resamp=resample(rearlwav,stim.audio.freq,fs);
            rearrwav_resamp=resample(rearrwav,stim.audio.freq,fs);
          elseif max(stim.loc)==5
            learlwav=audioread([mitdir 'L0e355a.wav']);
            rearlwav=audioread([mitdir 'L0e005a.wav']);
            learrwav=audioread([mitdir 'L0e005a.wav']); % instead of R0e355a, as recommended by documentation
            [rearrwav,fs]=audioread([mitdir 'L0e355a.wav']);
            
            learlwav_resamp=resample(learlwav,stim.audio.freq,fs);
            learrwav_resamp=resample(learrwav,stim.audio.freq,fs);
            rearlwav_resamp=resample(rearlwav,stim.audio.freq,fs);
            rearrwav_resamp=resample(rearrwav,stim.audio.freq,fs);
          elseif any(max(stim.loc)==0.5:0.5:15)
            %             interpolate_hrir('mit', stim.audio.freq, [-10:1:10], 0, 1); % called this way to create file loaded below
            %             interpolate_hrir('mit', stim.audio.freq, [-15:0.5:15], 0, 1); % called this way to create file loaded below
            load([mitdir(1:end-6) 'normal_hrir_interpolated_el0.mat']);
            %             if ~all(azimuth_int==[-10:10])
            if ~all(azimuth_int==[-15:0.5:15])
              error('this MIT interp file is not expected')
            end
            learlwav_resamp=hrirL_int(:,dsearchn(azimuth_int',min(stim.loc)));
            learrwav_resamp=hrirL_int(:,dsearchn(azimuth_int',max(stim.loc)));
            rearlwav_resamp=hrirR_int(:,dsearchn(azimuth_int',min(stim.loc)));
            rearrwav_resamp=hrirR_int(:,dsearchn(azimuth_int',max(stim.loc)));
          else
            error('MIT hrtf only has angles in multiples of 5; interpolate to your desired azimuth')
          end
          %           if max(stim.loc)==10
          %             learlwav=audioread([mitdir 'R0e010a.wav']);
          %             rearlwav=audioread([mitdir 'R0e350a.wav']);
          %             learrwav=audioread([mitdir 'R0e350a.wav']); % instead of L0e010a, as recommended by documentation
          %             [rearrwav,fs]=audioread([mitdir 'R0e010a.wav']);
          %           elseif max(stim.loc)==5
          %             learlwav=audioread([mitdir 'R0e005a.wav']);
          %             rearlwav=audioread([mitdir 'R0e355a.wav']);
          %             learrwav=audioread([mitdir 'R0e355a.wav']); % instead of L0e010a, as recommended by documentation
          %             [rearrwav,fs]=audioread([mitdir 'R0e005a.wav']);
          %           else
          %             error('MIT hrtf only has angles in multiples of 5')
          %           end
          
          switch stim.audio.freq
            case 96000
              cutconv=80;
            otherwise
              error('give another cutconv value')
          end
          learlstim=conv(audstim,learlwav_resamp);
          learlstim=learlstim(cutconv+1:cutconv+length(audstim));
          rearlstim=conv(audstim,rearlwav_resamp);
          rearlstim=rearlstim(cutconv+1:cutconv+length(audstim));
          
          learrstim=conv(audstim,learrwav_resamp);
          learrstim=learrstim(cutconv+1:cutconv+length(audstim));
          rearrstim=conv(audstim,rearrwav_resamp);
          rearrstim=rearrstim(cutconv+1:cutconv+length(audstim));
          
          %           learlstim=conv(audstim,resample(learlwav,stim.audio.freq,fs));
          %           learlstim=learlstim(cutconv+1:cutconv+length(audstim));
          %           rearlstim=conv(audstim,resample(rearlwav,stim.audio.freq,fs));
          %           rearlstim=rearlstim(cutconv+1:cutconv+length(audstim));
          %
          %           learrstim=conv(audstim,resample(learrwav,stim.audio.freq,fs));
          %           learrstim=learrstim(cutconv+1:cutconv+length(audstim));
          %           rearrstim=conv(audstim,resample(rearrwav,stim.audio.freq,fs));
          %           rearrstim=rearrstim(cutconv+1:cutconv+length(audstim));
          
          stim.audio.left{dur}(:,1) = learlstim;
          stim.audio.left{dur}(:,2) = rearlstim;
          stim.audio.right{dur}(:,1) = learrstim;
          stim.audio.right{dur}(:,2) = rearrstim;
          stim.audio.centre{dur}(:,1:2) = repmat(audstim, 1, 2);  % both ears; central sound
          
        case 'rec'
          stim.audio.right{dur}(:,1) = subj.recL{1,data.rec(1),durmap(dur)};
          stim.audio.right{dur}(:,2) = subj.recR{1,data.rec(1),durmap(dur)};
          stim.audio.left{dur}(:,1) = subj.recL{2,data.rec(2),durmap(dur)};
          stim.audio.left{dur}(:,2) = subj.recR{2,data.rec(2),durmap(dur)};
          %       stim.audio.loc(:,1,i) = subj.recL{stim.aloc==data.aloc(i),data.rec(i)};
          %       stim.audio.loc(:,2,i) = subj.recR{stim.aloc==data.aloc(i),data.rec(i)};
      end
      if dur==1
        cuetones(:,1,:)=sin(2*pi*setup.cuefreq'*(1/stim.audio.freq:1/stim.audio.freq:setup.cueduration))';
        cuetones=repmat(cuetones,[1 2 1]);
      end
      
      %     stim.audio.loc(:,:,i) = stim.audio.loc(:,:,i) / max(max(abs(stim.audio.loc(:,:,i)))); % normalize to be within [-1 1]
      stim.audio.left{dur} = stim.audio.left{dur} / max(abs(stim.audio.left{dur}(:))); % normalize to be within [-1 1]
      stim.audio.right{dur} = stim.audio.right{dur} / max(abs(stim.audio.right{dur}(:))); % normalize to be within [-1 1]
      stim.audio.centre{dur} = stim.audio.centre{dur} / max(abs(stim.audio.centre{dur}(:))); % normalize to be within [-1 1]
      ramp = round(stim.audio.freq * stim.audio.ramp); % calculate ramp
      %     stim.audio.loc(1:ramp,:,i) = stim.audio.loc(1:ramp,:,i) .* repmat((1:ramp)', 1, 2) / ramp; % add ramp on
      %     stim.audio.loc(end-ramp+1:end,:,i) = stim.audio.loc(end-ramp+1:end,:,i) .* repmat((ramp:-1:1)', 1, 2) / ramp; % add ramp off
      stim.audio.left{dur}(1:ramp,:) = stim.audio.left{dur}(1:ramp,:) .* repmat((1:ramp)', 1, 2) / ramp; % add ramp on
      stim.audio.left{dur}(end-ramp+1:end,:) = stim.audio.left{dur}(end-ramp+1:end,:) .* repmat((ramp:-1:1)', 1, 2) / ramp; % add ramp off
      stim.audio.right{dur}(1:ramp,:) = stim.audio.right{dur}(1:ramp,:) .* repmat((1:ramp)', 1, 2) / ramp; % add ramp on
      stim.audio.right{dur}(end-ramp+1:end,:) = stim.audio.right{dur}(end-ramp+1:end,:) .* repmat((ramp:-1:1)', 1, 2) / ramp; % add ramp off
      stim.audio.centre{dur}(1:ramp,:) = stim.audio.centre{dur}(1:ramp,:) .* repmat((1:ramp)', 1, 2) / ramp; % add ramp on
      stim.audio.centre{dur}(end-ramp+1:end,:) = stim.audio.centre{dur}(end-ramp+1:end,:) .* repmat((ramp:-1:1)', 1, 2) / ramp; % add ramp off
      
      cuetones=0.5*cuetones/max(cuetones(:));
      cuetones(1:ramp,:,:) = cuetones(1:ramp,:,:) .* repmat((1:ramp)', [1 2 2]) / ramp;
      cuetones(end-ramp+1:end,:,:) = cuetones(end-ramp+1:end,:,:) .* repmat((ramp:-1:1)', [1 2 2]) / ramp;
      
      for isi=1:length(stim.isi)
        stim.audio.movleft{dur,isi} =[stim.audio.right{dur}; zeros(round(stim.audio.freq*(stim.isi(isi)+stim.dur(dur))),2)]+[zeros(round(stim.audio.freq*(stim.isi(isi)+stim.dur(dur))),2); stim.audio.left{dur}];
        stim.audio.movright{dur,isi}=[stim.audio.left{dur}; zeros(round(stim.audio.freq*(stim.isi(isi)+stim.dur(dur))),2)]+[zeros(round(stim.audio.freq*(stim.isi(isi)+stim.dur(dur))),2); stim.audio.right{dur}];
      end
      
      clear audstiml* audstimr*
    end % dur
    setup.timeshift=timeshift;
    
    % FIXME: make this general over all stimtypes!
    
    % Create test sounds to test headphones.
    audstimtest=stim.audio.movleft{dur,isi}(1:length(audstim),1); % doesn't matter if it's 1 or 2 here for the test
    
    stim.audio.testright(:,1) = zeros(3*length(audstim),1);
    stim.audio.testright(:,2) = [audstimtest; zeros(size(audstim)); audstimtest];
    stim.audio.testleft(:,1) = [audstimtest; zeros(size(audstim)); audstimtest];
    stim.audio.testleft(:,2) = zeros(3*length(audstim),1);
    stim.audio.testcentre(:,1) = [audstimtest; zeros(size(audstim)); audstimtest];
    stim.audio.testcentre(:,2) = [audstimtest; zeros(size(audstim)); audstimtest];
    
    
    % Control over volume and latency bias
    
    % The visuo-auditory delay compensation takes place here.
    PsychPortAudio('LatencyBias', pamaster, latBias);
    
    % paslave1 = PsychPortAudio('OpenSlave', pamaster); % first presentation of sound
    % paslave2 = PsychPortAudio('OpenSlave', pamaster); % second presentation of sound
    
    % Generate some beep sound 1000 Hz, 0.1 secs, 50% amplitude and fill it
    % in the buffer for prehetin playback.
    mynoise(1,:) = 0.5 * MakeBeep(1000,0.1,stim.audio.freq);
    mynoise(2,:) = mynoise(1,:);
    PsychPortAudio('FillBuffer',pamaster,mynoise);
    PsychPortAudio('Volume',pamaster,0);
    PsychPortAudio('Start',pamaster,1,0);
    PsychPortAudio('Stop',pamaster,1);
    
    PsychPortAudio('Volume',pamaster,stim.audio.vol);
  otherwise
    disp('not presenting any sounds')
end
disp('debug6')


%% Setup keyboard codes / responses

% maximum time for the stimulus part to present within a trial
stim.time_trial=max(stim.asynch)-min(stim.asynch)+max(stim.dur)*2+max(stim.isi_flip)*setup.ifi;

try
  ft_defaults
catch
end
tok=tokenize(mat2str(round(clock)),' ');
tok{1}=tok{1}(2:end);
tok{end}=tok{end}(1:end-1);
for tt=2:6
  if length(tok{tt})==1
    tok{tt}=['0' tok{tt}];
  end
end
resp.timestamp=tok2str(tok,'_');

% resp.starttime=GetSecs;
resp.dircor=[];

switch stim.block
  case 'av'
    switch setup.paradigm
      case 'cued'
        if setup.cuetrain
          [resp.rtmotper,resp.rtmotdir,resp.rtcomsrc,resp.rtcueprob,resp.motperkeycode,resp.motdirkeycode,resp.comsrckeycode,resp.cueprobkeycode]=deal(nan(1,stim.mtot));
        else
          [resp.rtmotper,resp.rtmotdir,resp.rtcomsrc,resp.motperkeycode,resp.motdirkeycode,resp.comsrckeycode]=deal(nan(1,stim.mtot));
        end
      case 'nocue'
        [resp.rtmotper,resp.rtmotdir,resp.rtcomsrc,resp.motperkeycode,resp.motdirkeycode,resp.comsrckeycode]=deal(nan(1,stim.mreps));
    end
  case 'audonly'
    [resp.rtmotper,resp.rtmotdir,resp.rtcomsrc,resp.motperkeycode,resp.motdirkeycode,resp.comsrckeycode]=deal(nan(1,stim.audio.areps));
  case 'visonly'
    [resp.rtmotper,resp.rtmotdir,resp.rtcomsrc,resp.motperkeycode,resp.motdirkeycode,resp.comsrckeycode]=deal(nan(1,stim.vis.vreps));
end

% try
Priority(topPriorityLevel);

% Always needs to be put if using KbName!
KbName('UnifyKeyNames');

switch setup.rlocation
  case 'meg'
    KbQueueCreate(min(GetKeyboardIndices))
    KbQueueCreate(max(GetKeyboardIndices))
    KbQueueStart(max(GetKeyboardIndices))
  case 'mac'
    KbQueueCreate(min(GetKeyboardIndices))
    KbQueueStart(min(GetKeyboardIndices))
end

% to exit the program
quit   = KbName('ESCAPE');
% defining keys for input
% loc1Key = KbName('j');    % corresponding to 'flicker' or (certain) 'same'
% loc2Key = KbName('k');    % corresponding to 'motion' (or uncertain 'same')
% loc3Key = KbName('l');    % corresponding to 'distinct' or (uncertain) 'different'
% loc4Key = KbName('s');    % corresponding to (uncertain) motion to the left
% loc5Key = KbName('f');    % corresponding to (certain) motion to the right
% loc6Key = KbName('d');    % corresponding to centretest (or uncertain motion to the right)
% loc7Key = KbName('a');    % corresponding to certain motion to the left
% loc8Key = KbName(';');    % corresponding to uncertain 'different'
switch setup.rlocation
  case 'meg'
    loc1Key = KbName('9(');    % corresponding to (certain) 'same'
    loc2Key = KbName('8*')    % corresponding to 'flicker' or (uncertain) 'same' (and Lheadphones) (and 'same' if setup.respcertCS=0)
    loc3Key = KbName('7&')    % corresponding to 'motion' or (uncertain) 'different') (and Cheadphones) (and 'different' if setup.respcertCS=0) (and cuetrain)
    loc4Key = KbName('6^')    % corresponding to 'distinct' or (certain) 'different' (and Rheadphones)
    loc5Key = KbName('1!');    % corresponding to (certain) motion to the left
    loc6Key = KbName('2@');    % corresponding to (uncertain) motion to the left (and cuetrain)
    loc7Key = KbName('3#');    % corresponding to (uncertain) motion to the right
    loc8Key = KbName('4$');    % corresponding to (certain) motion to the right
  case 'macold' % how it was for Bham EEG (and n01 and n02)
    %     loc1Key = KbName('h');    % corresponding to 'flicker' or (certain) 'same'
    %     loc2Key = KbName('j');    % corresponding to 'motion' (or uncertain 'same')
    %     loc3Key = KbName('k');    % corresponding to 'distinct' or (uncertain) 'different'
    %     loc4Key = KbName('s');    % corresponding to (uncertain) motion to the left
    %     loc5Key = KbName('f');    % corresponding to (certain) motion to the right
    %     loc6Key = KbName('d');    % corresponding to centretest (or uncertain motion to the right)
    %     loc7Key = KbName('a');    % corresponding to certain motion to the left
    %     loc8Key = KbName('l');    % corresponding to uncertain 'different'
    loc5Key = KbName('h');    % corresponding to 'flicker' or (certain) 'same'
    loc6Key = KbName('j');    % corresponding to 'motion' (or uncertain 'same')
    loc7Key = KbName('k');    % corresponding to 'distinct' or (uncertain) 'different'
    loc2Key = KbName('s');    % corresponding to (uncertain) motion to the left
    loc4Key = KbName('f');    % corresponding to (certain) motion to the right
    loc3Key = KbName('d');    % corresponding to centretest (or uncertain motion to the right)
    loc1Key = KbName('a');    % corresponding to certain motion to the left
    loc8Key = KbName('l');    % corresponding to uncertain 'different'
  case 'mac' % from n03 onwards
    %     loc8Key = KbName('a');    % corresponding to (certain) 'same' (*)
    %     loc1Key = KbName('s');    % corresponding to 'flicker' or (uncertain) 'same' (*) (and Lheadphones*)
    %     loc2Key = KbName('d');    % corresponding to 'motion' or (uncertain) 'different') (*) (and Cheadphones*)
    %     loc3Key = KbName('f');    % corresponding to 'distinct' or (certain) 'different' (*) (and Rheadphones*)
    %     loc7Key = KbName('h');    % corresponding to (certain) motion to the left
    %     loc4Key = KbName('j');    % corresponding to (uncertain) motion to the left
    %     loc6Key = KbName('k');    % corresponding to (uncertain) motion to the right
    %     loc5Key = KbName('l');    % corresponding to (certain) motion to the right
    loc1Key = KbName('a');    % corresponding to (certain) 'same'
    loc2Key = KbName('s');    % corresponding to 'flicker' or (uncertain) 'same' (and Lheadphones) (and 'same' if setup.respcertCS=0)
    loc3Key = KbName('d');    % corresponding to 'motion' or (uncertain) 'different') (and Cheadphones) (and 'different' if setup.respcertCS=0) (and cuetrain)
    loc4Key = KbName('f');    % corresponding to 'distinct' or (certain) 'different' (and Rheadphones)
    loc5Key = KbName('h');    % corresponding to (certain) motion to the left
    loc6Key = KbName('j');    % corresponding to (uncertain) motion to the left (and cuetrain)
    loc7Key = KbName('k');    % corresponding to (uncertain) motion to the right
    loc8Key = KbName('l');    % corresponding to (certain) motion to the right
end
disp('debug7; this is right before trigger 7 sent')

resp.motperkey=[loc2Key loc3Key loc4Key];
if setup.respcertCS
  resp.comsrckey=[loc1Key loc2Key loc3Key loc4Key];
else
  resp.comsrckey=[loc2Key loc3Key];
end
if setup.respcertMD
  resp.motdirkey=[loc5Key loc6Key loc7Key loc8Key];
else
  resp.motdirkey=[loc6Key loc7Key];
end
resp.cuetrainkey=[loc3Key loc6Key];

keycodef=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key,loc7Key,loc8Key]),1);

%% Setup Eyelink eyetracker (if using it)
setup.el.window=win;

if setup.el.enable
  %   setup.edfFile = 'george.edf';
  setup.edfFile=[setup.subid(1:3) '_' tok2str(tok(4:5),'') '.edf']; % max 8 characters
  setup.edfFlag           = '-e';    % -e only convert event samples to asc format (edf still contains everything)
  
  el=Eyelink_start_jz(setup.edfFile);
  el.enable=setup.el.enable;
  el.fb=setup.el.fb;
  setup.el=el;
  if ~setup.el.dummy
    setup.el.online=1;
  else
    setup.el.online=0;
  end
  
  
  %   setup = appmot_setup_el(setup);
  %
  %   % start eyelink recording
  %   if setup.el.online
  %     Eyelink('Message', 'BLOCKID %d', b); % send 'BLOCKID'
  %     Eyelink('StartRecording');
  %     WaitSecs(0.01);
  %     Eyelink('Message', 'SYNCTIME');
  %
  %     % are we recording?
  %     if Eyelink('CheckRecording'); % Returns 0 if recording in progress
  %       Eyelink('Shutdown');
  %       setup.el.online = 0;
  %     end
  %   else
  %     error('EyeLink no longer online')
  %   end
  %   % keep track of saccades (no central fixation)
  %   saccCount = 0;
else
  setup.el.online = 0;
end

%% Begin experiment with headphone test and first trigger

resp.starttime=GetSecs;

jz_sendTrigger(setup,lj,7)
% if setup.lj
%   % trigger start of expt
%   lj.prepareStrobe(7) %prepare a strobed word with value 7
%   lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
% end

% switch setup.vlocation
%   case 'meg'
%     [oldFontName,oldFontNumber]=Screen(win,'TextFont',20);
% end
disp('debug8; right after trigger 7 sent')

% test headphones
if setup.includeintro
  switch stim.block
    case {'av' 'audonly'}
      keycode=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key,loc7Key,loc8Key]),1);
      while ~keycode(loc2Key)
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win,['Headphone test: 2 sounds on the Left (L4) or Centre (L3) or Right (L2)?'], win_center_x-1*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win,['Headphone test: 2 sounds on the Left (S) or Centre (D) or Right (F)?'], win_center_x-1*shifttext+macshift, win_center_y);
            %         Screen('DrawText', win,['Headphone test: 2 sounds on the Left (S) or Centre (D) or Right (F)?'], win_center_x-1*shifttext+macshift, win_center_y, setup.white);
          otherwise
            error('what other setup.rlocation do you use?')
        end
        [~,~,~,missed]=Screen('Flip',win);
        WaitSecs(0.5)
        PsychPortAudio('FillBuffer',pamaster,stim.audio.testleft');
        PsychPortAudio('Start',pamaster);
        RestrictKeysForKbCheck([quit,loc2Key,loc3Key,loc4Key]);
        KbQueueWait;
        allPresses=[];
        while KbEventAvail
          allPresses=[allPresses KbEventGet];
        end
        for event=1:length(allPresses)
          if allPresses(event).Pressed
            keycode(allPresses(event).Keycode)=1;
            break
          end
        end
        if keycode(quit)
          break;
        end
        WaitSecs(0.5)
      end
      keycode=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key]),1);
      while ~keycode(loc4Key)
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win,['Headphone test: 2 sounds on the Left (L4) or Centre (L3) or Right (L2)?'], win_center_x-1*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win,['Headphone test: 2 sounds on the Left (S) or Centre (D) or Right (F)?'], win_center_x-1*shifttext+macshift, win_center_y);
            %         Screen('DrawText', win,['Headphone test: 2 sounds on the Left (S) or Centre (D) or Right (F)?'], win_center_x-1*shifttext+macshift, win_center_y, setup.white);
          otherwise
            error('what other setup.rlocation do you use?')
        end
        [~,~,~,missed]=Screen('Flip',win);
        WaitSecs(0.5)
        PsychPortAudio('FillBuffer',pamaster,stim.audio.testright');
        PsychPortAudio('Start',pamaster);
        RestrictKeysForKbCheck([quit,loc2Key,loc3Key,loc4Key]);
        KbQueueWait;
        allPresses=[];
        while KbEventAvail
          allPresses=[allPresses KbEventGet];
        end
        for event=1:length(allPresses)
          if allPresses(event).Pressed
            keycode(allPresses(event).Keycode)=1;
            break
          end
        end
        % %         [~,keycode]=KbWait([],2);
        %         keynum=max(GetKeyboardIndices)
        %         disp('waiting for right')
        %         [~,keycode]=KbWait(keynum,2);
        if keycode(quit)
          break;
        end
        WaitSecs(0.5)
      end
      keycode=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key]),1);
      while ~keycode(loc3Key)
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win,['Headphone test: 2 sounds on the Left (L4) or Centre (L3) or Right (L2)?'], win_center_x-1*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win,['Headphone test: 2 sounds on the Left (S) or Centre (D) or Right (F)?'], win_center_x-1*shifttext+macshift, win_center_y);
            %         Screen('DrawText', win,['Headphone test: 2 sounds on the Left (S) or Centre (D) or Right (F)?'], win_center_x-1*shifttext+macshift, win_center_y, setup.white);
          otherwise
            error('what other setup.rlocation do you use?')
        end
        [~,~,~,missed]=Screen('Flip',win);
        WaitSecs(0.5)
        PsychPortAudio('FillBuffer',pamaster,stim.audio.testcentre');
        PsychPortAudio('Start',pamaster);
        RestrictKeysForKbCheck([quit,loc2Key,loc3Key,loc4Key]);
        KbQueueWait;
        allPresses=[];
        while KbEventAvail
          allPresses=[allPresses KbEventGet];
        end
        for event=1:length(allPresses)
          if allPresses(event).Pressed
            keycode(allPresses(event).Keycode)=1;
            break
          end
        end
        % %         [~,keycode]=KbWait([],2);
        %         keynum=max(GetKeyboardIndices)
        %         disp('waiting for centre')
        %         [~,keycode]=KbWait(keynum,2);
        if keycode(quit)
          break;
        end
        WaitSecs(0.5)
      end
      
      Screen('DrawText', win,['Three examples: Moving to the left'], win_center_x-shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      WaitSecs(0.5)
      PsychPortAudio('FillBuffer',pamaster,[stim.audio.movleft{max(stim.durseq),max(stim.isiseq)}; zeros(stim.audio.freq,2)]');
      PsychPortAudio('Start',pamaster,3); % 3 repetitions
      
      WaitSecs(5)
      
      Screen('DrawText', win,['Three examples: Moving to the right'], win_center_x-shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      WaitSecs(0.5)
      PsychPortAudio('FillBuffer',pamaster,[stim.audio.movright{max(stim.durseq),max(stim.isiseq)}; zeros(stim.audio.freq,2)]');
      PsychPortAudio('Start',pamaster,3);
      
      WaitSecs(5)
      
      switch stim.block
        case 'av'
          
          Screen('DrawText', win,['Three examples: SOUND moving to the LEFT (Flash SAME)'], win_center_x-shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          WaitSecs(3)
          for tt=1:3
            [tvbl,~,~,missed]=Screen('Flip',win);
            PsychPortAudio('FillBuffer',pamaster,[stim.audio.movleft{max(stim.durseq),max(stim.isiseq)}]');
            PsychPortAudio('Start',pamaster,[],tvbl+11.5*setup.ifi);
            Screen('FillOval',win,setup.white,rightsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi);
            if stim.isi(max(stim.isiseq))>0
              [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq)));
            end
            Screen('FillOval',win,setup.white,leftsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+2*stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            WaitSecs(1)
          end
          WaitSecs(1)
          
          Screen('DrawText', win,['Three examples: SOUND moving to the LEFT (Flash DIFFERENT)'], win_center_x-shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          WaitSecs(3)
          for tt=1:3
            [tvbl,~,~,missed]=Screen('Flip',win);
            PsychPortAudio('FillBuffer',pamaster,[stim.audio.movleft{max(stim.durseq),max(stim.isiseq)}]');
            PsychPortAudio('Start',pamaster,[],tvbl+11.5*setup.ifi);
            Screen('FillOval',win,setup.white,leftsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi);
            if stim.isi(max(stim.isiseq))>0
              [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq)));
            end
            Screen('FillOval',win,setup.white,rightsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+2*stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            WaitSecs(1)
          end
          WaitSecs(1)
          
          Screen('DrawText', win,['Three examples: SOUND moving to the RIGHT (Flash SAME)'], win_center_x-shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          WaitSecs(3)
          for tt=1:3
            [tvbl,~,~,missed]=Screen('Flip',win);
            PsychPortAudio('FillBuffer',pamaster,[stim.audio.movright{max(stim.durseq),max(stim.isiseq)}]');
            PsychPortAudio('Start',pamaster,[],tvbl+11.5*setup.ifi);
            Screen('FillOval',win,setup.white,leftsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi);
            if stim.isi(max(stim.isiseq))>0
              [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq)));
            end
            Screen('FillOval',win,setup.white,rightsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+2*stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            WaitSecs(1)
          end
          WaitSecs(1)
          
          Screen('DrawText', win,['Three examples: SOUND moving to the RIGHT (Flash DIFFERENT)'], win_center_x-shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          WaitSecs(3)
          for tt=1:3
            [tvbl,~,~,missed]=Screen('Flip',win);
            PsychPortAudio('FillBuffer',pamaster,[stim.audio.movright{max(stim.durseq),max(stim.isiseq)}]');
            PsychPortAudio('Start',pamaster,[],tvbl+11.5*setup.ifi);
            Screen('FillOval',win,setup.white,rightsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi);
            if stim.isi(max(stim.isiseq))>0
              [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq)));
            end
            Screen('FillOval',win,setup.white,leftsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+2*stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            WaitSecs(1)
          end
          WaitSecs(1)
          
      end
      
  end
end

jz_sendTrigger(setup,lj,6)
% if setup.lj
%   % done with examples; now final instructions
%   lj.prepareStrobe(6) %prepare a strobed word
%   lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
% end


% Reminding of key responses
flipcnt=0;
fliptimecnt=0;
RestrictKeysForKbCheck([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key,loc7Key,loc8Key]);
switch stim.block
  case 'av'
    motdirseq=stim.av.atrialseq;
    
    switch setup.paradigm
      case 'nocue'
        ntrials=stim.mreps;
        flipmiss=zeros(1,ntrials+1);
        if setup.askmotper
          switch setup.rlocation
            case 'meg'
              Screen('DrawText', win, ['Reminder: Flicker ' 'L4' ', Motion ' 'L3' ', Distinct ' 'L2' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
            case 'mac'
              Screen('DrawText', win, ['Reminder: Flicker ' upper(KbName(resp.motperkey(1))) ', Motion ' upper(KbName(resp.motperkey(2))) ', Distinct ' upper(KbName(resp.motperkey(3))) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
            otherwise
              error('what setup.rlocation are you using?')
          end
          [~,~,~,missed]=Screen('Flip',win);
          %           KbPressWait;
          KbQueueWait_jz
        end
    end
    
    if setup.askmotdir
      if setup.respcertMD
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win,['Reminder: Sound moving to LEFT (certain=' 'R2' ', uncertain=' 'R3' ') or RIGHT (uncertain=' 'R4' ', certain=' 'R5' ').  Press to continue'], win_center_x-2*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win,['Reminder: Sound moving to LEFT (certain=' upper(KbName(loc5Key)) ', uncertain=' upper(KbName(loc6Key)) ') or RIGHT (uncertain=' upper(KbName(loc7Key)) ', certain=' upper(KbName(loc8Key)) ').  Press to continue'], win_center_x-2*shifttext+macshift, win_center_y);
        end
      else
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win,['Reminder: Sound moving to left ' 'R3' ' or right ' 'R4' ' (Press to continue'], win_center_x-2*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win,['Reminder: Sound moving to left ' upper(KbName(loc6Key)) ' or right ' upper(KbName(loc7Key)) ' (Press to continue'], win_center_x-2*shifttext+macshift, win_center_y);
        end
      end
      [~,~,~,missed]=Screen('Flip',win);
      %       KbPressWait;
      KbQueueWait_jz
    end
    
    switch setup.paradigm
      case 'cued'
        ntrials=stim.mtot;
        for cc=1:length(stim.cueprob)
          cueprobshow=stim.cueprob(cc)/sum(stim.cueprob);
          switch setup.cuetype
            case 'vis'
              Screen('DrawText', win,['This cue ' setup.cuesym{cc} ' means ' num2str(round(100*cueprobshow)) ' probability AudVis same' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
            case 'audcong'
              Screen('DrawText', win,['This sound means ' num2str(round(100*cueprobshow)) ' probability AudVis same' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
              PsychPortAudio('FillBuffer',pamaster,cuetones(:,:,cc)');
              PsychPortAudio('Start',pamaster);
            case 'audmod'
              if cueprobshow>.5
                Screen('DrawText', win,['This sound means attend to the Flash/dot' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
              elseif cueprobshow<.5
                Screen('DrawText', win,['This sound means attend to the Sound' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
              end
              PsychPortAudio('FillBuffer',pamaster,cuetones(:,:,cc)');
              PsychPortAudio('Start',pamaster);
          end
          [~,~,~,missed]=Screen('Flip',win);
          %           KbPressWait;
          KbQueueWait_jz
        end
    end
    
    if setup.askcomsrc
      if setup.respcertCS
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win, ['Auditory and visual object SAME (certain=' 'L5' ', uncertain=' 'L4' ') or DIFFERENT (uncertain=' 'L3' ', certain=' 'L4' '). Press to continue'] , win_center_x-2*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win, ['Auditory and visual object SAME (certain=' upper(KbName(loc1Key)) ', uncertain=' upper(KbName(loc2Key)) ') or DIFFERENT (uncertain=' upper(KbName(loc3Key)) ', certain=' KbName(loc4Key) '). Press to continue'] , win_center_x-2*shifttext+macshift, win_center_y);
        end
        resp.corcong(stim.av.congseq==1,1)=loc1Key; % audvis congruent (certain; uncertain)
        resp.corcong(stim.av.congseq==1,2)=loc2Key; % audvis congruent (certain; uncertain)
        resp.corcong(stim.av.congseq==0,1)=loc4Key; % audvis incongruent (certain; uncertain)
        resp.corcong(stim.av.congseq==0,2)=loc3Key; % audvis incongruent (certain; uncertain)
        resp.corcong(stim.av.congseq==0 & ~stim.av.vtrialseq,1:2)=nan; % aud alone (so no response required)
      else
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win, ['Auditory and visual object same ' 'L4' ' or different ' 'L3' ' (Press to continue)'] , win_center_x-2*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win, ['Auditory and visual object same ' upper(KbName(loc2Key)) ' or different ' upper(KbName(loc3Key)) ' (Press to continue)'] , win_center_x-2*shifttext+macshift, win_center_y);
        end
        resp.corcong(stim.av.congseq==1)=loc2Key; % audvis congruent
        resp.corcong(stim.av.congseq==0)=loc3Key; % audvis incongruent
        resp.corcong(stim.av.congseq==0 & ~stim.av.vtrialseq)=nan; % aud alone (so no response required)
      end
      [~,~,~,missed]=Screen('Flip',win);
      %       KbPressWait;
      KbQueueWait_jz
    end
    
  case 'audonly'
    ntrials=stim.audio.areps;
    flipmiss=zeros(1,ntrials+1);
    if setup.askmotper
      switch setup.rlocation
        case 'meg'
          Screen('DrawText', win, ['Reminder: Flicker ' 'L4' ', Motion ' 'L3' ', Distinct ' 'L2' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
        case 'mac'
          Screen('DrawText', win, ['Reminder: Flicker ' upper(KbName(resp.motperkey(1))) ', Motion ' upper(KbName(resp.motperkey(2))) ', Distinct ' upper(KbName(resp.motperkey(3))) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
      end
      [~,~,~,missed]=Screen('Flip',win);
      %       KbPressWait;
      KbQueueWait_jz
    end
    if setup.askmotdir
      if setup.respcertMD
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win,['Reminder: Sound moving to left (certain) ' 'R2' ' (uncertain) ' 'R3' ' or right (uncertain) ' 'R4' ' (certain) ' 'R5' ' (Press to continue'], win_center_x-3*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win,['Reminder: Sound moving to left (certain) ' upper(KbName(loc5Key)) ' (uncertain) ' upper(KbName(loc6Key)) ' or right (uncertain) ' upper(KbName(loc7Key)) ' (certain) ' upper(KbName(loc8Key)) ' (Press to continue'], win_center_x-3*shifttext+macshift, win_center_y);
        end
      else
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win,['Reminder: Sound moving to left ' 'R3' ' or right ' 'R4' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win,['Reminder: Sound moving to left ' upper(KbName(loc6Key)) ' or right ' upper(KbName(loc7Key)) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
        end
      end
      [~,~,~,missed]=Screen('Flip',win);
      %       KbPressWait;
      KbQueueWait_jz
    end
    %     resp.cormotdir(stim.audio.trialseq==1)=loc5Key; % motion starting on left moving to right
    %     resp.cormotdir(stim.audio.trialseq==2)=loc4Key; % motion starting on right moving to left
    motdirseq=stim.audio.trialseq;
  case 'visonly'
    ntrials=stim.vis.vreps;
    flipmiss=zeros(1,ntrials+1);
    if setup.askmotper
      switch setup.rlocation
        case 'meg'
          Screen('DrawText', win, ['Reminder: Flicker ' 'L4' ', Motion ' 'L3' ', Distinct ' 'L2' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
        case 'mac'
          Screen('DrawText', win, ['Reminder: Flicker ' upper(KbName(resp.motperkey(1))) ', Motion ' upper(KbName(resp.motperkey(2))) ', Distinct ' upper(KbName(resp.motperkey(3))) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
      end
      [~,~,~,missed]=Screen('Flip',win);
      %       KbPressWait;
      KbQueueWait_jz
    end
    if setup.askmotdir
      if setup.respcertMD
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win,['Reminder: Dot moving to left (certain) ' 'R2' ' (uncertain) ' 'R3' ' or right (uncertain) ' 'R4' ' (certain) ' 'R5' ' (Press to continue'], win_center_x-3*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win,['Reminder: Dot moving to left (certain) ' upper(KbName(loc5Key)) ' (uncertain) ' upper(KbName(loc6Key)) ' or right (uncertain) ' upper(KbName(loc7Key)) ' (certain) ' upper(KbName(loc8Key)) ' (Press to continue'], win_center_x-3*shifttext+macshift, win_center_y);
        end
      else
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win,['Reminder: Dot moving to left ' 'R3' ' or right ' 'R4' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win,['Reminder: Dot moving to left ' upper(KbName(loc6Key)) ' or right ' upper(KbName(loc7Key)) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
        end
      end
      [~,~,~,missed]=Screen('Flip',win);
      %       KbPressWait;
      KbQueueWait_jz
    end
    %     resp.cormotdir(stim.vis.trialseq==1)=loc5Key; % motion starting on left moving to right
    %     resp.cormotdir(stim.vis.trialseq==2)=loc4Key; % motion starting on right moving to left
    motdirseq=stim.vis.trialseq;
end

if setup.respcertMD
  resp.cormotdir(motdirseq==1,1)=loc8Key; % motion to right (certain)
  resp.cormotdir(motdirseq==1,2)=loc7Key; % motion to right (uncertain)
  resp.cormotdir(motdirseq==2,1)=loc5Key; % motion to left (certain)
  resp.cormotdir(motdirseq==2,2)=loc6Key; % motion to left (uncertain)
else
  resp.cormotdir(motdirseq==1)=loc7Key; % motion to right
  resp.cormotdir(motdirseq==2)=loc6Key; % motion to left
end


jz_sendTrigger(setup,lj,5)
% if setup.lj
%   % now about to start real trial sequence
%   lj.prepareStrobe(5) %prepare a strobed word
%   lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
% end

%% loop through trials
try
  resp.stimstart=nan(1,ntrials);
  for itrial=1:ntrials
    
    % Probe the Mac even when setup.rlocation='meg' for Escape pressed
    % (often need to hold it down continuously)
    [pressed, secs, keycode, deltasecs] = KbCheck(min(GetKeyboardIndices));
    if pressed && keycode(quit)
      break
    end
    
    switch setup.rlocation
      case 'meg'
        KbQueueCreate(max(GetKeyboardIndices))
        KbQueueStart(max(GetKeyboardIndices))
      case 'mac'
        KbQueueCreate(min(GetKeyboardIndices))
        KbQueueStart(min(GetKeyboardIndices))
    end
    
    jz_sendTrigger(setup,lj,20)
    %     if setup.lj
    %       % Trial start
    %       lj.prepareStrobe(20) %prepare a strobed word
    %       lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
    %     end
    if setup.el.online
      Eyelink('Message', 'TRIALID %d', itrial);     % send 'TRIALID'
      % This supplies the title at the bottom of the eyetracker display
      Eyelink('command', 'record_status_message "TRIAL %d/%d"', itrial, ntrials);
    end
    
    
    switch stim.block
      case 'av'
        time_vis=stim.asynch(stim.av.asynchseq(itrial))-min(stim.asynch);
        time_aud=-min(stim.asynch);  % this is also 'time zero'
      case {'visonly' 'audonly'}
        time_vis=0;
        time_aud=0;
    end
    
    switch stim.block
      case {'av' 'audonly'}
        switch stim.block
          case 'av'
            if stim.av.atrialseq(itrial)==2 % 2 for start on right, move to left
              audstim=stim.audio.movleft{stim.durseq(itrial),stim.isiseq(itrial)}';
              %               if setup.lj, ljaudstim=32; end
              ljaudstim=32;
            elseif stim.av.atrialseq(itrial)==1 % 1 for start on left, move to right
              audstim=stim.audio.movright{stim.durseq(itrial),stim.isiseq(itrial)}';
              ljaudstim=31;
            end
          case 'audonly'
            if stim.audio.trialseq(itrial)==2 % 2 for start on right, move to left
              audstim=stim.audio.movleft{stim.durseq(itrial),stim.isiseq(itrial)}';
              ljaudstim=32;
            elseif stim.audio.trialseq(itrial)==1 % 1 for start on left, move to right
              audstim=stim.audio.movright{stim.durseq(itrial),stim.isiseq(itrial)}';
              ljaudstim=31;
            end
        end
    end
    
    % Check input
    [~,~,keyCode] = KbCheck;
    
    switch setup.paradigm
      case 'cued'
        switch setup.cuetype
          case {'audmod' 'audcong'}
            Screen('DrawTexture',win,fixCrossWhite.texture,[],fixCrossWhite.rect);
            PsychPortAudio('FillBuffer',pamaster,cuetones(:,:,stim.av.cueseq(itrial))');
          case 'vis'
            % just flip
        end
      case 'nocue'
        [~,~,~,missed]=Screen('Flip',win);
        Screen('DrawTexture',win,fixCrossWhite.texture,[],fixCrossWhite.rect);
    end
    [~,~,~,missed]=Screen('Flip',win);
    
    if 1
      WaitSecs(stim.time_to_onset+stim.onsetjitter(itrial)-5.5*setup.ifi);
      [tvbl,~,~,missed]=Screen('Flip',win);
    else
      [tvbl,~,~,missed]=Screen('Flip',win,stim.time_to_onset+stim.onsetjitter(itrial)-5.5*setup.ifi);
    end
    
    switch setup.paradigm
      case 'cued'
        resp.stimstart(itrial)=tvbl+6*setup.ifi;  % an additional 6*setup.ifi will be added on to all time.
      case 'nocue'
        resp.stimstart(itrial)=tvbl+6*setup.ifi;  % an additional 6*setup.ifi will be added on to all time.
    end
    
    % Present cue, if 'cued' paradigm
    switch setup.paradigm
      case 'cued'
        switch setup.cuetype
          case {'audmod' 'audcong'}
            PsychPortAudio('Start',pamaster,[],resp.stimstart(itrial)-0.5*setup.ifi);
            jz_sendTrigger(setup,lj,20+stim.av.cueseq(itrial))
            %             if setup.lj
            %               % 21 for cue 1 (setup.cuefreq(1)) and 22 for cue 2 (setup.cuefreq(2))
            %               lj.prepareStrobe(20+stim.av.cueseq(itrial)) %prepare a strobed word
            %               lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
            %             end
            resp.time_startcue(itrial)=resp.stimstart(itrial)-0.5*setup.ifi;
            %           WaitSecs(setup.cueduration);
            %           resp.time_endcue(itrial)=GetSecs;
            if setup.cuetrain
              [tvbl,~,~,missed]=Screen('Flip',win,resp.stimstart(itrial)-3*setup.ifi); % Thus, 50ms after previous flip
            else
              [tvbl,~,~,missed]=Screen('Flip',win,resp.stimstart(itrial)+setup.postcue-6*setup.ifi); % Thus, setup.postcue after previous flip
            end
          case 'vis'
            error('this option not calibrated for timing')
            Screen('DrawText', win, setup.cuesym{stim.av.cueseq(itrial)}, win_center_x, win_center_y);
            [resp.time_startcue(itrial),~,~,missed]=Screen('Flip',win);
            WaitSecs(setup.cueduration);
            %           Screen('DrawText', win, setup.cuesym(stim.av.cueseq(itrial)), win_center_x-shifttext, win_center_y);
            [resp.time_endcue(itrial),~,~,missed]=Screen('Flip',win);
            warning('take this resp.time_endcue into account for timing?')
            WaitSecs(setup.postcue);
        end
      otherwise
        % question: why is setup.postcue here when no cue is presented? what if delete?
        [tvbl,~,~,missed]=Screen('Flip',win,resp.stimstart(itrial)+setup.postcue-6*setup.ifi);
    end
    switch stim.block
      case {'av' 'audonly'}
        PsychPortAudio('FillBuffer',pamaster,audstim);
    end
    
    switch setup.paradigm
      case 'cued'
        resp.stimstart(itrial)=tvbl+6*setup.ifi;  % an additional 6*setup.ifi will be added on to all time.
      case 'nocue'
        resp.stimstart(itrial)=tvbl+6*setup.ifi;  % an additional 6*setup.ifi will be added on to all time.
    end
    
    % training block for cue value
    if setup.cuetrain && strcmp(setup.paradigm,'cued')
      
      switch setup.cuetype
        case {'vis' 'audcong'}
          switch setup.rlocation
            case 'mac'
              cuequestion='Likely for Flash and Sound to move together? D for yes, J for no';
            case 'meg'
              cuequestion='Likely for Flash and Sound to move together? L3 for yes, R3 for no';
          end
        case 'audmod'
          switch setup.rlocation
            case 'mac'
              cuequestion='Attend to Flash? D for yes, J for no';
            case 'meg'
              cuequestion='Attend to Flash? L3 for yes, R3 for no';
          end
      end
      Screen('DrawText', win, cuequestion, win_center_x-2*shifttext+macshift, win_center_y);
      [tvbl,~,~,missed]=Screen('Flip',win,resp.stimstart(itrial)+setup.precueQ-6*setup.ifi); % setup.precueQ after tvbl above
      poststimtime=GetSecs;
      jz_sendTrigger(setup,lj,63)
      %    if setup.lj
      %         % asked for cue likelihood?
      %         lj.prepareStrobe(63) %prepare a strobed word
      %         lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
      %       end
      RestrictKeysForKbCheck([quit,loc3Key,loc6Key]); % D(3) or J(6)
      %       [resp.rtcueprob(itrial),keycode]=KbWait([],2,poststimtime+setup.maxtime4cueprob);
      %       [~,~,keyCode] = KbCheck;
      switch setup.rlocation
        case 'meg'
          KbQueueWait_jz(max(GetKeyboardIndices),poststimtime+setup.maxtime4cueprob)
        case 'mac'
          KbQueueWait_jz(min(GetKeyboardIndices),poststimtime+setup.maxtime4cueprob)
      end
      allPresses=[];
      while KbEventAvail
        allPresses=[allPresses KbEventGet];
      end
      keycode=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key,loc7Key,loc8Key]),1);
      for event=1:length(allPresses)
        if allPresses(event).Pressed
          keycode(allPresses(event).Keycode)=1;
          resp.rtcueprob(itrial)=allPresses(event).Time;
          break
        end
      end
      if find(keycode)
        resp.cueprobkeycode(itrial)=find(keycode);
        jz_sendTrigger(setup,lj,100-20+resp.cueprobkeycode(itrial))
        %         if setup.lj
        %           % responded flicker, motion, distinct?
        %           lj.prepareStrobe(100-20+resp.cueprobkeycode(itrial)) %prepare a strobed word
        %           lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
        %         end
        % Stopping the loop if user presses 'Escape'.
        if keycode(quit)
          jz_sendTrigger(setup,lj,254)
          %           if setup.lj
          %             % quit
          %             lj.prepareStrobe(254) %prepare a strobed word
          %             lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
          %           end
          break;
        end
        [~,~,keyCode] = KbCheck;
        %         postmotpertime=GetSecs;
      else
        resp.cueprobkeycode(itrial)=0;
      end
      
      [tvbl,~,~,missed]=Screen('Flip',win);
      resp.stimstart(itrial)=tvbl+setup.postcueQ+6*setup.ifi;  % using new tvbl
    end
    
    %     resp.stimstart(itrial)-resp.starttime
    % 'resp.stimstart' is beginning of first stim, even if this means a 'negative' time regarding the asynchrony
    
    
    
    %     trialtime=GetSecs;
    %     while trialtime-resp.stimstart < time_trial
    %       if trialtime > time_vis
    %         firstvispres=1;
    
    switch stim.block
      case {'av' 'audonly'}
        PsychPortAudio('Start',pamaster,[],resp.stimstart(itrial)-0.5*setup.ifi+time_aud);
        resp.timeaudOnset(itrial)=resp.stimstart(itrial)-0.5*setup.ifi+time_aud;
        jz_sendTrigger(setup,lj,ljaudstim)
        % if setup.lj
        %           % 31 for aud moving right; 32 for aud moving left
        %           lj.prepareStrobe(ljaudstim) %prepare a strobed word
        %           lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
        %         end
    end
    
    switch stim.block
      case {'av' 'visonly'}
        switch stim.block
          case 'av'
            vistrial=stim.av.vtrialseq(itrial);
          case 'visonly'
            vistrial=stim.vis.trialseq(itrial);
        end
        % creating first visual dot
        if vistrial==1
          Screen('FillOval',win,setup.white,leftsphere);
        elseif vistrial==2
          Screen('FillOval',win,setup.white,rightsphere);
        elseif vistrial==0
          % blank screen
        else
          error('weird vis trial seq value')
        end
        
        %       while GetSecs<resp.stimstart(itrial)+time_vis-3*setup.ifi
        %       end
        [resp.tvbl_vis1on(itrial),resp.visonset(itrial),~,missed] = Screen('Flip',win,resp.stimstart(itrial)-0.5*setup.ifi+time_vis);
        %       if missed,    flipmiss(itrial)=flipmiss(itrial)+1;      end  % although this doesn't matter because by definition it will have missed the deadline of 0.5*setup.ifi prior to when we actually want it.
        %       resp.stimstart(itrial)+time_vis-resp.tvbl_vis1on(itrial)
        if setup.timingtesting
          jz_sendTrigger(setup,lj,255)
        else
          jz_sendTrigger(setup,lj,40+vistrial)
        end
        %         if setup.lj
        %           % 41 for vis dot first on left (moving right); 42 for vis dot first on right (moving left); % 40 for no visual stim
        %           lj.prepareStrobe(40+vistrial) %prepare a strobed word
        %           lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
        %         end
        
        %       while GetSecs<resp.stimstart(itrial)+time_vis+stim.dur-0.0015
        %       end
        % creating blank screen between stimuli
        if stim.isi(stim.isiseq(itrial))>0
          [resp.tvbl_vis1off(itrial),~,~,missed] = Screen('Flip',win,resp.stimstart(itrial)+time_vis-0.5*setup.ifi+stim.dur(stim.durseq(itrial)));
          %       if missed,    flipmiss(itrial)=flipmiss(itrial)+1;      end
          %       resp.stimstart(itrial)+time_vis+stim.dur(stim.durseq(itrial))-resp.tvbl_vis1off
        end
        
        % creating second visual dot
        if vistrial==1
          Screen('FillOval',win,setup.white,rightsphere);
        elseif vistrial==2
          Screen('FillOval',win,setup.white,leftsphere);
        elseif vistrial==0
          % blank screen
        else
          error('weird vis trial seq value')
        end
        %       while GetSecs<resp.stimstart(itrial)+time_vis+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))-0.0015
        %       end
        [resp.tvbl_vis2on(itrial),~,~,missed] = Screen('Flip',win,resp.stimstart(itrial)+time_vis-0.5*setup.ifi+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial)));
        %       if missed,    flipmiss(itrial)=flipmiss(itrial)+1;      end
        %       resp.stimstart(itrial)+time_vis+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))-tvbl_vis2on
        if vistrial>0
          trigval=42+vistrial;
        else
          trigval=40;
        end
        if setup.timingtesting
          jz_sendTrigger(setup,lj,255)
        else
          jz_sendTrigger(setup,lj,trigval)
        end
        %         if setup.lj
        %           % 43 for vis dot second on right (moving right); 44 for vis dot second on left (moving left); % 40 for no visual stim
        %           if vistrial>0
        %             lj.prepareStrobe(42+vistrial) %prepare a strobed word
        %           else
        %             lj.prepareStrobe(40) %prepare a strobed word
        %           end
        %           lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
        %         end
        %
        if stim.isi(stim.isiseq(itrial))==0
          resp.tvbl_vis1off(itrial)=resp.tvbl_vis2on(itrial);
        end
        
        
        %       while GetSecs<resp.stimstart(itrial)+time_vis+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))-0.0015
        %       end
        % creating blank screen between stimuli
        [resp.tvbl_vis2off(itrial),~,~,missed] = Screen('Flip',win,resp.stimstart(itrial)+time_vis-0.5*setup.ifi+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial)));
        %       if missed,    flipmiss(itrial)=flipmiss(itrial)+1;      end
        %       resp.stimstart(itrial)+time_vis+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))-tvbl_vis2off
    end
    
    
    %     [keyftime,keycodef]=KbWait([],2,resp.stimstart(itrial)+time_vis-1*setup.ifi+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))+setup.pauseb4q1);
    switch setup.rlocation
      case 'meg'
        KbQueueWait_jz(max(GetKeyboardIndices),resp.stimstart(itrial)+time_vis-1*setup.ifi+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))+setup.pauseb4q1)
      case 'mac'
        KbQueueWait_jz(min(GetKeyboardIndices),resp.stimstart(itrial)+time_vis-1*setup.ifi+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))+setup.pauseb4q1)
    end
    allPresses=[];
    while KbEventAvail
      allPresses=[allPresses KbEventGet];
    end
    keycodef=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key,loc7Key,loc8Key]),1);
    for event=1:length(allPresses)
      if allPresses(event).Pressed
        keycodef(allPresses(event).Keycode)=1;
        %         keyftime=allPresses(event).Time;
        break
      end
    end
    if any(keycodef([loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key,loc7Key,loc8Key]))
      Screen('DrawText', win, 'You pressed too fast', win_center_x-shifttext, win_center_y);
      [tvbl_fastpress,~,~,missed]=Screen('Flip',win,resp.stimstart(itrial)+time_vis-0.5*setup.ifi+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))+setup.pauseb4q1);
      jz_sendTrigger(setup,lj,50)
      % if setup.lj
      %         % pressed too fast
      %         lj.prepareStrobe(50) %prepare a strobed word
      %         lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
      %       end
      resp.rtmotper(itrial)=-1;
      [tvbl_fastpress,~,~,missed]=Screen('Flip',win,tvbl_fastpress+[round(1/setup.ifi)-0.5]*setup.ifi);% approximately 1 second
      continue
    end
    
    if setup.askmotper
      [~,~,~,missed]=Screen('Flip',win);
      Screen('DrawText', win, 'flicker, motion, distinct?', win_center_x-shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win,resp.stimstart(itrial)+time_vis+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))+setup.pauseb4q1);
      %       if missed,    flipmiss(itrial)=flipmiss(itrial)+1;      end
      poststimtime=GetSecs;
      jz_sendTrigger(setup,lj,60)
      %       if setup.lj
      %         % asked flicker, motion, distinct?
      %         lj.prepareStrobe(60) %prepare a strobed word
      %         lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
      %       end
      RestrictKeysForKbCheck([quit,loc2Key,loc3Key,loc4Key]);
      %       [resp.rtmotper(itrial),keycode]=KbWait([],2,poststimtime+setup.maxtime4motper);
      %       [~,~,keyCode] = KbCheck;
      switch setup.rlocation
        case 'meg'
          KbQueueWait_jz(max(GetKeyboardIndices),poststimtime+setup.maxtime4motper)
        case 'mac'
          KbQueueWait_jz(min(GetKeyboardIndices),poststimtime+setup.maxtime4motper)
      end
      allPresses=[];
      while KbEventAvail
        allPresses=[allPresses KbEventGet];
      end
      keycode=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key,loc7Key,loc8Key]),1);
      for event=1:length(allPresses)
        if allPresses(event).Pressed
          keycode(allPresses(event).Keycode)=1;
          resp.rtmotper(itrial)=allPresses(event).Time;
          break
        end
      end
      if find(keycode)
        resp.motperkeycode(itrial)=find(keycode);
        jz_sendTrigger(setup,lj,100+resp.motperkeycode(itrial))
        %         if setup.lj
        %           % responded flicker, motion, distinct?
        %           lj.prepareStrobe(100+resp.motperkeycode(itrial)) %prepare a strobed word
        %           lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
        %         end
        % Stopping the loop if user presses 'Escape'.
        if keycode(quit)
          jz_sendTrigger(setup,lj,254)
          % if setup.lj
          %             % quit
          %             lj.prepareStrobe(254) %prepare a strobed word
          %             lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
          %           end
          break;
        end
        [~,~,keyCode] = KbCheck;
        %         postmotpertime=GetSecs;
      else
        resp.motperkeycode(itrial)=0;
      end
    end
    
    if setup.askmotdir
      
      %       resp.stimstart(itrial)+time_vis+stim.dur+stim.isi+stim.dur+setup.pauseb4q1-resp.starttime
      switch stim.block
        case {'av' 'audonly'}
          Screen('DrawText', win, 'direction auditory motion?', win_center_x-shifttext+macshift, win_center_y);
        case 'visonly'
          Screen('DrawText', win, 'direction visual motion?', win_center_x-shifttext+macshift, win_center_y);
      end
      if setup.askmotper
        [~,~,~,missed]=Screen('Flip',win);
      else
        [~,~,~,missed]=Screen('Flip',win,resp.stimstart(itrial)+time_vis+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))+setup.pauseb4q1);
        %       if missed,    flipmiss(itrial)=flipmiss(itrial)+1;      end
      end
      
      poststimtime=GetSecs;
      jz_sendTrigger(setup,lj,61)
      % if setup.lj
      %         % asked direction motion
      %         lj.prepareStrobe(61) %prepare a strobed word
      %         lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
      %       end
      if setup.respcertMD
        RestrictKeysForKbCheck([quit,loc5Key,loc6Key,loc7Key,loc8Key]);
      else
        RestrictKeysForKbCheck([quit,loc6Key,loc7Key]);
      end
      %       [resp.rtmotdir(itrial),keycode]=KbWait([],2,poststimtime+setup.maxtime4motdir);
      %       [~,~,keyCode] = KbCheck;
      switch setup.rlocation
        case 'meg'
          KbQueueWait_jz(max(GetKeyboardIndices),poststimtime+setup.maxtime4motdir)
        case 'mac'
          KbQueueWait_jz(min(GetKeyboardIndices),poststimtime+setup.maxtime4motdir)
      end
      allPresses=[];
      while KbEventAvail
        allPresses=[allPresses KbEventGet];
      end
      keycode=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key,loc7Key,loc8Key]),1);
      for event=1:length(allPresses)
        if allPresses(event).Pressed
          keycode(allPresses(event).Keycode)=1;
          resp.rtmotdir(itrial)=allPresses(event).Time;
          break
        end
      end
      if find(keycode)
        resp.motdirkeycode(itrial)=find(keycode);
        jz_sendTrigger(setup,lj,100+resp.motdirkeycode(itrial))
        % if setup.lj
        %           % responded flicker, motion, distinct?
        %           lj.prepareStrobe(100+resp.motdirkeycode(itrial)) %prepare a strobed word
        %           lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
        %         end
      else
        resp.motdirkeycode(itrial)=0;
      end
      
      % Stopping the loop if user presses 'Escape'.
      if keycode(quit)
        jz_sendTrigger(setup,lj,254)
        % if setup.lj
        %           % quit
        %           lj.prepareStrobe(254) %prepare a strobed word
        %           lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
        %         end
        break;
      end
      [~,~,keyCode] = KbCheck;
      %       postq1time=GetSecs;
    end
    %
    %     while GetSecs<resp.stimstart(itrial)+time_vis+stim.dur+stim.isi+stim.dur+setup.pauseb4q1
    %     end
    
    if setup.askcomsrc
      switch stim.block
        case 'av'
          if stim.av.vtrialseq(itrial)>0
            Screen('DrawText', win, 'visual and auditory same direction?', win_center_x-shifttext+macshift, win_center_y);
            [~,~,~,missed]=Screen('Flip',win);
            postfliptime=GetSecs;
            jz_sendTrigger(setup,lj,62)
            % if setup.lj
            %               % asked common source
            %               lj.prepareStrobe(62) %prepare a strobed word
            %               lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
            %             end
            if setup.respcertCS
              RestrictKeysForKbCheck([quit,loc1Key,loc2Key,loc3Key,loc4Key]);
            else
              RestrictKeysForKbCheck([quit,loc2Key,loc3Key]);
            end
            %             [resp.rtcomsrc(itrial),keycode]=KbWait([],2,postfliptime+setup.maxtime4comsrc);
            switch setup.rlocation
              case 'meg'
                KbQueueWait_jz(max(GetKeyboardIndices),postfliptime+setup.maxtime4comsrc)
              case 'mac'
                KbQueueWait_jz(min(GetKeyboardIndices),postfliptime+setup.maxtime4comsrc)
            end
            allPresses=[];
            while KbEventAvail
              allPresses=[allPresses KbEventGet];
            end
            keycode=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key,loc7Key,loc8Key]),1);
            for event=1:length(allPresses)
              if allPresses(event).Pressed
                keycode(allPresses(event).Keycode)=1;
                resp.rtcomsrc(itrial)=allPresses(event).Time;
                break
              end
            end
            if find(keycode)
              resp.comsrckeycode(itrial)=find(keycode);
              jz_sendTrigger(setup,lj,100+10+resp.comsrckeycode(itrial))
              % if setup.lj
              %                 % responded flicker, motion, distinct?
              %                 lj.prepareStrobe(100+10+resp.comsrckeycode(itrial)) %prepare a strobed word
              %                 lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
              %               end
            else
              resp.comsrckeycode(itrial)=0;
            end
            % Stopping the loop if user presses 'Escape'.
            if keycode(quit)
              jz_sendTrigger(setup,lj,254)
              % if setup.lj
              %                 % quit
              %                 lj.prepareStrobe(254) %prepare a strobed word
              %                 lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
              %               end
              break;
            end
            [~,~,keyCode] = KbCheck;
          end
      end
    end
    
    %   if setup.timingtesting
    %     [~,~,keyCode] = KbCheck;
    %     if keyCode(quit)
    %       break;
    %     end
    %   end
    
    if stim.feedback(2) && (rem(itrial,sum(stim.feedback))==0 || itrial==ntrials)
      Screen('DrawText', win, ['Computing feedback...'], win_center_x-1*shifttext, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      dircor=round(100*length(find(resp.cormotdir(itrial-9:itrial)==resp.motdirkeycode(itrial-9:itrial)))  /length(find(~isnan(resp.motdirkeycode(itrial-9:itrial)))));
      resp.dircor=[resp.dircor dircor];
      WaitSecs(2)
      RestrictKeysForKbCheck([quit,loc6Key]);
      Screen('DrawText', win, ['On the last ' num2str(stim.feedback(2)) ' trials, you were correct in ' num2str(dircor) '% for Direction of Sounds.'], win_center_x-2*shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      jz_sendTrigger(setup,lj,70)
      % if setup.lj
      %         % given feedback
      %         lj.prepareStrobe(70) %prepare a strobed word
      %         lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
      %       end
      WaitSecs(5)
      if itrial~=ntrials
        switch setup.rlocation
          case 'meg'
            Screen('DrawText', win, ['Press/hold R3 to continue.'], win_center_x-1*shifttext+macshift, win_center_y);
          case 'mac'
            Screen('DrawText', win, ['Press/hold J to continue.'], win_center_x-1*shifttext+macshift, win_center_y);
        end
        [~,~,~,missed]=Screen('Flip',win);
        %         KbPressWait;
        KbQueueWait_jz
      end
    end
    
    
    if rem(itrial,30)==0 && itrial~=ntrials
      if setup.save
        save([setup.subid '_' stim.block '_' resp.timestamp],'setup','stim','resp');
      end
      WaitSecs(3)
      Screen('DrawText', win, ['Reminder to fix your eyes at the centre during the task!'], win_center_x-2*shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      WaitSecs(3)
      if setup.el.online
        if strcmp(setup.el.fb,'block')
          DrawFormattedText(setup.disp.win, ['In all the trials, you have moved your eyes too much in ' num2str(saccCount) ' trials.'], 'center', 'center', setup.white);
        end
      end
      RestrictKeysForKbCheck([quit,loc7Key]);
      switch setup.rlocation
        case 'meg'
          Screen('DrawText', win, ['Rest! Done with ' num2str(itrial) ' trials out of ' num2str(ntrials) '. Press/hold ' 'R4' ' to continue.'], win_center_x-2*shifttext+macshift, win_center_y);
        case 'mac'
          Screen('DrawText', win, ['Rest! Done with ' num2str(itrial) ' trials out of ' num2str(ntrials) '. Press/hold ' upper(KbName(loc7Key)) ' to continue.'], win_center_x-2*shifttext+macshift, win_center_y);
      end
      [~,~,~,missed]=Screen('Flip',win);
      jz_sendTrigger(setup,lj,71)
      % if setup.lj
      %         % Rest break
      %         lj.prepareStrobe(71) %prepare a strobed word
      %         lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
      %       end
      %       KbPressWait;
      KbQueueWait_jz
    end
    
    if setup.el.online
      Eyelink('Message', 'END TRIAL');
      %         [saccadeOccured] = dfi_checkForSaccades(setup);
      %         if saccadeOccured
      %             saccCount = saccCount + 1;
      %             % Feedback about central fixation after a trial
      %             if strcmp(setup.el.fb, 'trial')
      %                 Screen(setup.disp.win, 'Flip');
      %                 DrawFormattedText(setup.disp.win, 'Fixate on the center', 'center', 'center', setup.white);
      %                 Screen(setup.disp.win, 'Flip');
      %                 WaitSecs(1.5);
      %                 Screen(setup.disp.win, 'DrawTexture', s.stim.fix.texture, [], s.stim.fix.rect);
      %                 Screen(setup.disp.win, 'Flip');
      %             end
      %         end
    end
    
    
  end % itrial
catch ME
  disp(ME.message)
end

Screen('DrawText', win, ['Done with this block! Thank you!'], win_center_x-1*shifttext+macshift, win_center_y);
[~,~,~,missed]=Screen('Flip',win);
jz_sendTrigger(setup,lj,72)
% if setup.lj
%   % End of block
%   lj.prepareStrobe(72) %prepare a strobed word
%   lj.strobeWord %send the strobed word, which is 11bit max length on EIO and CIO via the DB15
% end
WaitSecs(3)

% resp.flipmiss=flipmiss;

% catch ME
%   disp(ME.message)
% end


%%  Closing out everything nicely

% if setup.el.enable==1;
%   % Eyelink, stop listening!
%   if Eyelink('IsConnected')
%     WaitSecs(0.015); % capture last events
%     Eyelink('StopRecording');
%   elseif setup.el.online
%     warning('Lost EyeLink connection!')
%   end
% end


% Close Eyetracker
if setup.el.enable
  filestatus=Eyelink_stop_jz(setup.edfFile);
  % Next try/catch from Steffen
  if filestatus==2
    try
      fprintf('Trying to convert to ASCII...')
      system(sprintf('%smfiles/edf2asc %s%s %s', setup.rdir, setup.bdir, setup.edfFile, setup.edfFlag))
%       ascFile = sprintf('subj%s_%s.asc',setup.subid, [time(1:2),'h',time(4:5),'m']);
%       movefile(sprintf('subj%s.asc',setup.subid),ascFile)
%       fprintf('ASCII file "%s" saved in "%s"', ascFile, setup.edir)
%       movefile(s.edfFile, sprintf('subj%s_%s.edf',setup.subid, [time(1:2),'h',time(4:5),'m']))
    catch
      fprintf('ASCII conversion of edf file unsuccessful\n')
    end
  end
end



Screen('CloseAll');
ShowCursor
WaitSecs(1); % to avoid displaying last key press in the command window
try
  KbQueueStop;
end
KbQueueRelease;
ListenChar(0);
try
  PsychPortAudio('Close');
catch
end
Priority(0);
