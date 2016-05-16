function setup = setup_screen(setup)

% Screen native resolutions and refresh rates, monitor width and distance params
switch setup.name
    case 'office'
        setup.res = [1920 1080];
        setup.refresh = 60;
        setup.mon.dist = 50; % roughly
        setup.mon.width = 48; % IIYAMA
    case 'lab'
        setup.res = [1920 1080];
        setup.refresh = 60;
        setup.mon.dist = 50; % 45
        setup.mon.width = 48; % IIYAMA
    case {'mac' 'NopBook03.local'  'NopBook2.local' 'nopbook2.local' 'nopbook03.local'}
      switch setup.vlocation
        case 'mac'
          setup.res = [1440 900];
          setup.refresh = [];
          setup.mon.dist = 50; % roughly
          setup.mon.width = 33; % roughly
        case '313a' % assuming using external monitor
          setup.res = [1920 1080];
          setup.refresh = 60;
          setup.mon.dist = 48; % roughly
          setup.mon.width = 48; % roughly
        case 'meg'
%           setup.res = [1600 1200];
          setup.res = [1024 768];  % worked with eyelink on 13/4/16 (sort of)
          setup.res = [1280 1024]; % worked with stimulus presentation and eyelink 13/4/16
          setup.refresh = 60;
          setup.mon.dist = 54; % confirmed
          setup.mon.width = 40; % confirmed
        case 'buicmri'
          error('set me up for buicmri')
        otherwise
          error('where are you?')
      end
    case 'mock'
        setup.res = [1400 1050]; % 1400 x 1050 native & default DVI resolution (JVC DLA-SX21), default BNC resolution is 800 x 600
        setup.refresh = [];
        setup.mon.dist = 62; % head to mirror (12) + mirror to projector (50) measured 08.05.14
        setup.mon.width = 50; % measured 08.05.14 (17.11.14)
    case 'scanner'
        setup.res = [1152 870]; % default BNC resolution (JVC DLA-SX21)
        setup.refresh = [];
        setup.mon.dist = 68; % head to mirror (12) + mirror to projector (56) measured by Alex and used by other people
        setup.mon.width = 59; %!!!!!54 56!!!! 09.05.2014 -- measured 19.12.12 (calculation by Alex was within 0.5 cm) 
  case 'PSYCHL-132432'  % second monitor
        setup.res = [1280 1024];
        setup.refresh = 60;
        setup.mon.dist = 50; % roughly
        setup.mon.width = 30; % Samsung913N
    case 'COLLES-140591'  
        setup.res = [2560 1600]; % Dell 3007WFP 30inch, ratio 16:10
        setup.refresh = 60;
        setup.mon.dist = 30; % room 3.16, roughly
        setup.mon.width = 64.6; % Dell 3007WFP 30inch, ratio 16:10, 25,44 inches wide
  case 'PPPMEGSTIM'
    switch setup.vlocation
      case 'meg'
          setup.res = [1600 1200];
          setup.refresh = 60;
          setup.mon.dist = 55; % confirmed
          setup.mon.width = 42; % confirmed
      otherwise
        error('no other vlocation than meg makes sense here')
    end
  otherwise
    error(['not yet coded for this computer ' setup.name])
end

% Field of view (in degree) and number of pixels per degree
setup.maxfov = atand(setup.mon.width / 2 / setup.mon.dist) * 2;
setup.ppd = setup.res(1) / setup.maxfov;

setup.screenres = setup.res(1)/(setup.mon.width*10);  % pixels/mm

% Screen adjustment in the scanner
if strcmp(setup.name, 'scanner')
%     setup.rect = [125 294 1027 506]; % adjusted by Tao 25.04.14. BNC default
    setup.rect = [125 314 1027 526]; % adjusted by Tao 28.04.14. BNC default
%     setup.rect = [60 416 1220 6848];
%     setup.rect = [204 204 1076 650]; % ratio adjusted 19.12.13 Mate (width 36.8 cm)
%     other margin adjusted measurements: [170 285 1095 694] 09.12.13 Mate, [225 190 1055 659] 19.12.13 Mate (width 35 cm)
    setup.maxfov = (setup.rect(3)-setup.rect(1)) / setup.ppd;
elseif strcmp(setup.name, 'mock')
    %     setup.rect = [105 328 695 472]; % adjusted by Mate 16.04.14 default resolution
    %     setup.rect = [120 458 1280 712]; % adjusted by Tao 17.04.14. DVI
    setup.rect = [91 447 1309 703]; % adjusted 09.05.14. DVI (38.21 degree)
    %     setup.rect = [110 516 1165 753]; % adjusted by Mate 14.01.14
    %     setup.rect = [230 323 1050 701]; % ratio adjusted 20.12.13 Talha (center more on the right!!)
    setup.maxfov = (setup.rect(3)-setup.rect(1)) / setup.ppd;
end