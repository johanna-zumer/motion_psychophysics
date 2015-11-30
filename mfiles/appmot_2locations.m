function [resp,stim,setup] = appmot_2locations(setup,stim)


%% screen

if setup.debug
   PsychDebugWindowConfiguration % use transparent screen
  Screen('Preference', 'SkipSyncTests', 1); % skip screen synchronization, otherwise error due to PTB debug mode
  setup.old.verb = Screen('Preference', 'Verbosity', 1); % print only errors
else
  Screen('Preference', 'SkipSyncTests', 0); % synchronize screen
  setup.old.verb = Screen('Preference', 'Verbosity'); % print error+warning+status messages
  setup.old.visdeb = Screen('Preference', 'VisualDebugLevel', 3); % turn off PsychToolbox Welcome Sign
end

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
    end
end

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

try
  [fixWidth,lineWidth] = deal(round(posdeg2pix(1.6,setup.mon.dist,setup.screenres)),...
    round(posdeg2pix(0.1,setup.mon.dist,S.screenres)));
catch
   warning('ask Mate for posdeg2pix')
  fixWidth=0.5;
  lineWidth=0.1;
end

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
  case {'NopBook03.local' 'NopBook2.local'}
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
    elseif strcmpi(setup.name,'NopBook03.local') || strcmpi(setup.name,'NopBook2.local')      
      switch setup.alocation
        case 'meg'
          latBias = -0.009;
        otherwise
          latBias = -0.016;
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
        case 'whitenoise'
          audstim=whitenoise;
        case 'noisytone'
          audstim=noisytone;
        case 'brownnoise'
          try
            brownnoise=load([setup.rdir(1:end-21) 'sounds_wavfiles\brownnoise.mat']);
          catch
            brownnoise=load('/Users/zumerj/Documents/MATLAB/sounds_wavfiles/brownnoise.mat');
            addpath(genpath('/Applications/MATLAB_R2011b.app/toolbox/signal/signal/'))
          end          
          brownresamp=resample(brownnoise.y,stim.audio.freq,brownnoise.Fs);
          audstim=brownresamp(1:round(stim.dur(dur)*stim.audio.freq));
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
            case {'NopBook03.local' 'NopBook2.local'}
              mitdir='/Users/zumerj/Documents/MATLAB/motion_psychophysics/mit_hrtf/elev0/';
            case 'PPPMEGSTIM'
              mitdir='C:\Users\MEGuser\Documents\Johanna\MultSens_ISMINO\motion_psychophysics\mit_hrtf\elev0\';
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
          elseif any(max(stim.loc)==1:10)
%             interpolate_hrir('mit', stim.audio.freq, [-10:1:10], 0, 1); % called this way to create file loaded below
            load([mitdir(1:end-6) 'normal_hrir_interpolated_el0.mat']);
            if ~all(azimuth_int==[-10:10])
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



%% Begin experiment

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

resp.starttime=GetSecs;
resp.dircor=[];

switch stim.block
  case 'av'
    switch setup.paradigm
      case 'cued'
        [resp.rtmotper,resp.rtmotdir,resp.rtcomsrc,resp.motperkeycode,resp.motdirkeycode,resp.comsrckeycode]=deal(nan(1,stim.mtot));
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

% to exit the program
quit   = KbName('ESCAPE');
% defining keys for input
loc1Key = KbName('j');    % corresponding to 'flicker' or 'same'
loc2Key = KbName('k');    % corresponding to 'motion'
loc3Key = KbName('l');    % corresponding to 'distinct' or 'different'
loc4Key = KbName('s');    % corresponding to motion to the left
loc5Key = KbName('f');    % corresponding to motion to the right
loc6Key = KbName('d');    % corresponding to centretest

