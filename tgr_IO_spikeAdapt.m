function IO_spikeAdapt = tgr_IO_spikeAdapt(all_cells,Inputparameter,show_single_epis)

if nargin<1
    [fname pname] = uigetfile('','Select preloaded Cell data.');
    all_cells = load([pname fname]);
    token = fieldnames(all_cells);
    if length(token)~=1
        disp('Too many input variables in cell-file!')
    else
        all_cells = all_cells.(token{1});
    end
end

% if nargin<2
%     [fname pname] = uigetfile('','Select preloaded info data.');
%     Inputparameter = load([pname fname]);
%     token = fieldnames(Inputparameter);
%     if length(token)~=1
%         disp('Too many input variables in cell-file!')
%     else
%         Inputparameter = Inputparameter.(token{1});
%     end
% end

if nargin<3
    show_single_epis = 'yes';
end

% if length(Inputparameter) ~= length(all_cells)
%     disp('Dimension mismatch of cell and info inputs');
% end

%%% If no Inputparameter{i} are defined, these pre-sets are used. If fields
%%% are empty, the empty values are replaced.
Inputpreset.Fs = 20000;
Inputpreset.Ms = Inputpreset.Fs/1000;
Inputpreset.show_single_epis='yes';
Inputpreset.show_average_section ='yes';
Inputpreset.AP_slope_threshold = 12;
Inputpreset.AP_spike_threshold = [12 5];
Inputpreset.sAHPbaseEnd = 180*Inputpreset.Ms;
Inputpreset.sAHPstart = 1200*Inputpreset.Ms;
Inputpreset.sAHPend = 1600*Inputpreset.Ms;
Inputpreset.IO_start = 201*Inputpreset.Ms;
Inputpreset.IO_end = 1200*Inputpreset.Ms;
Inputpreset.IOsteps = -100:50:600;
Inputpreset.expName = 'defaultExperiment';
Inputpreset.celltype = [];

IO_spikeAdapt = cell(1,length(all_cells));

