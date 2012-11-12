function AHP100 = tgr_AHP100(all_cells,Inputparameter,show_single_epis,show_average_section)

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

if nargin<2
    [fname pname] = uigetfile('','Select preloaded info data.');
    Inputparameter = load([pname fname]);
    token = fieldnames(Inputparameter);
    if length(token)~=1
        disp('Too many input variables in cell-file!')
    else
        Inputparameter = Inputparameter.(token{1});
    end
end

if nargin<3
    show_single_epis = 'yes';
end

if nargin<4
    show_average_section = 'yes';
end

if length(Inputparameter) ~= length(all_cells)
    disp('Dimension mismatch of cell and info inputs');
end

AHP100 = cell(1,length(all_cells));

%%% start of Analysis
for i = 1:size(all_cells,2)
    clear sAHP100 akeAHP100
    % Notch filter settings
    Order = 3;
    Wn1 = [40/(Inputparameter{i}.Fs/2) 60/(Inputparameter{i}.Fs/2)];
    [b1 a1] = butter(Order,Wn1,'stop');
    % Savitzky-Golay filter
    smoothwinL = 1;     % (ms)
    order = 1;
    binwidth = ceil(smoothwinL/1000*Inputparameter{i}.Fs);
    if mod(binwidth,2) == 0
        [~,g] = sgolay(order,binwidth-1);
    else
        [~,g] = sgolay(order,binwidth);
    end
    lg = size(g(:,2),1);
    extrabins = floor(lg/2); % delay caused by filtering, in bins
    
    for j=1:length(Inputparameter{i}.AHPsteps)
        trialc = 1;
        for trial = Inputparameter{i}.AHP{j}
            disp(trial)
%             data = filtfilt(b1,a1,all_cells{i}.rawdata(:,trial));
%             sgSignal = filter(g(:,1),1,data);
%             sgSignal = [sgSignal(lg)*ones(extrabins,1); sgSignal(lg:end); sgSignal(end)*ones(extrabins,1)];
%             dS(:,trialc) = all_cells{i}.cfs_info.yScales(1) * sgSignal + all_cells{i}.cfs_info.yOffsets(1);
            dS(:,trialc) = all_cells{i}.dS(:,trial);
            timebases = all_cells{i}.timebases(:,trial);
            if strcmp(show_single_epis,'yes')
                f = figure(7);
                set(f,'color','w');
                plot(dS(:,trialc)); hold on
                title(['AHP episode ' int2str(trial)]);
                %pause(0.5)
            end
            trialc = trialc + 1;            
        end
        timebase(:,j)=timebases;
        gS = filter(g(:,1),1,mean(dS,2)); % average episodes for each Istep and filter
        gS=[gS(extrabins:end); gS(end)*ones(extrabins-1,1)];
        mS(:,j) = gS;
        BaseVm = mean(mS([Inputparameter{i}.Baseline(1):Inputparameter{i}.Baseline(2)],j));
        PeakVm(j) = min(mS(Inputparameter{i}.Teststart+1000:Inputparameter{i}.Testend+4000,j));
        AHP100bin(j) = find(mS(Inputparameter{i}.Teststart+1000:Inputparameter{i}.Testend+4000,j) == PeakVm(j),1) + Inputparameter{i}.Teststart+1000-1;
        sAHP100(j) = PeakVm(j)-BaseVm;
        akeAHP100(j) = Inputparameter{i}.AHPsteps(j)/Inputparameter{i}.basic_properties{i}.Cm;
    end
    if strcmp(show_average_section,'yes')
        f = figure(4);
        set(f,'color','w');
        plot(timebase,mS); hold on % timebase(:,1:size(mS,2))
        plot(AHP100bin./Inputparameter{i}.Fs,PeakVm,'k.','MarkerSize',20); hold on
        set(gca,'XLim',[0.3 1]);
        set(gca,'YLim',[-75 0]);
        ylabel('Membrane potential (mV)');
        xlabel('Time (s)');
        title(['AHP (100 ms step) for cell ' Inputparameter{i}.expName]);
    end
    hold off
    AHP100{i}.sAHP100 = sAHP100;
    AHP100{i}.akeAHP100 = akeAHP100;
end