% test headphones
if setup.includeintro
  switch stim.block
    case {'av' 'audonly'}
      keycode=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key]),1);
      while ~keycode(loc4Key)
        Screen('DrawText', win,['Headphone test: 2 sounds on the Left (S) or Centre (D) or Right (F)?'], win_center_x-1*shifttext+macshift, win_center_y);
        [~,~,~,missed]=Screen('Flip',win);
        WaitSecs(0.5)
        PsychPortAudio('FillBuffer',pamaster,stim.audio.testleft');
        PsychPortAudio('Start',pamaster);
        RestrictKeysForKbCheck([quit,loc4Key,loc5Key,loc6Key]);
        [~,keycode]=KbWait([],2);
        if keycode(quit)
          break;
        end
        WaitSecs(0.5)
      end
      keycode=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key]),1);
      while ~keycode(loc5Key)
        Screen('DrawText', win,['Headphone test: 2 sounds on the Left (S) or Centre (D) or Right (F)?'], win_center_x-1*shifttext+macshift, win_center_y);
        [~,~,~,missed]=Screen('Flip',win);
        WaitSecs(0.5)
        PsychPortAudio('FillBuffer',pamaster,stim.audio.testright');
        PsychPortAudio('Start',pamaster);
        RestrictKeysForKbCheck([quit,loc4Key,loc5Key,loc6Key]);
        [~,keycode]=KbWait([],2);
        if keycode(quit)
          break;
        end
        WaitSecs(0.5)
      end
      keycode=zeros(max([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key]),1);
      while ~keycode(loc6Key)
        Screen('DrawText', win,['Headphone test: 2 sounds on the Left (S) or Centre (D) or Right (F)?'], win_center_x-1*shifttext+macshift, win_center_y);
        [~,~,~,missed]=Screen('Flip',win);
        WaitSecs(0.5)
        PsychPortAudio('FillBuffer',pamaster,stim.audio.testcentre');
        PsychPortAudio('Start',pamaster);
        RestrictKeysForKbCheck([quit,loc4Key,loc5Key,loc6Key]);
        [~,keycode]=KbWait([],2);
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
          
          Screen('DrawText', win,['Three examples: SOUND moving to the LEFT'], win_center_x-shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          WaitSecs(3)
          for tt=1:3
            [tvbl,~,~,missed]=Screen('Flip',win);
            PsychPortAudio('FillBuffer',pamaster,[stim.audio.movleft{max(stim.durseq),max(stim.isiseq)}]');
            PsychPortAudio('Start',pamaster,[],tvbl+11.5*setup.ifi);
            Screen('FillOval',win,setup.white,rightsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq)));
            Screen('FillOval',win,setup.white,leftsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+2*stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            WaitSecs(1)
          end
          WaitSecs(1)
          
          Screen('DrawText', win,['Three examples: SOUND moving to the LEFT'], win_center_x-shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          WaitSecs(3)
          for tt=1:3
            [tvbl,~,~,missed]=Screen('Flip',win);
            PsychPortAudio('FillBuffer',pamaster,[stim.audio.movleft{max(stim.durseq),max(stim.isiseq)}]');
            PsychPortAudio('Start',pamaster,[],tvbl+11.5*setup.ifi);
            Screen('FillOval',win,setup.white,leftsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq)));
            Screen('FillOval',win,setup.white,rightsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+2*stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            WaitSecs(1)
          end
          WaitSecs(1)
          
          Screen('DrawText', win,['Three examples: SOUND moving to the RIGHT'], win_center_x-shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          WaitSecs(3)
          for tt=1:3
            [tvbl,~,~,missed]=Screen('Flip',win);
            PsychPortAudio('FillBuffer',pamaster,[stim.audio.movright{max(stim.durseq),max(stim.isiseq)}]');
            PsychPortAudio('Start',pamaster,[],tvbl+11.5*setup.ifi);
            Screen('FillOval',win,setup.white,leftsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq)));
            Screen('FillOval',win,setup.white,rightsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+2*stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            WaitSecs(1)
          end
          WaitSecs(1)
          
          Screen('DrawText', win,['Three examples: SOUND moving to the RIGHT'], win_center_x-shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          WaitSecs(3)
          for tt=1:3
            [tvbl,~,~,missed]=Screen('Flip',win);
            PsychPortAudio('FillBuffer',pamaster,[stim.audio.movright{max(stim.durseq),max(stim.isiseq)}]');
            PsychPortAudio('Start',pamaster,[],tvbl+11.5*setup.ifi);
            Screen('FillOval',win,setup.white,rightsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq)));
            Screen('FillOval',win,setup.white,leftsphere);
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            [~,~,~,missed] = Screen('Flip',win,tvbl+11.5*setup.ifi+2*stim.dur(max(stim.durseq))+stim.isi(max(stim.isiseq)));
            WaitSecs(1)
          end
          WaitSecs(1)
          
      end
      
  end
end


% Reminding of key responses
flipcnt=0;
fliptimecnt=0;
resp.motperkey=[loc1Key loc2Key loc3Key];
resp.comsrckey=[loc1Key loc3Key];
RestrictKeysForKbCheck([quit,loc1Key,loc2Key,loc3Key,loc4Key,loc5Key,loc6Key]);
switch stim.block
  case 'av'
    resp.cormotdir(stim.av.atrialseq==1)=loc5Key; % motion starting on left moving to right
    resp.cormotdir(stim.av.atrialseq==2)=loc4Key; % motion starting on right moving to left
    switch setup.paradigm
      case 'cued'
        ntrials=stim.mtot;
        if setup.askmotdir
          Screen('DrawText', win,['Reminder: Sound moving to left ' upper(KbName(loc4Key)) ' or right ' upper(KbName(loc5Key)) ' (Press to continue'], win_center_x-2*shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          KbPressWait;
        end
        for cc=1:length(stim.cueprob)
          switch setup.cuetype
            case 'vis'
              Screen('DrawText', win,['This cue ' setup.cuesym{cc} ' means ' num2str(round(100*stim.cueprob(cc))) ' probability AV congruent' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
            case 'aud'
              Screen('DrawText', win,['This sound means ' num2str(round(100*stim.cueprob(cc))) ' probability AV congruent' ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
              PsychPortAudio('FillBuffer',pamaster,cuetones(:,:,cc)');
              PsychPortAudio('Start',pamaster);
          end
          [~,~,~,missed]=Screen('Flip',win);
          KbPressWait;
        end
        if setup.askcomsrc
          Screen('DrawText', win, ['Auditory and visual object same ' upper(KbName(loc1Key)) ' or different ' upper(KbName(loc3Key)) ' (Press to continue)'] , win_center_x-2*shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          KbPressWait;
          resp.corcong(stim.av.congseq==1)=loc1Key; % audvis congruent
          resp.corcong(stim.av.congseq==0)=loc3Key; % audvis incongruent
        end
      case 'nocue'
        ntrials=stim.mreps;
        flipmiss=zeros(1,ntrials+1);
        if setup.askmotper
          Screen('DrawText', win, ['Reminder: Flicker ' upper(KbName(resp.motperkey(1))) ', Motion ' upper(KbName(resp.motperkey(2))) ', Distinct ' upper(KbName(resp.motperkey(3))) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          KbPressWait;
        end
        if setup.askmotdir
          Screen('DrawText', win,['Reminder: Sound moving to left ' upper(KbName(loc4Key)) ' or right ' upper(KbName(loc5Key)) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          KbPressWait;
        end
        if setup.askcomsrc
          Screen('DrawText', win, ['Reminder: Sound and flash same ' upper(KbName(loc1Key)) ' or different ' upper(KbName(loc3Key)) ' (Press to continue)'] , win_center_x-2*shifttext+macshift, win_center_y);
          [~,~,~,missed]=Screen('Flip',win);
          KbPressWait;
          resp.corcong(stim.av.congseq==1)=loc1Key; % audvis congruent
          resp.corcong(stim.av.congseq==0)=loc3Key; % audvis incongruent
        end
    end
  case 'audonly'
    ntrials=stim.audio.areps;
    flipmiss=zeros(1,ntrials+1);
    if setup.askmotper
      Screen('DrawText', win, ['Reminder: Flicker ' upper(KbName(resp.motperkey(1))) ', Motion ' upper(KbName(resp.motperkey(2))) ', Distinct ' upper(KbName(resp.motperkey(3))) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      KbPressWait;
    end
    if setup.askmotdir
      Screen('DrawText', win,['Reminder: Sound moving to left ' upper(KbName(loc4Key)) ' or right ' upper(KbName(loc5Key)) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      KbPressWait;
    end
    resp.cormotdir(stim.audio.trialseq==1)=loc5Key; % motion starting on left moving to right
    resp.cormotdir(stim.audio.trialseq==2)=loc4Key; % motion starting on right moving to left
  case 'visonly'
    ntrials=stim.vis.vreps;
    flipmiss=zeros(1,ntrials+1);
    if setup.askmotper
      Screen('DrawText', win, ['Reminder: Flicker ' upper(KbName(resp.motperkey(1))) ', Motion ' upper(KbName(resp.motperkey(2))) ', Distinct ' upper(KbName(resp.motperkey(3))) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      KbPressWait;
    end
    if setup.askmotdir
      Screen('DrawText', win,['Reminder: Flash moving to left ' upper(KbName(loc4Key)) ' or right ' upper(KbName(loc5Key)) ' (Press to continue)'], win_center_x-2*shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      KbPressWait;
    end
    resp.cormotdir(stim.vis.trialseq==1)=loc5Key; % motion starting on left moving to right
    resp.cormotdir(stim.vis.trialseq==2)=loc4Key; % motion starting on right moving to left
end



% loop through trials
try
  resp.stimstart=nan(1,ntrials);
  for itrial=1:ntrials
    
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
            elseif stim.av.atrialseq(itrial)==1 % 1 for start on left, move to right
              audstim=stim.audio.movright{stim.durseq(itrial),stim.isiseq(itrial)}';
            end
          case 'audonly'
            if stim.audio.trialseq(itrial)==2 % 2 for start on right, move to left
              audstim=stim.audio.movleft{stim.durseq(itrial),stim.isiseq(itrial)}';
            elseif stim.audio.trialseq(itrial)==1 % 1 for start on left, move to right
              audstim=stim.audio.movright{stim.durseq(itrial),stim.isiseq(itrial)}';
            end
        end
    end
    
    % Check input
    [~,~,keyCode] = KbCheck;
    
    switch setup.paradigm
      case 'cued'
        switch setup.cuetype
          case 'aud'
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
          case 'aud'
            PsychPortAudio('Start',pamaster,[],resp.stimstart(itrial)-0.5*setup.ifi);
            resp.time_startcue(itrial)=resp.stimstart(itrial)-0.5*setup.ifi;
            %           WaitSecs(setup.cueduration);
            %           resp.time_endcue(itrial)=GetSecs;
            [tvbl,~,~,missed]=Screen('Flip',win,resp.stimstart(itrial)+setup.postcue-6*setup.ifi);
          case 'vis'
            error('this option not calibrated for timing')
            Screen('DrawText', win, setup.cuesym{stim.av.cueseq(itrial)}, win_center_x, win_center_y);
            [resp.time_startcue(itrial),~,~,missed]=Screen('Flip',win);
            WaitSecs(setup.cueduration);
            %           Screen('DrawText', win, setup.cuesym(stim.av.cueseq(itrial)), win_center_x-shifttext, win_center_y);
            [resp.time_endcue(itrial),~,~,missed]=Screen('Flip',win);
            warning('take this resp.time_enduce into account for timing?')
            WaitSecs(setup.postcue);
        end
      otherwise
        [tvbl,~,~,missed]=Screen('Flip',win,resp.stimstart(itrial)+setup.postcue-6*setup.ifi);
    end
    switch stim.block
      case {'av' 'audonly'}
        PsychPortAudio('FillBuffer',pamaster,audstim);
    end
    switch setup.paradigm
      case 'cued'
        resp.stimstart(itrial)=tvbl+6*setup.ifi;  % an additional 3*setup.ifi will be added on to all time.
      case 'nocue'
        resp.stimstart(itrial)=tvbl+6*setup.ifi;  % an additional 3*setup.ifi will be added on to all time.
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
        
        %       while GetSecs<resp.stimstart(itrial)+time_vis+stim.dur-0.0015
        %       end
        % creating blank screen between stimuli
        [resp.tvbl_vis1off(itrial),~,~,missed] = Screen('Flip',win,resp.stimstart(itrial)+time_vis-0.5*setup.ifi+stim.dur(stim.durseq(itrial)));
        %       if missed,    flipmiss(itrial)=flipmiss(itrial)+1;      end
        %       resp.stimstart(itrial)+time_vis+stim.dur(stim.durseq(itrial))-resp.tvbl_vis1off
        
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
        
        %       while GetSecs<resp.stimstart(itrial)+time_vis+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))-0.0015
        %       end
        % creating blank screen between stimuli
        [resp.tvbl_vis2off(itrial),~,~,missed] = Screen('Flip',win,resp.stimstart(itrial)+time_vis-0.5*setup.ifi+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial)));
        %       if missed,    flipmiss(itrial)=flipmiss(itrial)+1;      end
        %       resp.stimstart(itrial)+time_vis+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))-tvbl_vis2off
    end
    
    
    [keyftime,keycodef]=KbWait([],2,resp.stimstart(itrial)+time_vis-1*setup.ifi+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))+setup.pauseb4q1);
    if any(keycodef([loc1Key,loc2Key,loc3Key,loc4Key,loc5Key]))
      Screen('DrawText', win, 'you pressed too fast', win_center_x-shifttext, win_center_y);
      [tvbl_fastpress,~,~,missed]=Screen('Flip',win,resp.stimstart(itrial)+time_vis-0.5*setup.ifi+stim.dur(stim.durseq(itrial))+stim.isi(stim.isiseq(itrial))+stim.dur(stim.durseq(itrial))+setup.pauseb4q1);
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
      RestrictKeysForKbCheck([quit,loc1Key,loc2Key,loc3Key]);
      [resp.rtmotper(itrial),keycode]=KbWait([],2,poststimtime+setup.maxtime4motper);
      [~,~,keyCode] = KbCheck;
      if find(keycode)
        resp.motperkeycode(itrial)=find(keycode);
        % Stopping the loop if user presses 'Escape'.
        if keycode(quit)
          break;
        end
        [~,~,keyCode] = KbCheck;
        %         postmotpertime=GetSecs;
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
      RestrictKeysForKbCheck([quit,loc4Key,loc5Key]);
      [resp.rtmotdir(itrial),keycode]=KbWait([],2,poststimtime+setup.maxtime4motdir);
      [~,~,keyCode] = KbCheck;
      if find(keycode)
        resp.motdirkeycode(itrial)=find(keycode);
      end
      
      % Stopping the loop if user presses 'Escape'.
      if keycode(quit)
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
            Screen('DrawText', win, 'visual and auditory same object?', win_center_x-shifttext+macshift, win_center_y);
            [~,~,~,missed]=Screen('Flip',win);
            postfliptime=GetSecs;
            RestrictKeysForKbCheck([quit,loc1Key,loc3Key]);
            [resp.rtcomsrc(itrial),keycode]=KbWait([],2,postfliptime+setup.maxtime4comsrc);
            if find(keycode)
              resp.comsrckeycode(itrial)=find(keycode);
            end
            % Stopping the loop if user presses 'Escape'.
            if keycode(quit)
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
      RestrictKeysForKbCheck([quit,loc1Key]);
      Screen('DrawText', win, ['On the last ' num2str(stim.feedback(2)) ' trials, you were correct in ' num2str(dircor) '% for Direction of Sounds.'], win_center_x-2*shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      WaitSecs(5)
      if itrial~=ntrials
        Screen('DrawText', win, ['Press/hold J to continue.'], win_center_x-1*shifttext+macshift, win_center_y);
        [~,~,~,missed]=Screen('Flip',win);
        KbPressWait;
      end
    end
    
    
    if rem(itrial,30)==0
      if setup.save
        save([setup.subid '_' stim.block '_' resp.timestamp],'setup','stim','resp');
      end
      WaitSecs(3)
      RestrictKeysForKbCheck([quit,loc3Key]);
      Screen('DrawText', win, ['Rest! Done with ' num2str(itrial) ' trials out of ' num2str(ntrials) '. Press/hold L to continue.'], win_center_x-2*shifttext+macshift, win_center_y);
      [~,~,~,missed]=Screen('Flip',win);
      KbPressWait;
    end
    
    
    
  end % itrial
catch
end

Screen('DrawText', win, ['Done with this block! Thank you!'], win_center_x-1*shifttext+macshift, win_center_y);
[~,~,~,missed]=Screen('Flip',win);
WaitSecs(3)

% resp.flipmiss=flipmiss;

% catch ME
%   disp(ME.message)
% end


%%  Closing out everything nicely



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
