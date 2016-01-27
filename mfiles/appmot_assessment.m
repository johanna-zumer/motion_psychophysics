% script to assess 'resp' from call_appmot_2locations

trialuse=ones(1,length(resp.stimstart));
switch setup.paradigm
  case 'cued'
    if length(resp.time_startcue)<length(resp.stimstart)
      trialuse(1,length(resp.time_startcue):end)=0;
    end
  case 'nocue'
    if length(resp.timeaudOnset)<length(resp.stimstart)
      trialuse(1,length(resp.timeaudOnset):end)=0;
    end
end


switch stim.block
  case 'av'
    
    if ~isfield(resp,'comsrckey')
      resp.comsrckey=[resp.motperkey(1) resp.motperkey(3)];
    end
    
    disp('congruent, incongruent, audalone (percent correct of motion direction)')
    [length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq))  length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq))]
    %     disp('percent AV congruency correct')
    %     length(find(resp.corcong==resp.comsrckeycode))/length(trialuse)
    if length(unique(stim.av.asynchseq))>1
      disp('congruent, incongruent, audalone (percent correct of motion direction), per each asynchrony')
      for aa=1:length(unique(stim.av.asynchseq))
        [length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.av.asynchseq==aa))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.av.asynchseq==aa))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.av.asynchseq==aa))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.av.asynchseq==aa))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.av.asynchseq==aa))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.av.asynchseq==aa))]
      end
    end
    
    if length(unique(stim.isiseq))>1 % we varied ISI
      disp('congruent, incongruent, audalone (percent correct of motion direction), per each ISI')
      for aa=1:length(unique(stim.isiseq))
        [length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa))]
      end
    end
    
    if length(unique(stim.durseq))>1 % we varied Duration
      disp('congruent, incongruent, audalone (percent correct of motion direction), per each Duration')
      for aa=1:length(unique(stim.durseq))
        [length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.durseq==aa))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.durseq==aa))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.durseq==aa))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.durseq==aa))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.durseq==aa))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.durseq==aa))]
      end
    end
    
    %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
    for aa=1:length(unique(stim.isiseq))
      for bb=1:length(unique(stim.durseq))
        try
          percorout(aa,:,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
          percoroutnum(aa,:,bb)=[length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
          %           percorout(:,aa,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
        catch
          error('reminder to clear before reload')
        end
      end
    end
    disp('congruent, incongruent, audalone (percent correct of motion direction) (columns), per each ISI (rows) and Duration (3rd dimension)')
    [percorout -1 percoroutnum]
    %     end
    
    if ~isfield(setup,'av')
      setup.av.askfmdcs=1;
    end
    
    if setup.av.askfmdcs==1 || setup.av.askfmdcs==2
      disp('display percent common source percept as function of congruency')
%       disp('congruent, incongruent, audalone (% common source correct)')
      disp('congruent, incongruent (% common source correct)')
%       comsrc=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq))   length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & stim.av.vtrialseq))  /length(find(trialuse& ~stim.av.congseq & stim.av.vtrialseq))   length(find(isnan(resp.comsrckeycode) & isnan(resp.corcong) & ~stim.av.congseq  & ~stim.av.vtrialseq))  /length(find(trialuse& ~stim.av.congseq & ~stim.av.vtrialseq)) ];
      comsrc=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq))   length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & stim.av.vtrialseq))  /length(find(trialuse& ~stim.av.congseq & stim.av.vtrialseq))    ];
      comsrc

      for aa=1:length(unique(stim.isiseq))
        for bb=1:length(unique(stim.durseq))
