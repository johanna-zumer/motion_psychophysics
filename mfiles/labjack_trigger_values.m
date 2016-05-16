% testing labjack trigger values

if ~exist('lj')
  lj = labJack('deviceID', 3, 'verbose', true); %open a U3 with verbose logging on
end
if strfind(lj.version,'FAILED')
  error('opening labjack failed');
end

for ii=[1 2 4 8  16 32 64 128]
    lj.prepareStrobe(ii);
    lj.strobeWord;
%     pause(1)
    trg(ii)=input('what is trigger  ');
end