%%% start of Analysis
for i = 1:size(all_cells,2)
    if nargin<2
        Inputparameter{i} = Inputpreset;
    end
    if ~isfield(Inputparameter{i},'Fs')
        Inputparameter{i}.Fs = Inputpreset.Fs;
    end
    if ~isfield(Inputparameter{i},'Ms')
        Inputparameter{i}.Ms = Inputpreset.Ms;
    end
    if ~isfield(Inputparameter{i},'show_single_epis')
        Inputparameter{i}.show_single_epis = Inputpreset.show_single_epis;
    end
    if ~isfield(Inputparameter{i},'show_average_section')
        Inputparameter{i}.show_average_section = Inputpreset.show_average_section;
    end
    if ~isfield(Inputparameter{i},'AP_slope_threshold')
        Inputparameter{i}.AP_slope_threshold = Inputpreset.AP_slope_threshold;
    end
    if ~isfield(Inputparameter{i},'AP_spike_threshold')
        Inputparameter{i}.AP_spike_threshold = Inputpreset.AP_spike_threshold;
    end
    if ~isfield(Inputparameter{i},'sAHPbaseEnd')
        Inputparameter{i}.sAHPbaseEnd = Inputpreset.sAHPbaseEnd;
    end
    if ~isfield(Inputparameter{i},'sAHPstart')
        Inputparameter{i}.sAHPstart = Inputpreset.sAHPstart;
    end
    if ~isfield(Inputparameter{i},'sAHPend')
        Inputparameter{i}.sAHPend = Inputpreset.sAHPend;
    end
    if ~isfield(Inputparameter{i},'IO_start')
        Inputparameter{i}.IO_start = Inputpreset.IO_start;
    end
    if ~isfield(Inputparameter{i},'IO_end')
        Inputparameter{i}.IO_end = Inputpreset.IO_end;
    end
    if ~isfield(Inputparameter{i},'IOsteps')
        Inputparameter{i}.IOsteps = Inputpreset.IOsteps;
    end
    if ~isfield(Inputparameter{i},'expName')
        Inputparameter{i}.expName = Inputpreset.expName;
    end
    if ~isfield(Inputparameter{i},'state')
        Inputparameter{i}.state = [];
    end
    if ~isfield(Inputparameter{i},'celltype')
        Inputparameter{i}.celltype = [];
    end
    
    % Savitzky-Golay filter
    smoothwinL = 0.8;     % (ms)
    order = 1;
    binwidth = ceil(smoothwinL/1000*Inputparameter{i}.Fs);
    if mod(binwidth,2) == 0
        [~,g] = sgolay(order,binwidth-1);
    else
        [~,g] = sgolay(order,binwidth);
    end
    lg = size(g(:,2),1);
    extrabins = floor(lg/2); % delay caused by filtering, in bins

    %%% Loop through each data_Section that was found in the given file. The number of
    %%% data_Sections should correspond to the number of current
    %%% steps used
    if isempty(Inputparameter{i}.state)
        trials = 1:size(all_cells{i}.dS,2);
        dS = all_cells{i}.dS(:,trials);
        timebases = all_cells{i}.timebases(:,trials);
    else
        dS = all_cells{i}.dS(:,Inputparameter{i}.state{4});
        timebases = all_cells{i}.timebases(:,Inputparameter{i}.state{4});
    end
    for trial = 1:size(dS,2)
        clear time_AP_max AP_max_time time_AP_count time_AP_max_Vm time_AP_end_Vm raster AP_max mAHPbin sAHPbin
        slope = diff(dS(:,trial));
        sgSlope = filter(g(:,1),1,slope); % Savitzgy Golay filter
        sgSlope =[sgSlope(extrabins:end); sgSlope(end)*ones(extrabins-1,1)];
        Slope = [sgSlope*Inputparameter{i}.Ms; sgSlope(end)*Inputparameter{i}.Ms;];
        BaseVm = mean(dS(1:Inputparameter{i}.sAHPbaseEnd,trial));
        sAHPbin = find(dS(Inputparameter{i}.sAHPstart:Inputparameter{i}.sAHPend,trial) == min(dS(Inputparameter{i}.sAHPstart:Inputparameter{i}.sAHPend,trial)),1) + Inputparameter{i}.sAHPstart-1;
        sAHPVm = mean(dS(sAHPbin-10:sAHPbin+10,trial)); % min(dS(Inputparameter{i}.sAHPstart:Inputparameter{i}.sAHPend,trial));
        sAHP = sAHPVm-BaseVm;
        IOsteps(trial) = trial*50;
        if isfield(Inputparameter{i},'basic_properties')
            akeStep(trial) = trial*50/Inputparameter{i}.basic_properties{i}.Cm;
        else
            akeStep(trial) = 0;
        end
            %%% detect all APs
        lbin = Inputparameter{i}.IO_end;
        ab = Inputparameter{i}.IO_start;
        count1=0;
        while ab<lbin
            if sum(Slope(ab:lbin)>Inputparameter{i}.AP_spike_threshold(1))
                ab = find(Slope(ab:lbin)>Inputparameter{i}.AP_spike_threshold(1), 1 ) + ab-1;
                AP_max = max(Slope(ab:ab+20));
                AP_max_time = min(find(Slope(ab:ab+20) == AP_max) + ab-1);
                AP_max_Vm = max(dS(ab:ab+200,trial));
                AP_max_Vm_time = min(find(dS(ab:ab+200,trial) == AP_max_Vm) + ab-1);
                AP_end_Vm_time = min(find(dS(ab:ab+200,trial) <= Inputparameter{i}.AP_spike_threshold(1)) + ab-1);
                if sum(dS(AP_max_time-5:AP_max_time+34,trial) > Inputparameter{i}.AP_spike_threshold(2))
                    count1 = count1 + 1;
                    time_AP_max(count1) = AP_max_time;
                    time_AP_15(count1) = ab;
                    AP_threshold{count1,trial} = dS(ab,trial);
                    APs{count1,trial} =  dS(ab-49:ab+200,trial);
                    time_AP_max_Vm(count1) = AP_max_Vm_time;
                    try
                        time_AP_end_Vm(count1) = AP_end_Vm_time;
                    end
                end
                ab = AP_max_time+50;
            else
                ab = lbin;
            end
        end
        if count1 == 0
            raster = NaN;
            time_AP_max = NaN;
            time_AP_15 = NaN;
            time_AP_max_Vm = NaN;
            AP_max_Vm = NaN;
            AP_max_Vm_time = NaN;
            time_AP_max_Vm = NaN;
            time_AP_end_Vm = NaN;
            AP_threshold{trial} = NaN;
            mAHP{trial} = NaN;
        else
            raster = time_AP_max/Inputparameter{i}.Fs;
        end
        
        %%% transform AP times into ISI
        if ~isnan(raster(1)) && length(raster) == 1
            mAHPbin = find(dS(time_AP_max_Vm:time_AP_max+2000,trial) == min(dS(time_AP_max:time_AP_max+2000,trial)),1)+ time_AP_max-1;
            mAHPVm{1,trial} = mean(dS(mAHPbin-10:mAHPbin+10,trial));
            mAHP{1,trial} = mAHPVm{1,trial} - AP_threshold{1,trial};
            ISI{trial} = NaN;
            Ifqz{trial} = NaN;  
            Mfqz(trial) = 1;
        elseif length(raster) > 1
            for k = 1 : length(raster)
                if k < length(raster)
                    mAHPbin(k) = find(dS(time_AP_max(k):time_AP_max(k+1),trial) == min(dS(time_AP_max(k):time_AP_max(k+1),trial)),1) + time_AP_max(k)-1;
                    mAHPVm{k,trial} = mean(dS(mAHPbin(k)-5:mAHPbin(k)+5,trial));
                    mAHP{k,trial} = mAHPVm{k,trial} - AP_threshold{k,trial};
                elseif find(dS(time_AP_max(k):Inputparameter{i}.IO_end,trial) == min(dS(time_AP_max(k):Inputparameter{i}.IO_end,trial)),1) + time_AP_max(k)-1 < Inputparameter{i}.IO_end-5
                    mAHPbin(k) = find(dS(time_AP_max(k):Inputparameter{i}.IO_end,trial) == min(dS(time_AP_max(k):Inputparameter{i}.IO_end,trial)),1) + time_AP_max(k)-1; 
                    mAHPVm{k,trial} = mean(dS(mAHPbin(k)-5:mAHPbin(k)+5,trial));
                    mAHP{k,trial} = mAHPVm{k,trial} - AP_threshold{k,trial};
                else
                    mAHPVm{k,trial} = NaN;
                    mAHP{k,trial} = NaN;
                end
            end
            ISI{trial} = (raster(2:end)-raster(1:end-1))';
            Ifqz{trial} = 1./ISI{trial};
            Mfqz(trial)= length(raster);
        else
            mAHPVm{trial} = NaN;
            mAHP{trial} = NaN;
            mAHPbin = NaN;
            ISI{trial} = NaN;
            Ifqz{trial} = NaN;
            Mfqz(trial) = NaN;
        end
        
        %%% normalise ISIs to 3rd ISI
        if length(ISI{trial}) > 4
            nISI{trial} = ISI{trial}./ISI{trial}(3);
            SDnISI{trial} = std(nISI{trial});
        else
            nISI{trial} = NaN;
            SDnISI{trial} = NaN;
        end
        if strcmp(show_single_epis,'yes')
            f = figure(3);
            set(f,'color','w');
            subplot(2,1,1)
            plot(timebases,dS(:,trial),'b'); hold on
            plot(timebases,Slope,'g'); hold on
            plot(sAHPbin/Inputparameter{1}.Fs,sAHPVm,'c.','MarkerSize',20); hold on
            if ~isnan(mAHPbin(1))
                plot(time_AP_max/Inputparameter{i}.Fs, Inputparameter{i}.AP_spike_threshold(1)*ones(1,length(time_AP_max)), 'r.','MarkerSize',10); hold on
                plot([mAHPbin/Inputparameter{i}.Fs],[mAHPVm{1:length(mAHPbin),trial}],'g.','MarkerSize',10); hold on
            end
            set(gca,'ylim',[-100 50]); %'xLim',[0.1 1.4],
            hold off
            title(['Datasection ' int2str(trial) ' channel: ' int2str(all_cells{i}.cfs_info.chVec)]);
        end
        % % Compute Slope of Spike adaptation and generate plot
        %akeman=IOsteps(trial)/Cm(i);
        if length(ISI{trial}) > 6
            clear Nisi Linear stats
            ISInr{trial} = 1:1:length(ISI{trial});
            Linear=ISInr{trial}(3:end);
            Nisi=nISI{trial}(3:end);            
            if sum(nISI{trial} > 5) >= 1 % SDnISI{trial} < 2
                if strcmp(Inputparameter{i}.celltype,'CTh') || strcmp(Inputparameter{i}.celltype,'CSp') % ~Inputparameter{i}.celltype == 'CTh' || ~Inputparameter{i}.celltype == 'CSp'
                    IOslope(trial) = NaN;
                    IOfit{trial} = NaN;
                    MIfqz(trial) = NaN;
                else
                    Nisi(find(Nisi>5)) = NaN;
                    stats = regstats(Nisi,Linear,'linear',{'yhat' 'beta' 'rsquare' 'fstat'});
                    IOfit{trial} = stats.yhat;
                    IOslope(trial) = stats.beta(2);
                    MIfqz(trial) = mean(Ifqz{trial}(3:end));
                end
            else
                stats = regstats(Nisi,Linear,'linear',{'yhat' 'beta' 'rsquare' 'fstat'});
                IOfit{trial} = stats.yhat;
                IOslope(trial) = stats.beta(2);
                MIfqz(trial) = mean(Ifqz{trial}(3:end));
            end
            if strcmp(show_single_epis,'yes')
                subplot(2,1,2)
                plot(ISInr{trial},nISI{trial}, 'k.'); hold on
                if ~isnan(IOslope(trial))
                    plot(Linear,IOfit{trial}, 'r');
                end
                set(gca,'xLim',[0 25],'ylim',[0 3]);
                ylabel('Normalised ISI (to 3rd ISI)');
                xlabel('ISI number');
                title(['Spike adaptation for trial ' int2str(trial) ', Akeman = ' num2str(akeStep(trial))]);
                hold off
            end
