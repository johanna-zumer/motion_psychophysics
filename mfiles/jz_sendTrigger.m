function jz_sendTrigger(setup,lj,trigval)
% jz_sendTrigger(setup,trival)
%
% uses a LabJack device to send triggers to an external hardware, like an
% EEG setup. Needs labjack object (s.lj) and the trigger value to be send (trig). 

    % Send trigger now. 
    if setup.lj
      lj.prepareStrobe(trigval)
      lj.strobeWord
    end
    % Send eyelink trigger
    if setup.el.online
        Eyelink('Message', ['TRIGGER ', num2str(trigval)]);
    end


end