%           comsrcisidur(aa,:,bb)=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse& ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   ];
%           comsrcisidur_numer(aa,:,bb)=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   ];
%           comsrcisidur_denom(aa,:,bb)=[length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))         length(find(trialuse& ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   ];
          comsrcisidur(aa,:,bb)=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse& ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   ];
          comsrcisidur_numer(aa,:,bb)=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   ];
          comsrcisidur_denom(aa,:,bb)=[length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))         length(find(trialuse& ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   ];
        end
      end
      disp('congruent, incongruent (% common source correct)(columns), per each ISI (rows) and Duration (3rd dimension)')
      comsrcisidur
      

      for aa=1:length(unique(stim.isiseq))
        for bb=1:length(unique(stim.durseq))
          comsrcMDisidur(aa,:,bb)=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse& ~stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))      length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse& ~stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
          comsrcMDisidur_numer(aa,:,bb)=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))       length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb)) ];
          comsrcMDisidur_denom(aa,:,bb)=[length(find(trialuse & stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(trialuse & stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(trialuse& ~stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))      length(find(trialuse& ~stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
        end
      end
      disp('cong-MDcor, cong-MDincor, incong-MDcor, incong-MDincor (% common source correct)(columns), per each ISI (rows) and Duration (3rd dimension)')
      comsrcMDisidur

      
      %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
      for aa=1:length(unique(stim.isiseq))
        for bb=1:length(unique(stim.durseq))
          try
            percorcomsrc(aa,:,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.comsrckey(1) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & resp.comsrckeycode==resp.comsrckey(1) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.comsrckey(2) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & resp.comsrckeycode==resp.comsrckey(2) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb)) ];
            percorcomsrc_num(aa,:,bb)=[length(find(trialuse & resp.comsrckeycode==resp.comsrckey(1) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  length(find(trialuse & resp.comsrckeycode==resp.comsrckey(2) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb)) ];
            %           percorout(:,aa,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
          catch
            error('reminder to clear before reload')
          end
        end
      end
      disp('ComSrc, Not ComSrc (percent correct of motion direction) (columns), per each ISI (rows) and Duration (3rd dimension)')
      [percorcomsrc -1 percorcomsrc_num]
      %     end
      
      %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
      for aa=1:length(unique(stim.isiseq))
        for bb=1:length(unique(stim.durseq))
          try
            percorcorcomsrc(aa,:,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & resp.comsrckeycode==resp.corcong & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~(resp.comsrckeycode==resp.corcong) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb)) ];
            percorcorcomsrc_num(aa,:,bb)=[length(find(trialuse & resp.comsrckeycode==resp.corcong & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(trialuse & ~(resp.comsrckeycode==resp.corcong) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb)) ];
            %           percorout(:,aa,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
          catch
            error('reminder to clear before reload')
          end
        end
      end
      disp('ComSrc-Cong, NotComSrc-Incong (percent correct of motion direction) (columns), per each ISI (rows) and Duration (3rd dimension)')
      [percorcorcomsrc -1 percorcorcomsrc_num]
      %     end
      
      %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
      for aa=1:length(unique(stim.isiseq))
        for bb=1:length(unique(stim.durseq))
          try
            percorcomsrccong(aa,:,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & resp.comsrckeycode==resp.corcong & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))     length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~(resp.comsrckeycode==resp.corcong) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))     length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~(resp.comsrckeycode==resp.corcong) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb)) ];
            percorcomsrccong_numer(aa,:,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))      length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))     length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))      length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  ];
            percorcomsrccong_denom(aa,:,bb)=[length(find(trialuse & resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(trialuse & resp.comsrckeycode==resp.corcong & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(trialuse & ~(resp.comsrckeycode==resp.corcong) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(trialuse & ~(resp.comsrckeycode==resp.corcong) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb)) ];
          catch
            error('reminder to clear before reload')
          end
        end
      end
      disp('Correct-Cong, Correct-Incong, Incorrect-Cong, Incorrect-Incong (% correct of motion direction) (columns), per each ISI (rows) and Duration (3rd dimension)')
      [percorcomsrccong -1 percorcomsrccong_denom]
      %     end
      
      if setup.askmotper
        if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
          for cc=2
            for aa=1:length(unique(stim.isiseq))
              for bb=1:length(unique(stim.durseq))
                permotperisidur(aa,:,bb)=[length(find(resp.motperkeycode==resp.motperkey(cc) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.motperkeycode==resp.motperkey(cc) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.motperkeycode==resp.motperkey(cc) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
                permotperisidur_num(aa,:,bb)=[length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
              end
            end
          end
          disp('congruent, incongruent, audalone (percent motion percept) (columns), per each ISI (rows) and Duration (3rd dimension)')
          permotperisidur
        end
      end
    end
    if setup.av.askfmdcs==0 || setup.av.askfmdcs==2
      
      %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
      disp('flicker, motion, distinct (percent of trials within each ISI (row) and Duration (3rd dimension))')
      for aa=1:length(resp.motperkey)
        for bb=1:length(unique(stim.isiseq))
          for cc=1:length(unique(stim.durseq))
            motperisidur(bb,aa,cc)=length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(trialuse & stim.isiseq==bb & stim.durseq==cc));
          end
        end
      end
      motperisidur
      %     end
      
      disp('Cong, Incong (% Motion percept) (each ISI (row) and Duration (3rd dimension))')
      for aa=2
        for bb=1:length(unique(stim.isiseq))
          for cc=1:length(unique(stim.durseq))
            motpercongisidur(bb,:,cc)=[length(find(resp.motperkeycode==resp.motperkey(aa) & stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))        length(find(resp.motperkeycode==resp.motperkey(aa) & ~stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))];
          end
        end
      end
      motpercongisidur

    
      disp('Cong-MDcor, Cong-MDinc, Incong-MDcor, Incong-MDinc (% Motion percept) (each ISI (row) and Duration (3rd dimension))')
      for aa=2
        for bb=1:length(unique(stim.isiseq))
          for cc=1:length(unique(stim.durseq))
            motpercongdirisidur(bb,:,cc)=[length(find(resp.motperkeycode==resp.motperkey(aa) & resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(trialuse & resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))      length(find(resp.motperkeycode==resp.motperkey(aa) & resp.cormotdir~=resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(trialuse & resp.cormotdir~=resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))        length(find(resp.motperkeycode==resp.motperkey(aa) & resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(trialuse & resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))     length(find(resp.motperkeycode==resp.motperkey(aa) & resp.cormotdir~=resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(trialuse & resp.cormotdir~=resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))];
          end
        end
      end
      motpercongdirisidur
    
    end
    
    
    
    switch setup.paradigm
      case 'cued'
        disp('congruent, incongruent,audalone (percent correct of motion direction), per each cue type')
        for cc=unique(stim.av.cueseq)
          [length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.av.cueseq==cc))]
        end
        
        try
          for cc=unique(stim.av.cueseq)
            percorcomsrccong_percue(cc,:)=[length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse & resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))    length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse & resp.comsrckeycode==resp.corcong & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))     length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse & ~(resp.comsrckeycode==resp.corcong) & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))     length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse & ~(resp.comsrckeycode==resp.corcong) & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc)) ];
            percorcomsrccong_percue_numer(cc,:)=[length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))    length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))      length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))      length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))  ];
            percorcomsrccong_percue_denom(cc,:)=[length(find(trialuse & resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))   length(find(trialuse & resp.comsrckeycode==resp.corcong & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))   length(find(trialuse & ~(resp.comsrckeycode==resp.corcong) & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))    length(find(trialuse & ~(resp.comsrckeycode==resp.corcong) & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc)) ];
          end
        catch
          error('reminder to clear before reload')
        end
        disp('Correct-Cong, Correct-Incong, Incorrect-Cong, Incorrect-Incong (% correct of motion direction), per each cue type')
        [percorcomsrccong_percue, [-1; -1], percorcomsrccong_percue_denom]
        
        
        try
          for cc=unique(stim.av.cueseq)
            comsrcMDisidur_percue(cc,:)=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse & stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))   length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse & stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))    length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse& ~stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))      length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(trialuse& ~stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))];
            comsrcMDisidur_percue_numer(cc,:)=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))   length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))    length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))       length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc)) ];
            comsrcMDisidur_percue_denom(cc,:)=[length(find(trialuse & stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))         length(find(trialuse & stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))          length(find(trialuse& ~stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))               length(find(trialuse & ~stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.av.cueseq==cc))];
          end
        catch
          error('reminder to clear before reload')
        end
        disp('cong-MDcor, cong-MDincor, incong-MDcor, incong-MDincor (% common source correct)(columns), per each ISI (rows) and Duration (3rd dimension)')
        comsrcMDisidur
        
        
        if isfield(setup,'cuetrain') && setup.cuetrain==1
          disp('% of train cue for low cue, then high cue')
          if setup.cueord(1)==1 && length(setup.cueord)==2
            [length(find(resp.cueprobkeycode(1:length(resp.tvbl_vis1on))==resp.cuetrainkey(2)& stim.av.cueseq(1:length(resp.tvbl_vis1on))==1)) / length(find(stim.av.cueseq(1:length(resp.tvbl_vis1on))==1))     length(find(resp.cueprobkeycode(1:length(resp.tvbl_vis1on))==resp.cuetrainkey(1)& stim.av.cueseq(1:length(resp.tvbl_vis1on))==2)) / length(find(stim.av.cueseq(1:length(resp.tvbl_vis1on))==2))]
          elseif setup.cueord(2)==1 && length(setup.cueord)==2
          else
            error('is cueord something other than [1 2] or [2 1]')
          end
        end
        
        
        
      case 'nocue'
        if isfield(resp,'corcong')
          disp('correct mot-dir, incorrect mot-dir (percent congruency correct)')
          [length(find(resp.comsrckeycode(resp.cormotdir==resp.motdirkeycode & trialuse)==resp.corcong(resp.cormotdir==resp.motdirkeycode & trialuse)))/length(find( resp.cormotdir==resp.motdirkeycode & trialuse)) length(find(resp.comsrckeycode(resp.cormotdir~=resp.motdirkeycode & trialuse)==resp.corcong(resp.cormotdir~=resp.motdirkeycode & trialuse)))/length(find( resp.cormotdir~=resp.motdirkeycode & trialuse))]
          
          disp('correct mot-dir, incorrect mot-dir (percent congruency correct), per each asynchrony')
          for aa=1:length(unique(stim.av.asynchseq))
            [length(find(resp.comsrckeycode(resp.cormotdir==resp.motdirkeycode & trialuse & stim.av.asynchseq==aa)==resp.corcong(resp.cormotdir==resp.motdirkeycode & trialuse & stim.av.asynchseq==aa)))/length(find( resp.cormotdir==resp.motdirkeycode & trialuse & stim.av.asynchseq==aa)) length(find(resp.comsrckeycode(resp.cormotdir~=resp.motdirkeycode & trialuse & stim.av.asynchseq==aa)==resp.corcong(resp.cormotdir~=resp.motdirkeycode & trialuse & stim.av.asynchseq==aa)))/length(find( resp.cormotdir~=resp.motdirkeycode & trialuse & stim.av.asynchseq==aa))]
          end
          disp('correct mot-dir, incorrect mot-dir (percent congruency correct), per each ISI')
          for aa=1:length(unique(stim.isiseq))
            [length(find(resp.comsrckeycode(resp.cormotdir==resp.motdirkeycode & trialuse & stim.isiseq==aa)==resp.corcong(resp.cormotdir==resp.motdirkeycode & trialuse & stim.isiseq==aa)))/length(find( resp.cormotdir==resp.motdirkeycode & trialuse & stim.isiseq==aa)) length(find(resp.comsrckeycode(resp.cormotdir~=resp.motdirkeycode & trialuse & stim.isiseq==aa)==resp.corcong(resp.cormotdir~=resp.motdirkeycode & trialuse & stim.isiseq==aa)))/length(find( resp.cormotdir~=resp.motdirkeycode & trialuse & stim.isiseq==aa))]
          end
          disp('correct mot-dir, incorrect mot-dir (percent congruency correct), per each dur')
          for aa=1:length(unique(stim.durseq))
            [length(find(resp.comsrckeycode(resp.cormotdir==resp.motdirkeycode & trialuse & stim.durseq==aa)==resp.corcong(resp.cormotdir==resp.motdirkeycode & trialuse & stim.durseq==aa)))/length(find( resp.cormotdir==resp.motdirkeycode & trialuse & stim.durseq==aa)) length(find(resp.comsrckeycode(resp.cormotdir~=resp.motdirkeycode & trialuse & stim.durseq==aa)==resp.corcong(resp.cormotdir~=resp.motdirkeycode & trialuse & stim.durseq==aa)))/length(find( resp.cormotdir~=resp.motdirkeycode & trialuse & stim.durseq==aa))]
          end
          disp('correct mot-dir, incorrect mot-dir (percent congruency correct) (rows), per each ISI (columns) & Duration (3rd dimension)')
          for aa=1:length(unique(stim.isiseq))
            for bb=1:length(unique(stim.durseq))
              percongcor(aa,:,bb)=[length(find(resp.comsrckeycode(resp.cormotdir==resp.motdirkeycode & trialuse & stim.isiseq==aa & stim.durseq==bb)==resp.corcong(resp.cormotdir==resp.motdirkeycode & trialuse & stim.isiseq==aa & stim.durseq==bb)))/length(find( resp.cormotdir==resp.motdirkeycode & trialuse & stim.isiseq==aa & stim.durseq==bb)) length(find(resp.comsrckeycode(resp.cormotdir~=resp.motdirkeycode & trialuse & stim.isiseq==aa & stim.durseq==bb)==resp.corcong(resp.cormotdir~=resp.motdirkeycode & trialuse & stim.isiseq==aa & stim.durseq==bb)))/length(find( resp.cormotdir~=resp.motdirkeycode & trialuse & stim.isiseq==aa & stim.durseq==bb))];
            end
          end
          percongcor
        end
        
        
    end
    
  case {'visonly' 'audonly'}
    
    disp('percent correct (motion direction)')
    length(find(resp.cormotdir==resp.motdirkeycode))/length(find(trialuse))
    
    if length(unique(stim.isiseq))>1 % we varied ISI
      disp('(percent correct of motion direction), per each ISI')
      for aa=1:length(unique(stim.isiseq))
        motdirisi(aa)=length(find(resp.cormotdir==resp.motdirkeycode & stim.isiseq==aa))  /length(find(trialuse & stim.isiseq==aa));
      end
      motdirisi
    end
    
    if length(unique(stim.durseq))>1 % we varied Duration
      disp('(percent correct of motion direction), per each Duration')
      for aa=1:length(unique(stim.durseq))
        motdirdur(aa)=length(find(resp.cormotdir==resp.motdirkeycode & stim.durseq==aa))  /length(find(trialuse& stim.durseq==aa));
      end
      motdirdur
    end
    
    %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
    for aa=1:length(unique(stim.isiseq))
      for bb=1:length(unique(stim.durseq))
        percorout(aa,bb)=length(find(resp.cormotdir==resp.motdirkeycode & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.isiseq==aa & stim.durseq==bb));
        %           percorout(:,aa,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(trialuse & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
      end
    end
    disp('(percent correct of motion direction), per each ISI (rows) and Duration (columns)')
    percorout
    %     end
    
    disp('(percent correct motion dirction), [flicker  motion  distinct]')
    for aa=1:length(resp.motperkey)
      percormotper(aa)=length(find(resp.cormotdir==resp.motdirkeycode & resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode))) / length(find(resp.motperkeycode==resp.motperkey(aa) & trialuse));
    end
    percormotper
    
    disp('flicker, motion, distinct (percent of all trials)')
    for aa=1:length(resp.motperkey)
      pereachkind(aa)=length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode)))/length(find(trialuse));
    end
    pereachkind
    
    if length(unique(stim.isiseq))>1 % we varied ISI
      disp('flicker, motion, distinct (percent of trials within each ISI (row))')
      for aa=1:length(resp.motperkey)
        for bb=1:length(unique(stim.isiseq))
          motperisi(bb,aa)=length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode) & stim.isiseq==bb))  /length(find(trialuse & stim.isiseq==bb));
        end
      end
      motperisi
    end
    
    if length(unique(stim.durseq))>1 % we varied Duration
      disp('flicker, motion, distinct (percent of trials within each Duration (row))')
      for aa=1:length(resp.motperkey)
        for bb=1:length(unique(stim.durseq))
          motperdur(bb,aa)=length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode) & stim.durseq==bb))  /length(find(trialuse & stim.durseq==bb));
        end
      end
      motperdur
    end
    
    %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
    disp('flicker, motion, distinct (percent of trials within each ISI (row) and Duration (3rd dimension))')
    for aa=1:length(resp.motperkey)
      for bb=1:length(unique(stim.isiseq))
        for cc=1:length(unique(stim.durseq))
          motperisidur(bb,aa,cc)=length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(trialuse & stim.isiseq==bb & stim.durseq==cc));
        end
      end
    end
    motperisidur
    %     end
    