%             pause(4)
        else
            IOslope(trial) = NaN;
            MIfqz(trial) = NaN;
        end
        
        %save([cfsdir,sprintf('\\%d_%d_%d.mat',map4MalindaCTh(i,1),map4MalindaCTh(i,2),trial)])
        %saveas(h,[cfsdir,sprintf('\\%d_%d_%d.jpg',map4MalindaCTh(i,1),map4MalindaCTh(i,2),trial)],'jpg')
        %saveas(h,[cfsdir,sprintf('\\%d_%d_%d.fig',map4MalindaCTh(i,1),map4MalindaCTh(i,2),trial)],'fig')
        if length(raster) > 1
            ISIfreq(1,trial) = length(raster);
        else
            ISIfreq(1,trial) = 0;
        end
        %%% variables to save every trial!
        IO_spikeAdapt{i}.slope(:,trial) = slope;
        IO_spikeAdapt{i}.Slope(:,trial) = Slope;
        IO_spikeAdapt{i}.BaseVm(:,trial) = BaseVm;
        IO_spikeAdapt{i}.sAHPVm(:,trial) = sAHPVm;
        IO_spikeAdapt{i}.sAHP(:,trial) = sAHP;
        IO_spikeAdapt{i}.time_AP_max{trial} = time_AP_max;
        IO_spikeAdapt{i}.time_AP_count{trial} = time_AP_15;
        IO_spikeAdapt{i}.raster{trial} = raster;
    end
    IO_spikeAdapt{i}.sAHPmax = min(sAHP);
    %IO_spikeAdapt{i}.dS = dS;
    %IO_spikeAdapt{i}.timebases = timebases;
    IO_spikeAdapt{i}.AP_threshold = AP_threshold;
    IO_spikeAdapt{i}.mAHPVm = mAHPVm;
    IO_spikeAdapt{i}.mAHP = mAHP;
    IO_spikeAdapt{i}.ISI = ISI;
    IO_spikeAdapt{i}.Ifqz = Ifqz;
    IO_spikeAdapt{i}.Mfqz = Mfqz;
    IO_spikeAdapt{i}.nISI = nISI;
    IO_spikeAdapt{i}.SDnISI = SDnISI;
    try
        IO_spikeAdapt{i}.ISInr = ISInr;
    catch
        IO_spikeAdapt{i}.ISInr = NaN;
    end
    IO_spikeAdapt{i}.ISIfreq = ISIfreq;
    IO_spikeAdapt{i}.IOsteps = IOsteps;
    IO_spikeAdapt{i}.akeStep = akeStep;
    IO_spikeAdapt{i}.IOslope = IOslope;
    IO_spikeAdapt{i}.MIfqz = MIfqz;
    try
        IO_spikeAdapt{i}.IOfit = IOfit;
    catch
        IO_spikeAdapt{i}.IOfit = NaN;
    end
    try
    IO_spikeAdapt{i}.APs = APs;
    end
    clear dS timebases ISI Ifqz Mfqz MIfqz nISI SDnISI ISInr ISIfreq z IOslope IOfit akeStep sAHP sAHPVm APs mAHP mAHPVm akeStep AP_threshold
end


%save([file_dir,'\IO_spikeAdaptCTh.mat'],'IO_spikeAdaptCTh')


