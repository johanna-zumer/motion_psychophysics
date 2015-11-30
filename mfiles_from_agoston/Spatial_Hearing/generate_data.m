function [data, UD] = generate_data(runtype, stim, varargin) 

if ismember(runtype, {'A' 'V'})
    % Preallocate dataset array
    data = dataset;
    
    % Number of stimulus locations
    nlocs = length(stim.loc);
    
    % Generate V data
    if strfind(runtype, 'V')
        ntrials = nlocs * stim.visual.nreps;
        vdata = dataset;
        [vdata.resp, vdata.RT, vdata.aloc] = deal(NaN(ntrials, 1));
        vdata.vloc = pseudorand(stim, 'visual');
        vdata.blocktype = repmat('V', ntrials, 1);
        vdata.rec = NaN(ntrials, 1);
        data = [data; vdata];
    end
    
    % Generate A data
    if strfind(runtype, 'A')
        ntrials = nlocs * stim.audio.nreps;
        nrecs = length(stim.(stim.audio.type).id);
        adata = dataset;
        [adata.resp, adata.RT] = deal(NaN(ntrials, 1));
        adata.aloc = pseudorand(stim, 'audio');
        adata.vloc = NaN(ntrials, 1);
        adata.blocktype = repmat('A', ntrials, 1);
        adata.rec = zeros(ntrials, 1);
        for i=1:nlocs
            adata.rec(adata.aloc==stim.loc(i)) = mod(randperm(stim.audio.nreps), nrecs) + 1;
        end
        data = [data; adata];
    end
    
elseif strcmp(runtype, 'P')
    % Assign input parameters
    [trialtype, PAL] = varargin{:};
    
    % Interleave blocks if needed
    ntrialtypes = sum(~isnan(trialtype));
    if ntrialtypes == 1
        error('There should be at least 2 trialtypes (one for left and one for right side stimuli)')
    else
        [Y, index] = Shuffle(zeros(ntrialtypes, stim.nreps));
        idtrialtype = find(~isnan(trialtype));
        idtrialtype = idtrialtype(index(:));
    end
    
    % Factors and factorial data
    fact.vars = {1:length(stim.(stim.audio.type).id)}; % we define only the side of aloc
    fact.nconds = prod(cellfun(@length, fact.vars));
    fact.data = cell(size(fact.vars));
    [fact.data{:}] = ndgrid(fact.vars{:});
    
    % Block data
    ntrials = ntrialtypes * stim.nreps;
    data = zeros(ntrials, 3); % aloc, rec, trialtype
    for i=1:length(trialtype)
        if isnan(trialtype(i))
            continue
        else
            nreps = stim.nreps / fact.nconds;
            if mod(nreps, 1)
                error('Number of block trials is not a multiple of conditions.')
            end
            tempdata = repmat(cell2mat(cellfun(@(x) reshape(x, fact.nconds, 1), fact.data, 'UniformOutput', false)), nreps, 1);
            tempdata = tempdata(randperm(stim.nreps),:);
            switch i
                case 1
                    tempdata = [repmat(-1, stim.nreps, 1) tempdata]; % left
                case 2
                    tempdata = [repmat(-stim.azimuth, stim.nreps, 1) tempdata]; % left center
                case 3
                    tempdata = [repmat(stim.azimuth, stim.nreps, 1) tempdata]; % right center
                case 4
                    tempdata = [ones(stim.nreps, 1) tempdata]; % right
            end
            data(idtrialtype==i,:) = [tempdata repmat(trialtype(i), stim.nreps, 1)];
        end
    end
    
    % Create dataset array
    data = dataset({data, 'aloc', 'recid', 'trialtype'});
    data.blocktype = repmat('P', ntrials, 1);
    [data.vloc, data.resp, data.RT] = deal(NaN(ntrials, 1));
    data = data(:,[6 7 1 5 3 4 2]); % rearrange coloumns
    
    % Initialize palamedes
    if ~isfield(PAL, 'start')
        PAL.start.value = max(stim.loc); % default start value
    end
    UD = cell(1, max(trialtype(:)));
    for i=1:max(trialtype(:))
        if strcmp(PAL.method, 'weighted') % 3/2 weighted up down method (targets 60%)
            UD{i} = PAL_AMUD_setupUD_Ago('up', 1, 'down', 1, 'stepSizeDown', 1, 'stepSizeUp', 1.5, 'xMax', max(stim.loc), 'xMin', 0.5, ...
                'truncate', 'yes', 'stopCriterion', PAL.stop.criterion, 'stopRule', PAL.stop.rule, 'stopMin', PAL.stop.min, 'startValue', PAL.start.value);
        elseif strcmp(PAL.method, 'transformed') % 1 up/2 down method (targets 70%)
            UD{i} = PAL_AMUD_setupUD_Ago('up', 1, 'down', 2, 'stepSizeDown', 1, 'stepSizeUp', 1, 'xMax', max(stim.loc), 'xMin', 0.5, ...
                'truncate', 'yes', 'stopCriterion', PAL.stop.criterion, 'stopRule', PAL.stop.rule, 'stopMin', PAL.stop.min, 'startValue', PAL.start.value);
        end
        UD{i}.targetp = (UD{i}.stepSizeUp / (UD{i}.stepSizeUp + UD{i}.stepSizeDown)) ^ (1 / UD{i}.down); % target proportion correct
    end
end

end

function loc = pseudorand(stim, modality)
% Generate stimulus locations until max 3 stimuli are on the same side

nlocs = length(stim.loc);
loc = zeros(nlocs*stim.(modality).nreps, 1);
for r=1:stim.(modality).nreps
    while 1
        loc((1:nlocs)+(r-1)*nlocs,1) = stim.loc(randperm(nlocs));
        if r == 1
            chunk = loc((1:nlocs)+(r-1)*nlocs,1); % first randomization block
        else
            chunk = loc((1:nlocs*2)+(r-2)*nlocs,1); % handle overlap between randomization blocks
        end
        for k=1:2
            id = strfind([(chunk > 0) + 1]', repmat(k, 1, 4)); % resample when 4 sequential stimuli occur
            if ~isempty(id)
                break
            end
        end
        if isempty(id)
            break
        end
    end
end

end

