function appmot_behindproc(filenames)

aa=0;av=0;vv=0;
for ff=1:length(filenames)
  tmp=load(filenames(ff).name);
  tmp1.setup=tmp.setup;
  tmp1.stim=tmp.stim;
  tmp1.resp=tmp.resp;
  switch tmp.stim.block
    case 'audonly'
      aa=aa+1;
      datao(aa)=tmp1;
    case 'visonly'
      vv=vv+1;
      datvo(vv)=tmp1;
    case 'av'
      av=av+1;
      datav(av)=tmp1;
  end
end

% combine sessions of same params
dattest={'datao' 'datvo' 'datav'};

for dd=1:length(dattest)
  datuse=eval(dattest{dd});
  combind=[];
  respall{dd}.motperkeycode=[];
  respall{dd}.motdirkeycode=[];
  respall{dd}.comsrckeycode=[];
  respall{dd}.cormotdir=[];
  respall{dd}.durseq=[];
  respall{dd}.isiseq=[];
  for ff=1:length(datuse)-1
    for ee=ff+1:length(datuse)
      combflag=1;
      combflag=combflag && isequal(datuse(ff).setup.paradigm,datuse(ee).setup.paradigm);
      combflag=combflag && isequal(datuse(ff).stim.loc,datuse(ee).stim.loc);
      switch datuse(ff).setup.paradigm
        case 'cued'
          combflag=combflag && isequal(datuse(ff).stim.cueprob,datuse(ee).stim.cueprob);
          combflag=combflag && isequal(datuse(ff).stim.cueaudonly,datuse(ee).stim.cueaudonly);
      end
      if combflag
        if ~any(combind==ff)
          combind=[combind ff];
          respall{dd}.motperkeycode=[respall{dd}.motperkeycode datuse(ff).resp.motperkeycode];
          respall{dd}.motdirkeycode=[respall{dd}.motdirkeycode datuse(ff).resp.motdirkeycode];
          respall{dd}.comsrckeycode=[respall{dd}.comsrckeycode datuse(ff).resp.comsrckeycode];
          respall{dd}.cormotdir    =[respall{dd}.cormotdir     datuse(ff).resp.cormotdir];
          respall{dd}.durseq       =[respall{dd}.durseq        datuse(ff).stim.durseq];
          respall{dd}.isiseq       =[respall{dd}.isiseq        datuse(ff).stim.isiseq];
        end
        if ~any(combind==ee)
          combind=[combind ee];
          respall{dd}.motperkeycode=[respall{dd}.motperkeycode datuse(ff).resp.motperkeycode];
          respall{dd}.motdirkeycode=[respall{dd}.motdirkeycode datuse(ff).resp.motdirkeycode];
          respall{dd}.comsrckeycode=[respall{dd}.comsrckeycode datuse(ff).resp.comsrckeycode];
          respall{dd}.cormotdir    =[respall{dd}.cormotdir     datuse(ff).resp.cormotdir];
          respall{dd}.durseq       =[respall{dd}.durseq        datuse(ff).stim.durseq];
          respall{dd}.isiseq       =[respall{dd}.isiseq        datuse(ff).stim.isiseq];
        end
      end
    end
  end
  
  if isempty(respall{dd}.motdirkeycode)
    ff=input(['Which dataset of ' dattest{dd} ' out of ' num2str(length(datuse)) ' datasets do you want to use?  ']);
    respall{dd}.motperkeycode=[respall{dd}.motperkeycode datuse(ff).resp.motperkeycode];
    respall{dd}.motdirkeycode=[respall{dd}.motdirkeycode datuse(ff).resp.motdirkeycode];
    respall{dd}.comsrckeycode=[respall{dd}.comsrckeycode datuse(ff).resp.comsrckeycode];
    respall{dd}.cormotdir    =[respall{dd}.cormotdir     datuse(ff).resp.cormotdir];
    respall{dd}.durseq       =[respall{dd}.durseq        datuse(ff).stim.durseq];
    respall{dd}.isiseq       =[respall{dd}.isiseq        datuse(ff).stim.isiseq];
  end
end


