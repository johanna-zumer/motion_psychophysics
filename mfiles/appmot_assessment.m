% script to assess 'resp' from call_appmot_2locations

switch stim.block
  case 'av'
    
    if ~isfield(resp,'comsrckey')
      resp.comsrckey=[resp.motperkey(1) resp.motperkey(3)];
    end
    
    disp('congruent, incongruent, audalone (percent correct of motion direction)')
    [length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq))  length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq))]
    %     disp('percent AV congruency correct')
    %     length(find(resp.corcong==resp.comsrckeycode))/length(~isnan(resp.comsrckeycode))
    if length(unique(stim.av.asynchseq))>1
      disp('congruent, incongruent, audalone (percent correct of motion direction), per each asynchrony')
      for aa=1:length(unique(stim.av.asynchseq))
        [length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.av.asynchseq==aa))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.av.asynchseq==aa))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.av.asynchseq==aa))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.av.asynchseq==aa))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.av.asynchseq==aa))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.av.asynchseq==aa))]
      end
    end
    
    if length(unique(stim.isiseq))>1 % we varied ISI
      disp('congruent, incongruent, audalone (percent correct of motion direction), per each ISI')
      for aa=1:length(unique(stim.isiseq))
        [length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa))]
      end
    end
    
    if length(unique(stim.durseq))>1 % we varied Duration
      disp('congruent, incongruent, audalone (percent correct of motion direction), per each Duration')
      for aa=1:length(unique(stim.durseq))
        [length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.durseq==aa))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.durseq==aa))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.durseq==aa))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.durseq==aa))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.durseq==aa))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.durseq==aa))]
      end
    end
    
    %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
    for aa=1:length(unique(stim.isiseq))
      for bb=1:length(unique(stim.durseq))
        try
          percorout(aa,:,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
          %           percorout(:,aa,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
        catch
          error('reminder to clear before reload')
        end
      end
    end
    disp('congruent, incongruent, audalone (percent correct of motion direction) (columns), per each ISI (rows) and Duration (3rd dimension)')
    percorout
    %     end
    
    if ~isfield(setup,'av')
      setup.av.askfmdcs=1;
    end
    
    if setup.av.askfmdcs==1 || setup.av.askfmdcs==2
      disp('display percent common source percept as function of congruency')
      disp('congruent, incongruent, audalone (% common source correct)')
      comsrc=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq))  /length(find(~isnan(resp.comsrckeycode) & stim.av.congseq & stim.av.vtrialseq))   length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & stim.av.vtrialseq))  /length(find(~isnan(resp.comsrckeycode)& ~stim.av.congseq & stim.av.vtrialseq))   length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & ~stim.av.vtrialseq))  /length(find(~isnan(resp.comsrckeycode)& ~stim.av.congseq & ~stim.av.vtrialseq)) ];
      comsrc

      for aa=1:length(unique(stim.isiseq))
        for bb=1:length(unique(stim.durseq))
          comsrcisidur(aa,:,bb)=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.comsrckeycode) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.comsrckeycode)& ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   ];
        end
      end
      disp('congruent, incongruent, audalone (% common source correct)(columns), per each ISI (rows) and Duration (3rd dimension)')
      comsrcisidur
      

      for aa=1:length(unique(stim.isiseq))
        for bb=1:length(unique(stim.durseq))
          comsrcMDisidur(aa,:,bb)=[length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.comsrckeycode) & stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.comsrckeycode==resp.corcong & stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.comsrckeycode) & stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.comsrckeycode)& ~stim.av.congseq & resp.cormotdir==resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))      length(find(resp.comsrckeycode==resp.corcong & ~stim.av.congseq  & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.comsrckeycode)& ~stim.av.congseq & resp.cormotdir~=resp.motdirkeycode & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
        end
      end
      disp('cong-MDcor, cong-MDincor, incong-MDcor, incong-MDincor (% common source correct)(columns), per each ISI (rows) and Duration (3rd dimension)')
      comsrcMDisidur

      
      %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
      for aa=1:length(unique(stim.isiseq))
        for bb=1:length(unique(stim.durseq))
          try
            percorcomsrc(aa,:,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.comsrckey(1) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & resp.comsrckeycode==resp.comsrckey(1) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.comsrckey(2) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & resp.comsrckeycode==resp.comsrckey(2) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb)) ];
            %           percorout(:,aa,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
          catch
            error('reminder to clear before reload')
          end
        end
      end
      disp('ComSrc, Not ComSrc, AudAlone (percent correct of motion direction) (columns), per each ISI (rows) and Duration (3rd dimension)')
      percorcomsrc
      %     end
      
      %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
      for aa=1:length(unique(stim.isiseq))
        for bb=1:length(unique(stim.durseq))
          try
            percorcorcomsrc(aa,:,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & resp.comsrckeycode==resp.corcong & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~(resp.comsrckeycode==resp.corcong) & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb)) ];
            %           percorout(:,aa,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
          catch
            error('reminder to clear before reload')
          end
        end
      end
      disp('ComSrc-Cong, NotComSrc-Incong, AudAlone (percent correct of motion direction) (columns), per each ISI (rows) and Duration (3rd dimension)')
      percorcorcomsrc
      %     end
      
      %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
      for aa=1:length(unique(stim.isiseq))
        for bb=1:length(unique(stim.durseq))
          try
            percorcomsrccong(aa,:,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & resp.comsrckeycode==resp.corcong & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & resp.comsrckeycode==resp.corcong & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & resp.comsrckeycode==resp.corcong & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))     length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~(resp.comsrckeycode==resp.corcong) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))     length(find(resp.cormotdir==resp.motdirkeycode & ~(resp.comsrckeycode==resp.corcong) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~(resp.comsrckeycode==resp.corcong) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb)) ];
          catch
            error('reminder to clear before reload')
          end
        end
      end
      disp('Correct-Cong, Correct-Incong, Incorrect-Cong, Incorrect-Incong (% correct of motion direction) (columns), per each ISI (rows) and Duration (3rd dimension)')
      percorcomsrccong
      %     end
      
      if setup.askmotper
        if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
          for cc=2
            for aa=1:length(unique(stim.isiseq))
              for bb=1:length(unique(stim.durseq))
                permotperisidur(aa,:,bb)=[length(find(resp.motperkeycode==resp.motperkey(cc) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.motperkeycode==resp.motperkey(cc) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.motperkeycode==resp.motperkey(cc) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
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
            motperisidur(bb,aa,cc)=length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc));
          end
        end
      end
      motperisidur
      %     end
      
      disp('Cong, Incong (% Motion percept) (each ISI (row) and Duration (3rd dimension))')
      for aa=2
        for bb=1:length(unique(stim.isiseq))
          for cc=1:length(unique(stim.durseq))
            motpercongisidur(bb,:,cc)=[length(find(resp.motperkeycode==resp.motperkey(aa) & stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(~isnan(resp.motperkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))        length(find(resp.motperkeycode==resp.motperkey(aa) & ~stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(~isnan(resp.motperkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))];
          end
        end
      end
      motpercongisidur

    
      disp('Cong-MDcor, Cong-MDinc, Incong-MDcor, Incong-MDinc (% Motion percept) (each ISI (row) and Duration (3rd dimension))')
      for aa=2
        for bb=1:length(unique(stim.isiseq))
          for cc=1:length(unique(stim.durseq))
            motpercongdirisidur(bb,:,cc)=[length(find(resp.motperkeycode==resp.motperkey(aa) & resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(~isnan(resp.motperkeycode) & resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))      length(find(resp.motperkeycode==resp.motperkey(aa) & resp.cormotdir~=resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(~isnan(resp.motperkeycode) & resp.cormotdir~=resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))        length(find(resp.motperkeycode==resp.motperkey(aa) & resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(~isnan(resp.motperkeycode) & resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))     length(find(resp.motperkeycode==resp.motperkey(aa) & resp.cormotdir~=resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(~isnan(resp.motperkeycode) & resp.cormotdir~=resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==bb & stim.durseq==cc))];
          end
        end
      end
      motpercongdirisidur
    
    end
    
    
    
    switch setup.paradigm
      case 'cued'
        disp('congruent, incongruent,audalone (percent correct of motion direction), per each cue type')
        for cc=unique(stim.av.cueseq)
          [length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.av.cueseq==cc))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.av.cueseq==cc))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.av.cueseq==cc))]
        end
        
        
      case 'nocue'
        if isfield(resp,'corcong')
          disp('correct mot-dir, incorrect mot-dir (percent congruency correct)')
          [length(find(resp.comsrckeycode(resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode))==resp.corcong(resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode))))/length(find( resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode))) length(find(resp.comsrckeycode(resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode))==resp.corcong(resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode))))/length(find( resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode)))]
          
          disp('correct mot-dir, incorrect mot-dir (percent congruency correct), per each asynchrony')
          for aa=1:length(unique(stim.av.asynchseq))
            [length(find(resp.comsrckeycode(resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.av.asynchseq==aa)==resp.corcong(resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.av.asynchseq==aa)))/length(find( resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.av.asynchseq==aa)) length(find(resp.comsrckeycode(resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.av.asynchseq==aa)==resp.corcong(resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.av.asynchseq==aa)))/length(find( resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.av.asynchseq==aa))]
          end
          disp('correct mot-dir, incorrect mot-dir (percent congruency correct), per each ISI')
          for aa=1:length(unique(stim.isiseq))
            [length(find(resp.comsrckeycode(resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa)==resp.corcong(resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa)))/length(find( resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa)) length(find(resp.comsrckeycode(resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa)==resp.corcong(resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa)))/length(find( resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa))]
          end
          disp('correct mot-dir, incorrect mot-dir (percent congruency correct), per each dur')
          for aa=1:length(unique(stim.durseq))
            [length(find(resp.comsrckeycode(resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.durseq==aa)==resp.corcong(resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.durseq==aa)))/length(find( resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.durseq==aa)) length(find(resp.comsrckeycode(resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.durseq==aa)==resp.corcong(resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.durseq==aa)))/length(find( resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.durseq==aa))]
          end
          disp('correct mot-dir, incorrect mot-dir (percent congruency correct) (rows), per each ISI (columns) & Duration (3rd dimension)')
          for aa=1:length(unique(stim.isiseq))
            for bb=1:length(unique(stim.durseq))
              percongcor(aa,:,bb)=[length(find(resp.comsrckeycode(resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa & stim.durseq==bb)==resp.corcong(resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa & stim.durseq==bb)))/length(find( resp.cormotdir==resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa & stim.durseq==bb)) length(find(resp.comsrckeycode(resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa & stim.durseq==bb)==resp.corcong(resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa & stim.durseq==bb)))/length(find( resp.cormotdir~=resp.motdirkeycode & ~isnan(resp.motdirkeycode) & stim.isiseq==aa & stim.durseq==bb))];
            end
          end
          percongcor
        end
        
        
    end
    
    disp('display percent capture as function of congruency')
    % vis post cue timing
    
  case {'visonly' 'audonly'}
    
    disp('percent correct (motion direction)')
    length(find(resp.cormotdir==resp.motdirkeycode))/length(find(~isnan(resp.motdirkeycode)))
    
    if length(unique(stim.isiseq))>1 % we varied ISI
      disp('(percent correct of motion direction), per each ISI')
      for aa=1:length(unique(stim.isiseq))
        motdirisi(aa)=length(find(resp.cormotdir==resp.motdirkeycode & stim.isiseq==aa))  /length(find(~isnan(resp.motdirkeycode) & stim.isiseq==aa));
      end
      motdirisi
    end
    
    if length(unique(stim.durseq))>1 % we varied Duration
      disp('(percent correct of motion direction), per each Duration')
      for aa=1:length(unique(stim.durseq))
        motdirdur(aa)=length(find(resp.cormotdir==resp.motdirkeycode & stim.durseq==aa))  /length(find(~isnan(resp.motdirkeycode)& stim.durseq==aa));
      end
      motdirdur
    end
    
    %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
    for aa=1:length(unique(stim.isiseq))
      for bb=1:length(unique(stim.durseq))
        percorout(aa,bb)=length(find(resp.cormotdir==resp.motdirkeycode & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & stim.isiseq==aa & stim.durseq==bb));
        %           percorout(:,aa,bb)=[length(find(resp.cormotdir==resp.motdirkeycode & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))   length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))    length(find(resp.cormotdir==resp.motdirkeycode & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))  /length(find(~isnan(resp.motdirkeycode) & ~stim.av.congseq & ~stim.av.vtrialseq & stim.isiseq==aa & stim.durseq==bb))];
      end
    end
    disp('(percent correct of motion direction), per each ISI (rows) and Duration (columns)')
    percorout
    %     end
    
    disp('(percent correct motion dirction), [flicker  motion  distinct]')
    for aa=1:length(resp.motperkey)
      percormotper(aa)=length(find(resp.cormotdir==resp.motdirkeycode & resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode))) / length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode)));
    end
    percormotper
    
    disp('flicker, motion, distinct (percent of all trials)')
    for aa=1:length(resp.motperkey)
      pereachkind(aa)=length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode)))/length(find(~isnan(resp.motperkeycode)));
    end
    pereachkind
    
    if length(unique(stim.isiseq))>1 % we varied ISI
      disp('flicker, motion, distinct (percent of trials within each ISI (row))')
      for aa=1:length(resp.motperkey)
        for bb=1:length(unique(stim.isiseq))
          motperisi(bb,aa)=length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode) & stim.isiseq==bb))  /length(find(~isnan(resp.motperkeycode) & stim.isiseq==bb));
        end
      end
      motperisi
    end
    
    if length(unique(stim.durseq))>1 % we varied Duration
      disp('flicker, motion, distinct (percent of trials within each Duration (row))')
      for aa=1:length(resp.motperkey)
        for bb=1:length(unique(stim.durseq))
          motperdur(bb,aa)=length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode) & stim.durseq==bb))  /length(find(~isnan(resp.motperkeycode) & stim.durseq==bb));
        end
      end
      motperdur
    end
    
    %     if length(unique(stim.durseq))>1 && length(unique(stim.isiseq))>1
    disp('flicker, motion, distinct (percent of trials within each ISI (row) and Duration (3rd dimension))')
    for aa=1:length(resp.motperkey)
      for bb=1:length(unique(stim.isiseq))
        for cc=1:length(unique(stim.durseq))
          motperisidur(bb,aa,cc)=length(find(resp.motperkeycode==resp.motperkey(aa) & ~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc))  /length(find(~isnan(resp.motperkeycode) & stim.isiseq==bb & stim.durseq==cc));
        end
      end
    end
    motperisidur
    %     end
    
end


switch setup.paradigm
  case 'cued'
    %     visonsetpostcuejitter=resp.tvbl_vis1on-resp.time_endcue-[stim.asynch(stim.av.asynchseq(1:length(resp.tvbl_vis1on)))-min(stim.asynch)]-setup.postcue;
    visonsetpostcuejitter=resp.tvbl_vis1on-resp.time_startcue+setup.cueduration-[stim.asynch(stim.av.asynchseq(1:length(resp.tvbl_vis1on)))-min(stim.asynch)]-setup.postcue;
    median(visonsetpostcuejitter)
    std(visonsetpostcuejitter)
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


