clear all
close all
if ispc
  cd('D:\motion_psychophysics\behav_data');
else
  cd('/mnt/hgfs/D/motion_psychophysics/behav_data');
end

%%
maxsub=18;

% JZ was: 01, 13, 14, 15, 19

motperuse=-.1*ones(5,9,maxsub); % ISI by DUR by participant
flkperuse=-.1*ones(5,9,maxsub); % ISI by DUR by participant
dstperuse=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoruse=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravc=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravi=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravc_csy=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravi_csy=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravc_csn=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravi_csn=-.1*ones(5,9,maxsub); % ISI by DUR by participant

for ii=2:maxsub
  if ii<10
    sub=['p0' num2str(ii)];
  else
    sub=['p' num2str(ii)];
  end
  audfile=dir([sub '_audonly*']);
  if ii<5
    motperisidursub=zeros(4,3,3);
    percoroutsub=zeros(4,3);
  elseif ii<13
    motperisidursub=zeros(3,3,4);
    percoroutsub=zeros(3,4);
  elseif ii<14
    motperisidursub=zeros(2,3,6);
    percoroutsub=zeros(2,6);
  elseif ii<15
    motperisidursub=zeros(1,3,2);
    percoroutsub=zeros(1,2);
  elseif ii<19
    motperisidursub=zeros(1,3,7);
    percoroutsub=zeros(1,7);
  end
  ffuse=0;
  for ff=1:length(audfile)
    load(audfile(ff).name);
    if stim.loc(2)~=10
      continue
    end
    if sum(isnan(resp.motdirkeycode))>4 && ii~=4
      continue
    end
    clear motperisidur percorout
    appmot_assessment;
    motperisidursub=motperisidursub+motperisidur;
    percoroutsub=percoroutsub+percorout;
    ffuse=ffuse+1;
  end
  motperisidursub=motperisidursub/ffuse;
  percoroutsub=percoroutsub/ffuse;
  if ii<5
    motperuse(2:5,1:3,ii)=squeeze(motperisidursub(:,2,:));
    flkperuse(2:5,1:3,ii)=squeeze(motperisidursub(:,1,:));
    dstperuse(2:5,1:3,ii)=squeeze(motperisidursub(:,3,:));
    percoruse(2:5,1:3,ii)=percoroutsub;
  elseif ii<11
    motperuse(1:3,2:5,ii)=squeeze(motperisidursub(:,2,:));
    flkperuse(1:3,2:5,ii)=squeeze(motperisidursub(:,1,:));
    dstperuse(1:3,2:5,ii)=squeeze(motperisidursub(:,3,:));
    percoruse(1:3,2:5,ii)=percoroutsub;
  elseif ii<13
    motperuse(1:3,[2 4 5 6],ii)=squeeze(motperisidursub(:,2,:));
    flkperuse(1:3,[2 4 5 6],ii)=squeeze(motperisidursub(:,1,:));
    dstperuse(1:3,[2 4 5 6],ii)=squeeze(motperisidursub(:,3,:));
    percoruse(1:3,[2 4 5 6],ii)=percoroutsub;
  elseif ii<14
    motperuse(1:2,[2 5 6 7 8 9],ii)=squeeze(motperisidursub(:,2,:));
    flkperuse(1:2,[2 5 6 7 8 9],ii)=squeeze(motperisidursub(:,1,:));
    dstperuse(1:2,[2 5 6 7 8 9],ii)=squeeze(motperisidursub(:,3,:));
    percoruse(1:2,[2 5 6 7 8 9],ii)=percoroutsub;
  elseif ii<15
    motperuse(1,[2 5 ],ii)=squeeze(motperisidursub(:,2,:));
    flkperuse(1,[2 5 ],ii)=squeeze(motperisidursub(:,1,:));
    dstperuse(1,[2 5 ],ii)=squeeze(motperisidursub(:,3,:));
    percoruse(1,[2 5 ],ii)=percoroutsub;
  elseif ii<19
    motperuse(1,[2:8],ii)=squeeze(motperisidursub(:,2,:));
    flkperuse(1,[2:8 ],ii)=squeeze(motperisidursub(:,1,:));
    dstperuse(1,[2:8 ],ii)=squeeze(motperisidursub(:,3,:));
    percoruse(1,[2:8 ],ii)=percoroutsub;
  end
  
  figure(1);
  subplot(4,5,ii-1);imagesc(flkperuse(:,:,ii));
  if ii==3,title('% flicker percept'),end
  if ii==6,ylabel('ISI');end
  if ii==18,xlabel('DUR');end
  set(get(1,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(1,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);;
  
  figure(2);
  subplot(4,5,ii-1);imagesc(motperuse(:,:,ii));
  if ii==3,title('% motion percept'),end
  if ii==6,ylabel('ISI');end
  if ii==18,xlabel('DUR');end
  set(get(2,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(2,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);;
  
  figure(3);
  subplot(4,5,ii-1);imagesc(dstperuse(:,:,ii));
  if ii==3,title('% distinct percept'),end
  if ii==6,ylabel('ISI');end
  if ii==18,xlabel('DUR');end
  set(get(3,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(3,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);;
  
  figure(4);
  subplot(4,5,ii-1);imagesc(percoruse(:,:,ii));
  if ii==3,title('% motion direction'),end
  if ii==6,ylabel('ISI');end
  if ii==18,xlabel('DUR');end
  set(get(4,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(4,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);;
  
  
  avfile=dir([sub '_av*']);
  if ii<5
    percoroutsub=zeros(4,3,3);
    percorcomsrccongsub=zeros(4,4,3);
  elseif ii<13
    percoroutsub=zeros(3,3,4);
    percorcomsrccongsub=zeros(3,4,4);
  elseif ii<14
    percoroutsub=zeros(2,3,6);
    percorcomsrccongsub=zeros(2,4,6);
  elseif ii<15
    percoroutsub=zeros(1,3,2);
    percorcomsrccongsub=zeros(1,4,2);
  elseif ii<19
    percoroutsub=zeros(1,3,7);
    percorcomsrccongsub=zeros(1,4,7);
  end
  ffuse1=0;
  ffuse2=0;
  for ff=1:length(avfile)
    load(avfile(ff).name);
    if stim.loc(2)~=10
      continue
    end
    if sum(isnan(resp.motdirkeycode))>4 && ii~=5  && ii~=7
      continue
    end
    clear motperisidur percorout comsrc* percorcomsrc percongcor percorcomsrccong
    appmot_assessment;
    percoroutsub=percoroutsub+percorout;
    ffuse1=ffuse1+1;
    if ~isfield(setup,'av')
      setup.av.askfmdcs=1;
    end
    if setup.av.askfmdcs
      percorcomsrccongsub=percorcomsrccongsub+percorcomsrccong;
    else
      continue
    end
    ffuse2=ffuse2+1;
  end
  percoroutsub=percoroutsub/ffuse1;
  percorcomsrccongsub=percorcomsrccongsub/ffuse2;
  if ii<5
    percoravc(2:5,1:3,ii)=percoroutsub(:,1,:);
    percoravi(2:5,1:3,ii)=percoroutsub(:,2,:);
    percoravc_csy(2:5,1:3,ii)=percorcomsrccongsub(:,1,:);
    percoravi_csy(2:5,1:3,ii)=percorcomsrccongsub(:,2,:);
    percoravc_csn(2:5,1:3,ii)=percorcomsrccongsub(:,3,:);
    percoravi_csn(2:5,1:3,ii)=percorcomsrccongsub(:,4,:);
  elseif ii<11
    percoravc(1:3,2:5,ii)=percoroutsub(:,1,:);
    percoravi(1:3,2:5,ii)=percoroutsub(:,2,:);
    percoravc_csy(1:3,2:5,ii)=percorcomsrccongsub(:,1,:);
    percoravi_csy(1:3,2:5,ii)=percorcomsrccongsub(:,2,:);
    percoravc_csn(1:3,2:5,ii)=percorcomsrccongsub(:,3,:);
    percoravi_csn(1:3,2:5,ii)=percorcomsrccongsub(:,4,:);
  elseif ii<13
    percoravc(1:3,[2 5 6 7],ii)=percoroutsub(:,1,:);
    percoravi(1:3,[2 5 6 7],ii)=percoroutsub(:,2,:);
    percoravc_csy(1:3,[2 5 6 7],ii)=percorcomsrccongsub(:,1,:);
    percoravi_csy(1:3,[2 5 6 7],ii)=percorcomsrccongsub(:,2,:);
    percoravc_csn(1:3,[2 5 6 7],ii)=percorcomsrccongsub(:,3,:);
    percoravi_csn(1:3,[2 5 6 7],ii)=percorcomsrccongsub(:,4,:);
  elseif ii<14
    percoravc(1:2,[2 5 6 7 8 9],ii)=percoroutsub(:,1,:);
    percoravi(1:2,[2 5 6 7 8 9],ii)=percoroutsub(:,2,:);
    percoravc_csy(1:2,[2 5 6 7 8 9],ii)=percorcomsrccongsub(:,1,:);
    percoravi_csy(1:2,[2 5 6 7 8 9],ii)=percorcomsrccongsub(:,2,:);
    percoravc_csn(1:2,[2 5 6 7 8 9],ii)=percorcomsrccongsub(:,3,:);
    percoravi_csn(1:2,[2 5 6 7 8 9],ii)=percorcomsrccongsub(:,4,:);
  elseif ii<15
    percoravc(1,[2 5],ii)=percoroutsub(:,1,:);
    percoravi(1,[2 5],ii)=percoroutsub(:,2,:);
    percoravc_csy(1,[2 5],ii)=percorcomsrccongsub(:,1,:);
    percoravi_csy(1,[2 5],ii)=percorcomsrccongsub(:,2,:);
    percoravc_csn(1,[2 5],ii)=percorcomsrccongsub(:,3,:);
    percoravi_csn(1,[2 5],ii)=percorcomsrccongsub(:,4,:);
  elseif ii<19
    percoravc(1,[2:8],ii)=percoroutsub(:,1,:);
    percoravi(1,[2:8],ii)=percoroutsub(:,2,:);
    percoravc_csy(1,[2:8],ii)=percorcomsrccongsub(:,1,:);
    percoravi_csy(1,[2:8],ii)=percorcomsrccongsub(:,2,:);
    percoravc_csn(1,[2:8],ii)=percorcomsrccongsub(:,3,:);
    percoravi_csn(1,[2:8],ii)=percorcomsrccongsub(:,4,:);
  end
  
  figure(5);
  subplot(4,5,ii-1);imagesc(percoravc(:,:,ii));
  if ii==3,title('% motion direction; AV cong'),end
  if ii==6,ylabel('ISI');end
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);;
  
  figure(6);
  subplot(4,5,ii-1);imagesc(percoravi(:,:,ii));
  if ii==3,title('% motion direction; AV incong'),end
  if ii==6,ylabel('ISI');end
  if ii==18,xlabel('DUR');end
  set(get(6,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(6,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);
  
  if setup.av.askfmdcs
    figure(7);
    subplot(4,5,ii-1);imagesc(percoravc_csy(:,:,ii));
    if ii==3,title('% motion direction; CorrectComSrc & AV cong'),end
    if ii==6,ylabel('ISI');end
    if ii==18,xlabel('DUR');end
    set(get(7,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
    set(get(7,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
    caxis([-.1 1]);
    
    figure(8);
    subplot(4,5,ii-1);imagesc(percoravi_csy(:,:,ii));
    if ii==3,title('% motion direction; CorrectComSrc & AV incong'),end
    if ii==6,ylabel('ISI');end
    if ii==18,xlabel('DUR');end
    set(get(8,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
    set(get(8,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
    caxis([-.1 1]);
    
    figure(9);
    subplot(4,5,ii-1);imagesc(percoravc_csn(:,:,ii));
    if ii==3,title('% motion direction; IncorrectComSrc & AV cong'),end
    if ii==6,ylabel('ISI');end
    if ii==18,xlabel('DUR');end
    set(get(9,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
    set(get(9,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
    caxis([-.1 1]);
    
    figure(10);
    subplot(4,5,ii-1);imagesc(percoravi_csn(:,:,ii));
    if ii==3,title('% motion direction; IncorrectComSrc & AV incong'),end
    if ii==6,ylabel('ISI');end
    if ii==18,xlabel('DUR');end
    set(get(10,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
    set(get(10,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
    caxis([-.1 1]);
  end
  
end

for ind=1:10
  figure(ind);subplot(4,5,20);imagesc(-.1);caxis([-.1 1]);colorbar;
end

flkperuse(flkperuse==-.1)=nan;
motperuse(motperuse==-.1)=nan;
dstperuse(dstperuse==-.1)=nan;
figure(11);
subplot(1,3,1);imagesc(nanmean(flkperuse(:,:,[2 3 5:maxsub]),3));caxis([-.1 1]);
% set(get(7,'Children'),'xTick',1:6,'xTickLabel',{'34' '50' '67' '84' '100' '117'})
% set(get(7,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
subplot(1,3,2);imagesc(nanmean(motperuse(:,:,[2 3 5:maxsub]),3));caxis([-.1 1]);
% set(get(7,'Children'),'xTick',1:6,'xTickLabel',{'34' '50' '67' '84' '100' '117'})
% set(get(7,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
subplot(1,3,3);imagesc(nanmean(dstperuse(:,:,[2 3 5:maxsub]),3));caxis([-.1 1]);
set(get(11,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
set(get(11,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})

percoravc(percoravc==-.1)=nan;
percoravi(percoravi==-.1)=nan;
figure(12);
subplot(1,2,1);imagesc(nanmean(percoravc(:,:,[2:maxsub]),3));caxis([-.1 1]);
set(get(12,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
set(get(12,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
subplot(1,2,2);imagesc(nanmean(percoravi(:,:,[2:maxsub]),3));caxis([-.1 1]);
set(get(12,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
set(get(12,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})

%% For those who have mot-per in both AA and AV conditions:

close all
subuse=[15:18 24:27];
maxsub=max(subuse);

motperaa=-.1*ones(5,9,maxsub); % ISI by DUR by participant
flkperaa=-.1*ones(5,9,maxsub); % ISI by DUR by participant
dstperaa=-.1*ones(5,9,maxsub); % ISI by DUR by participant

motperav=-.1*ones(5,9,maxsub); % ISI by DUR by participant
flkperav=-.1*ones(5,9,maxsub); % ISI by DUR by participant
dstperav=-.1*ones(5,9,maxsub); % ISI by DUR by participant

percoraa=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percorav=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravc=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravi=-.1*ones(5,9,maxsub); % ISI by DUR by participant

percoravcs1=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravcs0=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravCSc=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravCSi=-.1*ones(5,9,maxsub); % ISI by DUR by participant

percoravcs1_117=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravcs0_117=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravCSc_117=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravCSi_117=-.1*ones(5,9,maxsub); % ISI by DUR by participant

percoravcs1_117_5=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravcs0_117_5=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravCSc_117_5=-.1*ones(5,9,maxsub); % ISI by DUR by participant
percoravCSi_117_5=-.1*ones(5,9,maxsub); % ISI by DUR by participant

for ii=subuse
  if ii<10
    sub=['p0' num2str(ii)];
  else
    sub=['p' num2str(ii)];
  end
  audfile=dir([sub '_audonly*']);
  if ii<19
    motperisidursub=zeros(1,3,7);
    percoroutsub=zeros(1,7);
  elseif ii>23
    motperisidursub=zeros(1,3,5);
    percoroutsub=zeros(1,5);
  end
  ffuse=0;
  for ff=1:length(audfile)
    load(audfile(ff).name);
    if stim.loc(2)~=10
      continue
    end
    if sum(isnan(resp.motdirkeycode))>4 && ii~=4
      continue
    end
    clear motperisidur percorout
    appmot_assessment;
    motperisidursub=motperisidursub+motperisidur;
    percoroutsub=percoroutsub+percorout;
    ffuse=ffuse+1;
  end
  motperisidursub=motperisidursub/ffuse;
  percoroutsub=percoroutsub/ffuse;
  if ii<19
    motperaa(1,[2:8],ii)=squeeze(motperisidursub(:,2,:));
    flkperaa(1,[2:8 ],ii)=squeeze(motperisidursub(:,1,:));
    dstperaa(1,[2:8 ],ii)=squeeze(motperisidursub(:,3,:));
    percoraa(1,[2:8 ],ii)=percoroutsub;
  elseif ii>23
    motperaa(1,[2 4 5 6 7],ii)=squeeze(motperisidursub(:,2,:));
    flkperaa(1,[2 4 5 6 7],ii)=squeeze(motperisidursub(:,1,:));
    dstperaa(1,[2 4 5 6 7],ii)=squeeze(motperisidursub(:,3,:));
    percoraa(1,[2 4 5 6 7],ii)=percoroutsub;    
  end
  
  avfile=dir([sub '_av*']);

  if ii<19
    motperisidursub=zeros(1,3,7);
    percoroutsub=zeros(1,3,7);
  elseif ii>23
    motperisidursub=zeros(1,3,5);
    percoroutsub=zeros(1,3,5);
  end
  ffuse=0;
  for ff=1:length(avfile)
    load(avfile(ff).name);
    if stim.loc(2)~=10
      continue
    end
    if sum(isnan(resp.motdirkeycode))>4 && ii~=5  && ii~=7
      continue
    end
    if setup.av.askfmdcs
      continue % we only want the fmd av trials here
    end
    clear motperisidur percorout comsrc* percorcomsrc percongcor percorcomsrccong
    appmot_assessment;
    motperisidursub=motperisidursub+motperisidur;
    percoroutsub=percoroutsub+percorout;
    ffuse=ffuse+1;
  end
  motperisidursub=motperisidursub/ffuse;
  percoroutsub=percoroutsub/ffuse;
  if ii<19
    motperav(1,[2:8],ii)=squeeze(motperisidursub(:,2,:));
    flkperav(1,[2:8 ],ii)=squeeze(motperisidursub(:,1,:));
    dstperav(1,[2:8 ],ii)=squeeze(motperisidursub(:,3,:));
    percorav(1,[2:8 ],ii)=squeeze(nanmean(percoroutsub,2));
    percoravc(1,[2:8 ],ii)=squeeze(percoroutsub(:,1,:))
    percoravi(1,[2:8 ],ii)=squeeze(percoroutsub(:,2,:));
  elseif ii>23
    motperav(1,[2 4 5 6 7],ii)=squeeze(motperisidursub(:,2,:));
    flkperav(1,[2 4 5 6 7],ii)=squeeze(motperisidursub(:,1,:));
    dstperav(1,[2 4 5 6 7],ii)=squeeze(motperisidursub(:,3,:));
    percorav(1,[2 4 5 6 7],ii)=squeeze(nanmean(percoroutsub,2));
    percoravc(1,[2 4 5 6 7],ii)=squeeze(percoroutsub(:,1,:));
    percoravi(1,[2 4 5 6 7],ii)=squeeze(percoroutsub(:,2,:));
  end
  
  if ii<19
    percorcomsrcsub=zeros(1,2,7);
    percoroutCSsub=zeros(1,3,7);
  elseif ii>23
    percorcomsrcsub=zeros(1,2,5);
    percoroutCSsub=zeros(1,3,5);
  end
  ffuse=0;
  for ff=1:length(avfile)
    load(avfile(ff).name);
    if stim.loc(2)~=10
      continue
    end
    if sum(isnan(resp.motdirkeycode))>4 && ii~=5  && ii~=7
      continue
    end
    if setup.av.askfmdcs==0
      continue % we only want the cs av trials here
    end
    if ii>23 && length(stim.dur_flip)==1
      continue % skip blocks where final (only one) duration was used
    end
    clear motperisidur percorout comsrc* percorcomsrc percongcor percorcomsrccong
    appmot_assessment;
    percorcomsrcsub=percorcomsrcsub+percorcomsrc;
    percoroutCSsub=percoroutCSsub+percorout;
    ffuse=ffuse+1;
  end
  percorcomsrcsub=percorcomsrcsub/ffuse;
  percoroutCSsub=percoroutCSsub/ffuse;
  if ii<19
    percoravcs1(1,[2:8 ],ii)=squeeze(percorcomsrcsub(:,1,:));
    percoravcs0(1,[2:8 ],ii)=squeeze(percorcomsrcsub(:,2,:));
    percoravCSc(1,[2:8 ],ii)=squeeze(percoroutCSsub(:,1,:));
    percoravCSi(1,[2:8 ],ii)=squeeze(percoroutCSsub(:,2,:));
  elseif ii>23
    percoravcs1(1,[2 4 5 6 7],ii)=squeeze(percorcomsrcsub(:,1,:));
    percoravcs0(1,[2 4 5 6 7],ii)=squeeze(percorcomsrcsub(:,2,:));
    percoravCSc(1,[2 4 5 6 7],ii)=squeeze(percoroutCSsub(:,1,:));
    percoravCSi(1,[2 4 5 6 7],ii)=squeeze(percoroutCSsub(:,2,:));
  end
  
  if ii<19
    percorcomsrcsub=zeros(1,2,1);
    percoroutCS117sub=zeros(1,3,1);
  elseif ii>23
    percorcomsrcsub=zeros(1,2,1);
    percoroutCS117sub=zeros(1,3,1);
  end
  ffuse=0;
  for ff=1:length(avfile)
    load(avfile(ff).name);
    if stim.loc(2)~=10
      continue
    end
    if sum(isnan(resp.motdirkeycode))>4 && ii~=5  && ii~=7
      continue
    end
    if setup.av.askfmdcs==0
      continue % we only want the cs av trials here
    end
    if ii<24
      continue
    end
    if length(stim.dur_flip)>1
      continue % Here we look at only 1 duration run at once
    end
    clear motperisidur percorout comsrc* percorcomsrc percongcor percorcomsrccong
    appmot_assessment;
    percorcomsrcsub=percorcomsrcsub+percorcomsrc;
    percoroutCS117sub=percoroutCS117sub+percorout;
    ffuse=ffuse+1;
  end
  percorcomsrcsub=percorcomsrcsub/ffuse;
  percoroutCS117sub=percoroutCS117sub/ffuse;
  if ii<19
    percoravcs1_117(1,[6 ],ii)=squeeze(percorcomsrcsub(:,1,:));
    percoravcs0_117(1,[6 ],ii)=squeeze(percorcomsrcsub(:,2,:));
    percoravCSc_117(1,[6 ],ii)=squeeze(percoroutCS117sub(:,1,:));
    percoravCSi_117(1,[6 ],ii)=squeeze(percoroutCS117sub(:,2,:));
  elseif ii>23
    percoravcs1_117(1,[6],ii)=squeeze(percorcomsrcsub(:,1,:));
    percoravcs0_117(1,[6],ii)=squeeze(percorcomsrcsub(:,2,:));
    percoravCSc_117(1,[6],ii)=squeeze(percoroutCS117sub(:,1,:));
    percoravCSi_117(1,[6],ii)=squeeze(percoroutCS117sub(:,2,:));
  end
  
  % 5 degrees
  if ii<19
    percorcomsrcsub=zeros(1,2,1);
    percoroutCS117sub=zeros(1,3,1);
  elseif ii>23
    percorcomsrcsub=zeros(1,2,1);
    percoroutCS117sub=zeros(1,3,1);
  end
  ffuse=0;
  for ff=1:length(avfile)
    load(avfile(ff).name);
    if stim.loc(2)~=5  % <-- 5 degrees
      continue
    end
    if sum(isnan(resp.motdirkeycode))>4 && ii~=5  && ii~=7
      continue
    end
    if setup.av.askfmdcs==0
      continue % we only want the cs av trials here
    end
    if ii<24
      continue
    end
    if length(stim.dur_flip)>1
      continue % Here we look at only 1 duration run at once
    end
    clear motperisidur percorout comsrc* percorcomsrc percongcor percorcomsrccong
    appmot_assessment;
    percorcomsrcsub=percorcomsrcsub+percorcomsrc;
    percoroutCS117sub=percoroutCS117sub+percorout;
    ffuse=ffuse+1;
  end
  percorcomsrcsub=percorcomsrcsub/ffuse;
    percoroutCS117sub=percoroutCS117sub/ffuse;
  if ii<19
    percoravcs1_117_5(1,[6 ],ii)=squeeze(percorcomsrcsub(:,1,:));
    percoravcs0_117_5(1,[6 ],ii)=squeeze(percorcomsrcsub(:,2,:));
    percoravCSc_117_5(1,[6 ],ii)=squeeze(percoroutCS117sub(:,1,:));
    percoravCSi_117_5(1,[6 ],ii)=squeeze(percoroutCS117sub(:,2,:));
  elseif ii>23
    percoravcs1_117_5(1,[6],ii)=squeeze(percorcomsrcsub(:,1,:));
    percoravcs0_117_5(1,[6],ii)=squeeze(percorcomsrcsub(:,2,:));
    percoravCSc_117_5(1,[6],ii)=squeeze(percoroutCS117sub(:,1,:));
    percoravCSi_117_5(1,[6],ii)=squeeze(percoroutCS117sub(:,2,:));
  end
  
  if ii<24
    iiplot=ii;
  else
    iiplot=ii-5;
  end
  figure(1);
  subplot(2,length(subuse),iiplot-14);imagesc(flkperaa(:,:,ii));
  if ii==18,xlabel('DUR');end
  set(get(1,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(1,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),title('% flicker percept'),end
  if ii==min(subuse),ylabel('AA');end
  
  figure(2);
  subplot(2,length(subuse),iiplot-14);imagesc(motperaa(:,:,ii));
  if ii==18,xlabel('DUR');end
  set(get(2,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(2,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),title('% motion percept'),end
  if ii==min(subuse),ylabel('AA');end
  
  figure(3);
  subplot(2,length(subuse),iiplot-14);imagesc(dstperaa(:,:,ii));
  if ii==18,xlabel('DUR');end
  set(get(3,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(3,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),title('% distinct percept'),end
  if ii==min(subuse),ylabel('AA');end
  
  figure(1);
  subplot(2,length(subuse),iiplot-14+length(subuse));imagesc(flkperav(:,:,ii));
  if ii==3,title('% flicker percept'),end
  if ii==18,xlabel('DUR');end
  set(get(1,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(1,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AV');end
  
  figure(2);
  subplot(2,length(subuse),iiplot-14+length(subuse));imagesc(motperav(:,:,ii));
  if ii==3,title('% motion percept'),end
  if ii==18,xlabel('DUR');end
  set(get(2,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(2,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AV');end
  
  figure(3);
  subplot(2,length(subuse),iiplot-14+length(subuse));imagesc(dstperav(:,:,ii));
  if ii==3,title('% distinct percept'),end
  if ii==18,xlabel('DUR');end
  set(get(3,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(3,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AV');end
  
  figure(4);
  subplot(4,length(subuse),iiplot-14);imagesc(percoraa(:,:,ii));
  if ii==18,xlabel('DUR');end
  set(get(4,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(4,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),title('% motion direction'),end
  if ii==min(subuse),ylabel('AA');end
  
  figure(4);
  subplot(4,length(subuse),iiplot-14+length(subuse));imagesc(percorav(:,:,ii));
  if ii==3,title('% motion direction'),end
  if ii==18,xlabel('DUR');end
  set(get(4,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(4,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AV');end
  
  figure(4);
  subplot(4,length(subuse),iiplot-14+2*length(subuse));imagesc(percoravc(:,:,ii));
  if ii==3,title('% motion direction'),end
  if ii==18,xlabel('DUR');end
  set(get(4,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(4,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AVc');end
  
  figure(4);
  subplot(4,length(subuse),iiplot-14+3*length(subuse));imagesc(percoravi(:,:,ii));
  if ii==3,title('% motion direction'),end
  if ii==18,xlabel('DUR');end
  set(get(4,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(4,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AVi');end
  
  % This is when it WAS common source
  figure(5);
  subplot(4,length(subuse),iiplot-14);imagesc(percoravCSc(:,:,ii));
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),title('% motion direction'),end
  if ii==min(subuse),ylabel('AV_CSc');end
  
  % This is when it was NOT common source 
  figure(5);
  subplot(4,length(subuse),iiplot-14+length(subuse));imagesc(percoravCSi(:,:,ii));
  if ii==3,title('% motion direction'),end
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AV_CSi');end

  % This is when they thought it WAS common source (whether it was or not)
  figure(5);
  subplot(4,length(subuse),iiplot-14+2*length(subuse));imagesc(percoravcs1(:,:,ii));
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),title('% motion direction'),end
  if ii==min(subuse),ylabel('AV_CS1');end
  
  % This is when they thought it was NOT common source (whether it was or not)
  figure(5);
  subplot(4,length(subuse),iiplot-14+3*length(subuse));imagesc(percoravcs0(:,:,ii));
  if ii==3,title('% motion direction'),end
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AV_CS0');end
  
  % This is when it WAS common source
  figure(6);
  subplot(4,length(subuse),iiplot-14);imagesc(percoravCSc_117(:,:,ii));
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),title('% motion direction'),end
  if ii==min(subuse),ylabel('AV_CSc');end
  
  % This is when it was NOT common source
  figure(6);
  subplot(4,length(subuse),iiplot-14+length(subuse));imagesc(percoravCSi_117(:,:,ii));
  if ii==3,title('% motion direction'),end
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AV_CSi');end

  % This is when they thought it WAS common source (whether it was or not)
  figure(6);
  subplot(4,length(subuse),iiplot-14+2*length(subuse));imagesc(percoravcs1_117(:,:,ii));
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),title('% motion direction'),end
  if ii==min(subuse),ylabel('AV_CS1');end
  
  % This is when they thought it was NOT common source (whether it was or not)
  figure(6);
  subplot(4,length(subuse),iiplot-14+3*length(subuse));imagesc(percoravcs0_117(:,:,ii));
  if ii==3,title('% motion direction'),end
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AV_CS0');end

  % This is when it WAS common source
  figure(7);
  subplot(4,length(subuse),iiplot-14);imagesc(percoravCSc_117_5(:,:,ii));
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),title('% motion direction'),end
  if ii==min(subuse),ylabel('AV_CSc_5deg');end
  
  % This is when it was NOT common source
  figure(7);
  subplot(4,length(subuse),iiplot-14+length(subuse));imagesc(percoravCSi_117_5(:,:,ii));
  if ii==3,title('% motion direction'),end
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AV_CSi_5deg');end

  % This is when they thought it WAS common source (whether it was or not)
  figure(7);
  subplot(4,length(subuse),iiplot-14+2*length(subuse));imagesc(percoravcs1_117_5(:,:,ii));
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),title('% motion direction'),end
  if ii==min(subuse),ylabel('AV_CS1_5deg');end
  
  % This is when they thought it was NOT common source (whether it was or not)
  figure(7);
  subplot(4,length(subuse),iiplot-14+3*length(subuse));imagesc(percoravcs0_117_5(:,:,ii));
  if ii==3,title('% motion direction'),end
  if ii==18,xlabel('DUR');end
  set(get(5,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(get(5,'Children'),'yTick',1:5,'yTickLabel',{'0' '17' '34' '50' '67'})
  caxis([-.1 1]);title(ii)
  if ii==min(subuse),ylabel('AV_CS0_5deg');end

end

%% For all those who have different stim.audio.type

cd('D:\motion_psychophysics\behav_data');
close all
subuse=19:23;
maxsub=max(subuse);

motperaa=-.1*ones(5,9,5,maxsub); % ISI by DUR by audiotype by participant
flkperaa=-.1*ones(5,9,5,maxsub); % ISI by DUR by audiotype by participant
dstperaa=-.1*ones(5,9,5,maxsub); % ISI by DUR by audiotype by participant
percoraa=-.1*ones(5,9,5,maxsub); % ISI by DUR by participant

audiotype={'ITD' 'ILD' 'ILDITD' 'cipic' 'MIT'};

for ii=subuse
  if ii<10
    sub=['p0' num2str(ii)];
  else
    sub=['p' num2str(ii)];
  end
  audfile=dir([sub '_audonly*']);
  if ii>18
    motperisidursub=zeros(1,3,7,5);
    percoroutsub=zeros(1,7,5);
  end
  
  %   ffuse=0;
  for ff=1:length(audfile)
    load(audfile(ff).name);
    if stim.loc(2)~=10
      continue
    end
    if sum(isnan(resp.motdirkeycode))>4 && ii~=4
      continue
    end
    typeind=find(strcmp(audiotype,stim.audio.type));
    if ii==22 && typeind~=5
      motperisidursub(:,:,:,typeind)=nan;
      percoroutsub(:,:,typeind)=nan;
      continue
    end
    clear motperisidur percorout
    appmot_assessment;
    motperisidursub(:,:,:,typeind)=motperisidursub(:,:,:,typeind)+motperisidur;
    percoroutsub(:,:,typeind)=percoroutsub(:,:,typeind)+percorout;
    %     ffuse=ffuse+1;
  end
  %   motperisidursub=motperisidursub/ffuse;
  %   percoroutsub=percoroutsub/ffuse;
  if ii>18
    motperaa(1,[2:8],:,ii)=squeeze(motperisidursub(:,2,:,:));
    flkperaa(1,[2:8 ],:,ii)=squeeze(motperisidursub(:,1,:,:));
    dstperaa(1,[2:8 ],:,ii)=squeeze(motperisidursub(:,3,:,:));
    percoraa(1,[2:8 ],:,ii)=percoroutsub;
  end
  
  switch ii
    case 19
      ylab={['ITD 3'] ['ILD 4'] ['ILDITD 1'] ['CIPIC 5'] ['MIT 2']}
    case 20
      ylab={['ITD 1'] ['ILD 5'] ['ILDITD 4'] ['CIPIC 2'] ['MIT 3']}
    case 21
      ylab={['ITD 4'] ['ILD 5'] ['ILDITD 2'] ['CIPIC 3'] ['MIT 1']}
    case 22
      ylab={['ITD 2'] ['ILD 5'] ['ILDITD 3'] ['CIPIC 4'] ['MIT 1']}
    case 23
      ylab={['ITD 2'] ['ILD 5'] ['ILDITD 4'] ['CIPIC 1'] ['MIT 3']}
    otherwise
      error('set ylab')
  end
  
  figure(1);
  subplot(2,3,ii-18);imagesc(squeeze(flkperaa(1,:,:,ii))');
  if ii==3,title('% flicker percept'),end
  if ii==6,ylabel('HRIR');end
  if ii==18,xlabel('DUR');end
  set(get(1,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  child=get(1,'Children');
  set(child(1),'yTick',1:5,'yTickLabel',ylab)
  caxis([-.1 1]);;
  title(['p' num2str(ii)])
  
  figure(2);
  subplot(2,3,ii-18);imagesc(squeeze(motperaa(1,:,:,ii))');
  if ii==3,title('% motion percept'),end
  if ii==6,ylabel('HRIR');end
  if ii==18,xlabel('DUR');end
  child=get(2,'Children');
  set(get(2,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(child(1),'yTick',1:5,'yTickLabel',ylab)
  caxis([-.1 1]);;
  title(['p' num2str(ii)])
  
  figure(3);
  subplot(2,3,ii-18);imagesc(squeeze(dstperaa(1,:,:,ii))');
  if ii==3,title('% distinct percept'),end
  if ii==6,ylabel('HRIR');end
  if ii==18,xlabel('DUR');end
  child=get(3,'Children');
  set(get(3,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(child(1),'yTick',1:5,'yTickLabel',ylab)
  caxis([-.1 1]);;
  title(['p' num2str(ii)])
  
  figure(4);
  subplot(2,3,ii-18);imagesc(squeeze(percoraa(1,:,:,ii))');
  if ii==3,title('% motion direction correct'),end
  if ii==6,ylabel('HRIR');end
  if ii==18,xlabel('DUR');end
  child=get(4,'Children');
  set(get(4,'Children'),'xTick',1:9,'xTickLabel',{'34' '50' '67' '84' '100' '117' '134' '150' '167'})
  set(child(1),'yTick',1:5,'yTickLabel',ylab)
  caxis([-.1 1]);;
  title(['p' num2str(ii)])
end

%%  For comparing FMD, CS, and FMD+CS 
% 28=JZ, 29=SJ

close all
subuse=[28:29];
maxsub=max(subuse);

% motperav=-.1*ones(6,maxsub); % blocktype by participant
% flkperav=-.1*ones(6,maxsub); % blocktype by participant
% dstperav=-.1*ones(6,maxsub); % blocktype by participant
% 
% percoravc=-.1*ones(6,maxsub); % ISI by DUR by participant
% percoravi=-.1*ones(6,maxsub); % ISI by DUR by participant
% 
% comsrcC=-.1*ones(6,maxsub); % blocktype by participant
% comsrcI=-.1*ones(6,maxsub); % blocktype by participant
% 
% percoravcs1C=-.1*ones(6,maxsub); % blocktype by participant
% percoravcs0C=-.1*ones(6,maxsub); % blocktype by participant
% percoravcs1I=-.1*ones(6,maxsub); % blocktype by participant
% percoravcs0I=-.1*ones(6,maxsub); % blocktype by participant
% 
% comsrcCMDcor=-.1*ones(6,maxsub); % blocktype by participant
% comsrcCMDinc=-.1*ones(6,maxsub); % blocktype by participant
% comsrcIMDcor=-.1*ones(6,maxsub); % blocktype by participant
% comsrcIMDinc=-.1*ones(6,maxsub); % blocktype by participant

ss=1;
for ii=subuse
  if ii<10
    sub=['p0' num2str(ii)];
  else
    sub=['p' num2str(ii)];
  end
  
  avfile=dir([sub '_av*']);
  
  motperisidursub=zeros(6,3);
  comsrcisidursub=zeros(6,2);
  percoroutsub=zeros(6,3);
  percorcomsrcsub=zeros(6,2);
  percorcomsrccongsub=zeros(6,4);
  comsrcMDisidursub=zeros(6,4);
  motpercongisidursub=zeros(6,2);
  motpercongdirisidursub=zeros(6,4);
  
  for ff=1:length(avfile)
    load(avfile(ff).name);
    if sum(isnan(resp.motdirkeycode))>4 && ii~=5  && ii~=7
      continue
    end
    clear motperisidur percorout comsrcisidur percorcomsrc percongcor percorcomsrccong motpercongdirisidur motpercongisidur
    appmot_assessment;
    if setup.av.askfmdcs==0 || setup.av.askfmdcs==2
      motperisidursub(ff,:)=motperisidursub(ff,:)+motperisidur;
      motpercongdirisidursub(ff,:)=motpercongdirisidursub(ff,:)+motpercongdirisidur;
      motpercongisidursub(ff,:)=motpercongisidursub(ff,:)+motpercongisidur;
    else
      motperisidursub(ff,:)=nan;
      motpercongdirisidursub(ff,:)=nan;
      motpercongisidursub(ff,:)=nan;
    end
    if setup.av.askfmdcs==1 || setup.av.askfmdcs==2
      percorcomsrcsub(ff,:)=percorcomsrcsub(ff,:)+percorcomsrc;
      comsrcisidursub(ff,:)=comsrcisidursub(ff,:)+comsrcisidur;
      percorcomsrccongsub(ff,:)=percorcomsrccongsub(ff,:)+percorcomsrccong;
      comsrcMDisidursub(ff,:)=comsrcMDisidursub(ff,:)+comsrcMDisidur;
    else
      percorcomsrcsub(ff,:)=nan;
      comsrcisidursub(ff,:)=nan;
      percorcomsrccongsub(ff,:)=nan;
      comsrcMDisidursub(ff,:)=nan;
    end
    percoroutsub(ff,:)=percoroutsub(ff,:)+percorout;
  end
  
%   comsrcC(:,ii)=squeeze(comsrcisidursub(:,1));
%   comsrcI(:,ii)=squeeze(comsrcisidursub(:,2));

%   percoravc(:,ii)=squeeze(percoroutsub(:,1));
%   percoravi(:,ii)=squeeze(percoroutsub(:,2));
  
%   percoravcs1(:,ii)=squeeze(percorcomsrcsub(:,1)); % ComSrc, Not ComSrc, AudAlone (percent correct of motion direction)
%   percoravcs0(:,ii)=squeeze(percorcomsrcsub(:,2));
  
%   percoravcs1C(:,ii)=squeeze(percorcomsrccongsub(:,1)); % Correct-Cong, Correct-Incong, Incorrect-Cong, Incorrect-Incong (% correct of motion direction)
%   percoravcs0I(:,ii)=squeeze(percorcomsrccongsub(:,2));
%   percoravcs0C(:,ii)=squeeze(percorcomsrccongsub(:,3)); % Correct-Cong, Correct-Incong, Incorrect-Cong, Incorrect-Incong (% correct of motion direction)
%   percoravcs1I(:,ii)=squeeze(percorcomsrccongsub(:,4));
  
%   comsrcCMDcor(:,ii)=comsrcMDisidursub(:,1); % cong-MDcor, cong-MDincor, incong-MDcor, incong-MDincor (% common source correct)
%   comsrcCMDinc(:,ii)=comsrcMDisidursub(:,2);
%   comsrcIMDcor(:,ii)=comsrcMDisidursub(:,3);
%   comsrcIMDinc(:,ii)=comsrcMDisidursub(:,4);

figure(1);subplot(1,length(subuse),ss);plot(motperisidursub,'o');title(sub);legend({'%Flicker' '%Motion' '%Distinct'});axis([-inf inf 0 1])

figure(2);subplot(1,length(subuse),ss);plot(comsrcisidursub,'o');title(sub);legend({'%ComSrcCor-Cong' '%ComSrcCor-Incong'});axis([-inf inf 0 1])

figure(3);subplot(1,length(subuse),ss);plot(percoroutsub,'o');title(sub);legend({'%MotDirCor-Cong' '%MotDirCor-Incong'});axis([-inf inf 0 1])

figure(4);subplot(1,length(subuse),ss);plot(percorcomsrcsub,'o');title(sub);legend({'%MotDirCor-ComSrc' '%MotDirCor-NotComSrc'});axis([-inf inf 0 1])

figure(5);subplot(1,length(subuse),ss);plot(percorcomsrccongsub,'o');title(sub);legend({'%MotDirCor-ComSrcCor-Cong' '%MotDirCor-ComSrcCor-Incong' '%MotDirCor-ComSrcInc-Cong' '%MotDirCor-ComSrcInc-Incong' });axis([-inf inf 0 1])

figure(6);subplot(1,length(subuse),ss);plot(comsrcMDisidursub,'o');title(sub);legend({'%ComSrcCor-MDcor-Cong' '%ComSrcCor-MDinc-Cong' '%ComSrcCor-MDcor-Incong' '%ComSrcCor-MDinc-Incong' });axis([-inf inf 0 1])

figure(7);subplot(1,length(subuse),ss);plot(motpercongisidursub,'o');title(sub);legend({'%Motion-Cong' '%Motion-Incong'});axis([-inf inf 0 1])

figure(8);subplot(1,length(subuse),ss);plot(motpercongdirisidursub,'o');title(sub);legend({'%Motion-Cong-MDcor' '%Motion-Cong-MDinc' '%Motion-Incong-MDcor' '%Motion-Incong-MDinc'});axis([-inf inf 0 1])

ss=ss+1;
end

%% For comparing different degrees (1-5) and dot size (0.2 to 1.5 deg)

close all
subuse=[30];
maxsub=max(subuse);

% motperav=-.1*ones(6,maxsub); % blocktype by participant
% flkperav=-.1*ones(6,maxsub); % blocktype by participant
% dstperav=-.1*ones(6,maxsub); % blocktype by participant
% 
% percoravc=-.1*ones(6,maxsub); % ISI by DUR by participant
% percoravi=-.1*ones(6,maxsub); % ISI by DUR by participant
% 
% comsrcC=-.1*ones(6,maxsub); % blocktype by participant
% comsrcI=-.1*ones(6,maxsub); % blocktype by participant
% 
% percoravcs1C=-.1*ones(6,maxsub); % blocktype by participant
% percoravcs0C=-.1*ones(6,maxsub); % blocktype by participant
% percoravcs1I=-.1*ones(6,maxsub); % blocktype by participant
% percoravcs0I=-.1*ones(6,maxsub); % blocktype by participant
% 
% comsrcCMDcor=-.1*ones(6,maxsub); % blocktype by participant
% comsrcCMDinc=-.1*ones(6,maxsub); % blocktype by participant
% comsrcIMDcor=-.1*ones(6,maxsub); % blocktype by participant
% comsrcIMDinc=-.1*ones(6,maxsub); % blocktype by participant

ss=1;
for ii=subuse
  if ii<10
    sub=['p0' num2str(ii)];
  else
    sub=['p' num2str(ii)];
  end
  
  avfile=dir([sub '_av*']);
  
  sep=[5 4 3 5 4 3 2 2 1 1 2 2];
  diam=[1 1 1 2 2 2 2 3 3 2 1 3];
  percorout1all=nan(max(sep),max(diam));
  percorout2all=nan(max(sep),max(diam));
  comsrc1all=nan(max(sep),max(diam));
  comsrc2all=nan(max(sep),max(diam));
  for ff=1:length(avfile)
    load(avfile(ff).name);
    appmot_assessment;
    percorout1all(sep(ff),diam(ff))=percorout(1);
    percorout2all(sep(ff),diam(ff))=percorout(2);
    comsrc1all(sep(ff),diam(ff))=comsrc(1);
    comsrc2all(sep(ff),diam(ff))=comsrc(2);
  end
  
end

%%  For 31-38, plotting results for all conditions

clearvars -except *dir
close all;
subuse=[31:38 100 1002 101 1001 102 104:111];

% threshold for % correct motion direction, collapsed over ComSrc response
nocuethresh=0.75;
cuethresh=[0.7 0.8];
finalthresh=1.5;
locthresh=10;

subind=0;

includesubj=nan(length(subuse),2);

for ii=subuse
  subind=subind+1;
  if ii>1000
    subpre='e';
    subnum=ii-1000;
  else
    subpre='p';
    subnum=ii;
  end
  if subnum<10
    sub=[subpre '0' num2str(subnum)];
  else
    sub=[subpre num2str(subnum)];
  end
  if ii>36 && ii<1000
    cd('D:\motion_cued\behav_data');
  elseif ii>1000
    cd('D:\motion_cued\behav_data');
  else
    cd('D:\motion_psychophysics\behav_data');
  end
  avfile=dir([sub '_av*']);
    
  % without cue
  cnt=0;
  clear *tmp
  for ff=1:length(avfile)
    load(avfile(ff).name);
    if strcmp(setup.paradigm,'cued')  % do blocks with cue separately
      continue
    end
    cnt=cnt+1;
    appmot_assessment;
    comsrc_tmp(cnt,:)=comsrcisidur; % congruent, incongruent, audalone (% common source correct)
    comsrcn_tmp(cnt,:)=comsrcisidur_numer; % congruent, incongruent, audalone (% common source correct)
    comsrcd_tmp(cnt,:)=comsrcisidur_denom; % congruent, incongruent, audalone (% common source correct)
    comsrcMD_tmp(cnt,:)=comsrcMDisidur; % cong-MDcor, cong-MDincor, incong-MDcor, incong-MDincor (% common source correct)
    comsrcMDn_tmp(cnt,:)=comsrcMDisidur_numer; % cong-MDcor, cong-MDincor, incong-MDcor, incong-MDincor (% common source correct)
    comsrcMDd_tmp(cnt,:)=comsrcMDisidur_denom; % cong-MDcor, cong-MDincor, incong-MDcor, incong-MDincor (% common source correct)
    
    percorcomsrccong_tmp(cnt,:)=percorcomsrccong; % Correct-Cong, Correct-Incong, Incorrect-Cong, Incorrect-Incong (% correct of motion direction)
    percorcomsrccongn_tmp(cnt,:)=percorcomsrccong_numer; % Correct-Cong, Correct-Incong, Incorrect-Cong, Incorrect-Incong (% correct of motion direction)
    percorcomsrccongd_tmp(cnt,:)=percorcomsrccong_denom; % Correct-Cong, Correct-Incong, Incorrect-Cong, Incorrect-Incong (% correct of motion direction)
  end
  
  percorcomsrccong_all(subind,:)=nansum(percorcomsrccongn_tmp)./nansum(percorcomsrccongd_tmp);
  percorcomsrccongN_all(subind,:)=nansum(percorcomsrccongd_tmp);
  comsrc_all(subind,:)=nansum(comsrcn_tmp)./nansum(comsrcd_tmp);
  comsrcN_all(subind,:)=nansum(comsrcd_tmp);
  comsrcMD_all(subind,:)=nansum(comsrcMDn_tmp)./nansum(comsrcMDd_tmp);
  comsrcMDN_all(subind,:)=nansum(comsrcMDd_tmp);
  
%   comsrc_all(subind,:)=nanmean(comsrc_tmp,1);
%   comsrcn_all(subind,:)=nanmean(comsrcn_tmp,1);
%   comsrcd_all(subind,:)=nanmean(comsrcd_tmp,1);
%   comsrcMD_all(subind,:)=nanmean(comsrcMD_tmp,1);
  
  % threshold for inclusion:
  includesubj(subind,1)=[nansum(percorcomsrccong_all(subind,[1 3]).*percorcomsrccongN_all(subind,[1 3]),2) ]./[nansum(percorcomsrccongN_all(subind,[1 3]),2)]>nocuethresh;
  avnocue_loc(subind)=max(stim.loc);  % using last of block

  
  % with cue
  cnt=0;
  clear *tmp
  for ff=1:length(avfile)
    load(avfile(ff).name);
    if strcmp(setup.paradigm,'nocue')  % do blocks without cue separately
      continue
    end
    cnt=cnt+1;
    appmot_assessment;
    percorcomsrccong_percue_tmp(cnt,:,:)=percorcomsrccong_percue;
    percorcomsrccong_percue_numer_tmp(cnt,:,:)=percorcomsrccong_percue_numer;
    percorcomsrccong_percue_denom_tmp(cnt,:,:)=percorcomsrccong_percue_denom;
    comsrcMD_percue_tmp(cnt,:,:)=comsrcMDisidur_percue;
    comsrcMD_percue_numer_tmp(cnt,:,:)=comsrcMDisidur_percue_numer;
    comsrcMD_percue_denom_tmp(cnt,:,:)=comsrcMDisidur_percue_denom;
  end
  avcued_loc(subind)=max(stim.loc);  % using last of block
  if cnt>0
    percorcomsrccong_percue_all(subind,:,:)=squeeze(nansum(percorcomsrccong_percue_numer_tmp,1)./nansum(percorcomsrccong_percue_denom_tmp,1));
    percorcomsrccong_percueN_all(subind,:,:)=squeeze(nansum(percorcomsrccong_percue_denom_tmp,1));
    comsrcMD_percue_all(subind,:,:)=squeeze(nansum(comsrcMD_percue_numer_tmp,1)./nansum(comsrcMD_percue_denom_tmp,1));
    comsrcMD_percueN_all(subind,:,:)=squeeze(nansum(comsrcMD_percue_denom_tmp,1));
    
    %  moddir-correct, collapsed over ComSrc answer
    corMD_percue_all(subind,:,1)=nansum(nansum(percorcomsrccong_percue_numer_tmp(:,:,[1 3]),3),1)./nansum(nansum(percorcomsrccong_percue_denom_tmp(:,:,[1 3]),3),1);
    corMD_percueN_all(subind,:,1)=nansum(nansum(percorcomsrccong_percue_denom_tmp(:,:,[1 3]),3),1);
    corMD_percue_all(subind,:,2)=nansum(nansum(percorcomsrccong_percue_numer_tmp(:,:,[2 4]),3),1)./nansum(nansum(percorcomsrccong_percue_denom_tmp(:,:,[2 4]),3),1);
    corMD_percueN_all(subind,:,2)=nansum(nansum(percorcomsrccong_percue_denom_tmp(:,:,[2 4]),3),1);
    
    corCS_percue_all(subind,:,1)=nansum(nansum(comsrcMD_percue_numer_tmp(:,:,[1 2]),3),1)./nansum(nansum(comsrcMD_percue_denom_tmp(:,:,[1 2]),3),1);
    corCS_percueN_all(subind,:,1)=nansum(nansum(comsrcMD_percue_denom_tmp(:,:,[1 2]),3),1);
    corCS_percue_all(subind,:,2)=nansum(nansum(comsrcMD_percue_numer_tmp(:,:,[3 4]),3),1)./nansum(nansum(comsrcMD_percue_denom_tmp(:,:,[3 4]),3),1);
    corCS_percueN_all(subind,:,2)=nansum(nansum(comsrcMD_percue_denom_tmp(:,:,[3 4]),3),1);
    
    includesubj(subind,2)=mean(corMD_percue_all(subind,:,1)>cuethresh);
  else
    percorcomsrccong_percue_all(subind,:,:)=nan(2,4);
    percorcomsrccong_percueN_all(subind,:,:)=nan(2,4);
    comsrcMD_percue_all(subind,:,:)=nan(2,4);
    comsrcMD_percueN_all(subind,:,:)=nan(2,4);

    corMD_percue_all(subind,:,:)=nan(2,2);
    corMD_percueN_all(subind,:,:)=nan(2,2);
    corCS_percue_all(subind,:,:)=nan(2,2);
    corCS_percueN_all(subind,:,:)=nan(2,2);
    
    includesubj(subind,2)=nan;
  end
  
end

% order of columns in percorcomsrccong_all is less intuitive.  reorder.
tmp=percorcomsrccong_all(:,[1 3 2 4]);
percorcomsrccong_all=tmp;
tmp=percorcomsrccongN_all(:,[1 3 2 4]);
percorcomsrccongN_all=tmp;
tmp=percorcomsrccong_percue_all(:,:,[1 3 2 4]);
percorcomsrccong_percue_all=tmp;
tmp=percorcomsrccong_percueN_all(:,:,[1 3 2 4]);
percorcomsrccong_percueN_all=tmp;

% create normalised percentage of trial numbers per participant
percorcomsrccongN_all_norm=percorcomsrccongN_all./repmat(sum(percorcomsrccongN_all,2),[1 4]);
percorcomsrccong_percueN_all_norm=percorcomsrccong_percueN_all./repmat(sum(sum(percorcomsrccong_percueN_all,2),3),[1 2 4]);
corMD_percueN_all_norm=corMD_percueN_all./repmat(sum(sum(corMD_percueN_all,2),3),[1 2 2]);
comsrcMDN_all_norm=comsrcMDN_all./repmat(sum(comsrcMDN_all,2),[1 4]);
comsrcMD_percueN_all_norm=comsrcMD_percueN_all./repmat(sum(sum(comsrcMD_percueN_all,2),3),[1 2 4]);
corCS_percueN_all_norm=corCS_percueN_all./repmat(sum(sum(corCS_percueN_all,2),3),[1 2 2]);


corMD_all=[nansum(percorcomsrccong_all(:,1:2).*percorcomsrccongN_all(:,1:2),2) nansum(percorcomsrccong_all(:,3:4).*percorcomsrccongN_all(:,3:4),2)]./[nansum(percorcomsrccongN_all(:,1:2),2) nansum(percorcomsrccongN_all(:,3:4),2)];
corMDN_all=[nansum(percorcomsrccongN_all(:,1:2),2) nansum(percorcomsrccongN_all(:,3:4),2)]./repmat(nansum([nansum(percorcomsrccongN_all(:,1:2),2) nansum(percorcomsrccongN_all(:,3:4),2)],2),[1 2]);

corCS_all=[nansum(comsrcMD_all(:,1:2).*comsrcMDN_all_norm(:,1:2),2) nansum(comsrcMD_all(:,3:4).*comsrcMDN_all_norm(:,3:4),2)]./[nansum(comsrcMDN_all_norm(:,1:2),2) nansum(comsrcMDN_all_norm(:,3:4),2)];
corCSN_all=[nansum(comsrcMDN_all_norm(:,1:2),2) nansum(comsrcMDN_all_norm(:,3:4),2)]./repmat(nansum([nansum(comsrcMDN_all_norm(:,1:2),2) nansum(comsrcMDN_all_norm(:,3:4),2)],2),[1 2]);

close all
figind=1;

figure(figind);figind=figind+1;
subplot(2,1,1);bar(corMD_all');ylabel('% correct of motion direction');xlabel('Cong, Incong');axis([-inf inf 0 1]);
subplot(2,1,2);bar(corMDN_all');ylabel('% of trials');axis([-inf inf 0 0.55]);

figure(figind);figind=figind+1;
subplot(2,1,1);bar(corCS_all');ylabel('% common source correct');xlabel('Cong, Incong');axis([-inf inf 0 1]);
% subplot(2,1,1);bar([corCS_all(:,1) 1-corCS_all(:,2)]');ylabel('% Common Source Yes');xlabel('Cong, Incong');axis([-inf inf 0 1]);
subplot(2,1,2);bar(corCSN_all');ylabel('% of trials');axis([-inf inf 0 0.55]);
figure(figind);figind=figind+1;
% subplot(2,1,1);bar(corCS_all');ylabel('% common source correct');xlabel('Cong, Incong');axis([-inf inf 0 1]);
subplot(2,1,1);bar([corCS_all(:,1) 1-corCS_all(:,2)]');ylabel('% Common Source Yes');xlabel('Cong, Incong');axis([-inf inf 0 1]);
subplot(2,1,2);bar(corCSN_all');ylabel('% of trials');axis([-inf inf 0 0.55]);

figure(figind);figind=figind+1;
% subplot(2,1,1);bar(percorcomsrccong_all');ylabel('% correct of motion direction');xlabel('Cong-CScor, Cong-CSincor, Incong-CScor, Incong-CSincor');axis([-inf inf 0 1]);
subplot(2,1,1);bar(percorcomsrccong_all');ylabel('% correct of motion direction');xlabel('Cong-CSyes, Cong-CSno, Incong-CSno, Incong-CSyes');axis([-inf inf 0 1]);
subplot(2,1,2);bar(percorcomsrccongN_all_norm');ylabel('% of trials');axis([-inf inf 0 0.5]);

figure(figind);figind=figind+1;
subplot(2,1,1);bar(comsrcMD_all');ylabel('% common source correct');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);
% subplot(2,1,1);bar([comsrcMD_all(:,1:2) 1-comsrcMD_all(:,3:4)]');ylabel('% common source Yes');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);
subplot(2,1,2);bar(comsrcMDN_all_norm');ylabel('% of trials');axis([-inf inf 0 0.5]);
figure(figind);figind=figind+1;
% subplot(2,1,1);bar(comsrcMD_all');ylabel('% common source correct');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);
subplot(2,1,1);bar([comsrcMD_all(:,1:2) 1-comsrcMD_all(:,3:4)]');ylabel('% common source Yes');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);
subplot(2,1,2);bar(comsrcMDN_all_norm');ylabel('% of trials');axis([-inf inf 0 0.5]);


maxy=ceil(100*max(max(corMD_percueN_all_norm(:)),max(corCS_percueN_all_norm(:)))/5)*5/100;

figure(figind);figind=figind+1;
subplot(2,2,1);bar(squeeze(corMD_percue_all(:,1,:))');ylabel('% correct of motion direction');xlabel('Cong, Incong');axis([-inf inf 0 1]);title('Low cong. prob. cue')
subplot(2,2,2);bar(squeeze(corMD_percue_all(:,2,:))');ylabel('% correct of motion direction');xlabel('Cong, Incong');axis([-inf inf 0 1]);title('High cong. prob. cue')
subplot(2,2,3);bar(squeeze(corMD_percueN_all_norm(:,1,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);
subplot(2,2,4);bar(squeeze(corMD_percueN_all_norm(:,2,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);

figure(figind);figind=figind+1;
subplot(2,2,1);bar(squeeze(corCS_percue_all(:,1,:))');ylabel('% common source correct');xlabel('Cong, Incong');axis([-inf inf 0 1]);title('Low cong. prob. cue')
subplot(2,2,2);bar(squeeze(corCS_percue_all(:,2,:))');ylabel('% common source correct');xlabel('Cong, Incong');axis([-inf inf 0 1]);title('High cong. prob. cue')
% subplot(2,2,1);bar([squeeze(corCS_percue_all(:,1,1)) 1-squeeze(corCS_percue_all(:,1,2))]');ylabel('% common source Yes');xlabel('Cong, Incong');axis([-inf inf 0 1]);title('Low cong. prob. cue')
% subplot(2,2,2);bar([squeeze(corCS_percue_all(:,2,1)) 1-squeeze(corCS_percue_all(:,2,2))]');ylabel('% common source Yes');xlabel('Cong, Incong');axis([-inf inf 0 1]);title('High cong. prob. cue')
subplot(2,2,3);bar(squeeze(corCS_percueN_all_norm(:,1,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);
subplot(2,2,4);bar(squeeze(corCS_percueN_all_norm(:,2,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);
figure(figind);figind=figind+1;
% subplot(2,2,1);bar(squeeze(corCS_percue_all(:,1,:))');ylabel('% common source correct');xlabel('Cong, Incong');axis([-inf inf 0 1]);title('Low cong. prob. cue')
% subplot(2,2,2);bar(squeeze(corCS_percue_all(:,2,:))');ylabel('% common source correct');xlabel('Cong, Incong');axis([-inf inf 0 1]);title('High cong. prob. cue')
subplot(2,2,1);bar([squeeze(corCS_percue_all(:,1,1)) 1-squeeze(corCS_percue_all(:,1,2))]');ylabel('% common source Yes');xlabel('Cong, Incong');axis([-inf inf 0 1]);title('Low cong. prob. cue')
subplot(2,2,2);bar([squeeze(corCS_percue_all(:,2,1)) 1-squeeze(corCS_percue_all(:,2,2))]');ylabel('% common source Yes');xlabel('Cong, Incong');axis([-inf inf 0 1]);title('High cong. prob. cue')
subplot(2,2,3);bar(squeeze(corCS_percueN_all_norm(:,1,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);
subplot(2,2,4);bar(squeeze(corCS_percueN_all_norm(:,2,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);

maxy=ceil(100*max(max(percorcomsrccong_percueN_all_norm(:)),max(comsrcMD_percueN_all_norm(:)))/5)*5/100;

figure(figind);figind=figind+1;
% subplot(2,2,1);bar(squeeze(percorcomsrccong_percue_all(:,1,:))');ylabel('% correct of motion direction');xlabel('Cong-CScor, Cong-CSincor, Incong-CScor, Incong-CSincor');axis([-inf inf 0 1]);title('Low cong. prob. cue')
% subplot(2,2,2);bar(squeeze(percorcomsrccong_percue_all(:,2,:))');ylabel('% correct of motion direction');xlabel('Cong-CScor, Cong-CSincor, Incong-CScor, Incong-CSincor');axis([-inf inf 0 1]);title('High cong. prob. cue')
subplot(2,2,1);bar(squeeze(percorcomsrccong_percue_all(:,1,:))');ylabel('% correct of motion direction');xlabel('Cong-CSyes, Cong-CSno, Incong-CSno, Incong-CSyes');axis([-inf inf 0 1]);title('Low cong. prob. cue')
subplot(2,2,2);bar(squeeze(percorcomsrccong_percue_all(:,2,:))');ylabel('% correct of motion direction');xlabel('Cong-CSyes, Cong-CSno, Incong-CSno, Incong-CSyes');axis([-inf inf 0 1]);title('High cong. prob. cue')
subplot(2,2,3);bar(squeeze(percorcomsrccong_percueN_all_norm(:,1,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);
subplot(2,2,4);bar(squeeze(percorcomsrccong_percueN_all_norm(:,2,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);

figure(figind);figind=figind+1;
subplot(2,2,1);bar(squeeze(comsrcMD_percue_all(:,1,:))');ylabel('% common source correct');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);title('Low cong. prob. cue')
subplot(2,2,2);bar(squeeze(comsrcMD_percue_all(:,2,:))');ylabel('% common source correct');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);title('High cong. prob. cue')
% subplot(2,2,1);bar([squeeze(comsrcMD_percue_all(:,1,1:2)) 1-squeeze(comsrcMD_percue_all(:,1,3:4))]');ylabel('% common source Yes');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);title('Low cong. prob. cue')
% subplot(2,2,2);bar([squeeze(comsrcMD_percue_all(:,2,1:2)) 1-squeeze(comsrcMD_percue_all(:,2,3:4))]');ylabel('% common source Yes');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);title('High cong. prob. cue')
subplot(2,2,3);bar(squeeze(comsrcMD_percueN_all_norm(:,1,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);
subplot(2,2,4);bar(squeeze(comsrcMD_percueN_all_norm(:,2,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);
figure(figind);figind=figind+1;
% subplot(2,2,1);bar(squeeze(comsrcMD_percue_all(:,1,:))');ylabel('% common source correct');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);title('Low cong. prob. cue')
% subplot(2,2,2);bar(squeeze(comsrcMD_percue_all(:,2,:))');ylabel('% common source correct');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);title('High cong. prob. cue')
subplot(2,2,1);bar([squeeze(comsrcMD_percue_all(:,1,1:2)) 1-squeeze(comsrcMD_percue_all(:,1,3:4))]');ylabel('% common source Yes');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);title('Low cong. prob. cue')
subplot(2,2,2);bar([squeeze(comsrcMD_percue_all(:,2,1:2)) 1-squeeze(comsrcMD_percue_all(:,2,3:4))]');ylabel('% common source Yes');xlabel('Cong-MDcor, Cong-MDincor, Incong-MDcor, Incong-MDincor');axis([-inf inf 0 1]);title('High cong. prob. cue')
subplot(2,2,3);bar(squeeze(comsrcMD_percueN_all_norm(:,1,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);
subplot(2,2,4);bar(squeeze(comsrcMD_percueN_all_norm(:,2,:))');ylabel('% of trials');axis([-inf inf 0 maxy]);

% percorcomsrccong_avg=nansum(percorcomsrccong_all.*percorcomsrccongN_all,1)./nansum(percorcomsrccongN_all,1);

% % % Stats
%                 column1 - dependent variable
%                 column2 - grouping variable for subject
%                 column3 - grouping variable for factor 1
%                 column4 - grouping variable for factor 2
nsub=size(corMD_percue_all(7:end,:,:),1);
data(:,1)=reshape(corMD_percue_all(7:end,:,:),[nsub*2*2 1]);
data(:,2)=[1:nsub 1:nsub 1:nsub 1:nsub];
data(:,3)=[ones(nsub*2,1); 2*ones(nsub*2,1)]; % congruency
data(:,4)=[ones(nsub,1); 2*ones(nsub,1); ones(nsub,1); 2*ones(nsub,1)]; % cue
stats = rmanova2(data,.05,0,1)
% data(:,1)=reshape(corMD_percueN_all(7:end,:,:),[nsub*2*2 1]);
% stats = rmanova2(data,.05,0,1)
data(:,1)=reshape(corCS_percue_all(7:end,:,:),[nsub*2*2 1]);
stats = rmanova2(data,.05,0,1)
tmp=[squeeze(corCS_percue_all(:,:,1)) 1-squeeze(corCS_percue_all(:,:,2))];
data(:,1)=reshape(tmp(7:end,:,:),[nsub*2*2 1]);
stats = rmanova2(data,.05,0,1)


% Three-way RM anova (congruency, cue, comsrc-cor)
% Following: http://uk.mathworks.com/matlabcentral/answers/140799-3-way-repeated-measures-anova-pairwise-comparisons-using-multcompare
percormotdir=reshape(percorcomsrccong_percue_all(end-nsub+1:end,:,:),[nsub 8]);
varNames = {'LC_Con_CSyes','HC_Con_CSyes','LC_Con_CSno','HC_Con_CSno','LC_Inc_CSno','HC_Inc_CSno','LC_Inc_CSyes','HC_Inc_CSyes'};
t = array2table(percormotdir,'VariableNames',varNames);
factorNames = {'Cue','Congruency','ComSrcResp'};
within = table({'L';'H';'L';'H';'L';'H';'L';'H'},{'C';'C';'C';'C';'I';'I';'I';'I'},{'Y';'Y';'N';'N';'Y';'Y';'N';'N'},'VariableNames',factorNames);
rm = fitrm(t,'LC_Con_CSyes-HC_Inc_CSyes~1','WithinDesign',within);
[ranovatbl] = ranova(rm, 'WithinModel','Cue*Congruency*ComSrcResp')

percormotdir=reshape(percorcomsrccong_percueN_all(end-nsub+1:end,:,:),[nsub 8]);
t = array2table(percormotdir,'VariableNames',varNames);
rm = fitrm(t,'LC_Con_CSyes-HC_Inc_CSyes~1','WithinDesign',within);
[ranovatbl] = ranova(rm, 'WithinModel','Cue*Congruency*ComSrcResp')

% which participants to invite back for EEG
subuse(sum(includesubj,2)>=finalthresh & avcued_loc'<=locthresh)
subuse(sum(includesubj,2)>=finalthresh & avcued_loc'<=locthresh & corMD_percue_all(:,1,2)-corMD_percue_all(:,2,2)>.1)