end


% vis post cue timing
switch setup.paradigm
  case 'cued'
    if isfield(setup,'cuetrain') && setup.cuetrain
      % don't need to subtract off setup.postcueQ b/c it is built in to resp.stimstart
      visonsetpostcuejitter=resp.tvbl_vis1on-resp.stimstart(1:length(resp.tvbl_vis1on))-[stim.asynch(stim.av.asynchseq(1:length(resp.tvbl_vis1on)))-min(stim.asynch)];
    else
%       visonsetpostcuejitter=resp.tvbl_vis1on-resp.time_startcue+setup.cueduration-[stim.asynch(stim.av.asynchseq(1:length(resp.tvbl_vis1on)))-min(stim.asynch)]-setup.postcue;
      % first_vis - startcue - asynch - postcue_duration
      visonsetpostcuejitter=resp.tvbl_vis1on-resp.time_startcue-[stim.asynch(stim.av.asynchseq(1:length(resp.tvbl_vis1on)))-min(stim.asynch)]-setup.postcue;
    end
    disp('median and std of postcue jitter around expected')
    [median(visonsetpostcuejitter) std(visonsetpostcuejitter)]
    
%     if isfield(setup,'cuetrain') && setup.cuetrain
%       disp('percent correct/incorrect on cue value')
%       trialuse=1:length(resp.time_startcue);
%       if setup.cueord(1)==1
%         [mean(resp.cueprobkeycode(stim.av.cueseq(trialuse)==setup.cueord(2))==resp.cuetrainkey(1)) mean(resp.cueprobkeycode(stim.av.cueseq(trialuse)==setup.cueord(2))==resp.cuetrainkey(2))]
%       elseif setup.cueord(1)==2
%         [mean(resp.cueprobkeycode(stim.av.cueseq(trialuse)==setup.cueord(1))==resp.cuetrainkey(1)) mean(resp.cueprobkeycode(stim.av.cueseq(trialuse)==setup.cueord(1))==resp.cuetrainkey(2)) ]
%       else
%         error('code for more than 2 cueords?')
%       end
%     end
end

disp('SOA (ISI by Duration)')
[xx,yy]=meshgrid(stim.dur,stim.isi);xx+yy

clear vistiming
switch stim.block
  case {'av'}
    vistiming(1,:)=resp.tvbl_vis1on - (resp.stimstart(1:length(resp.tvbl_vis1on))+[stim.asynch(stim.av.asynchseq(1:length(resp.tvbl_vis1on)))-min(stim.asynch)]);
    vistiming(2,:)=resp.tvbl_vis1off - (resp.stimstart(1:length(resp.tvbl_vis1on))+[stim.asynch(stim.av.asynchseq(1:length(resp.tvbl_vis1on)))-min(stim.asynch)] + stim.dur(stim.durseq(1:length(resp.tvbl_vis1on))));
    vistiming(3,:)=resp.tvbl_vis2on - (resp.stimstart(1:length(resp.tvbl_vis1on))+[stim.asynch(stim.av.asynchseq(1:length(resp.tvbl_vis1on)))-min(stim.asynch)] + stim.dur(stim.durseq(1:length(resp.tvbl_vis1on))) + stim.isi(stim.isiseq(1:length(resp.tvbl_vis1on))));
    vistiming(4,:)=resp.tvbl_vis2off - (resp.stimstart(1:length(resp.tvbl_vis1on))+[stim.asynch(stim.av.asynchseq(1:length(resp.tvbl_vis1on)))-min(stim.asynch)] + 2*stim.dur(stim.durseq(1:length(resp.tvbl_vis1on))) + stim.isi(stim.isiseq(1:length(resp.tvbl_vis1on))));
    disp('vis timing in ms')
    median(vistiming'*1000)
  case {'visonly'}
    vistiming(1,:)=resp.tvbl_vis1on - (resp.stimstart(1:length(resp.tvbl_vis1on)));
    vistiming(2,:)=resp.tvbl_vis1off - (resp.stimstart(1:length(resp.tvbl_vis1on)) + stim.dur(stim.durseq(1:length(resp.tvbl_vis1on))));
    vistiming(3,:)=resp.tvbl_vis2on - (resp.stimstart(1:length(resp.tvbl_vis1on)) + stim.dur(stim.durseq(1:length(resp.tvbl_vis1on))) + stim.isi(stim.isiseq(1:length(resp.tvbl_vis1on))));
    vistiming(4,:)=resp.tvbl_vis2off - (resp.stimstart(1:length(resp.tvbl_vis1on))+ 2*stim.dur(stim.durseq(1:length(resp.tvbl_vis1on))) + stim.isi(stim.isiseq(1:length(resp.tvbl_vis1on))));
    disp('vis timing in ms')
    median(vistiming'*1000)
end

