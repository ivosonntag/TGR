function basic_properties = tgr_basic_properties(all_cells,Inputparameter,show_single_epis,show_average_section)

%%% this is an old version of the basic_properties function and should be replaced with basic_props.m

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
    show_single_epis = 'no';
end

if nargin<4
    show_average_section = 'yes';
end

if length(Inputparameter) ~= length(all_cells)
    disp('Dimension mismatch of cell and info inputs');
end

basic_properties = cell(1,length(all_cells));

for i = 1:max(length(all_cells))
    % Notch filter settings
    Order = 3;
    Wn1 = [40/(Inputparameter{i}.Fs/2) 60/(Inputparameter{i}.Fs/2)];
    [b1 a1] = butter(Order,Wn1,'stop');
    % % Analyse Test pulse states for RMP and Rm
    clear dS timebases Peakbin xdata ydata FittedCurve Fitted PeakVm AP_threshold APhalf_time APmaxSlopes AP_amplitude fAHP ADP
    for trial = Inputparameter{i}.state{1}
        fprintf('cell %d trial %d/%d \n',i,trial,length(Inputparameter{i}.state{1}));
        data = filtfilt(b1,a1,all_cells{i}.rawdata(:,trial));
        dS(:,trial) = all_cells{i}.cfs_info.yScales(1) * data + all_cells{i}.cfs_info.yOffsets(1);
        timebases = all_cells{i}.timebases;
        if strcmp(show_single_epis,'yes')
            %                 plot(timebases(:,trial),rawdata); hold on
            %                 plot(timebases(:,trial),data,'r'); hold off
            subplot(1,2,1)
            plot(timebases,dS(:,trial));
            title(['Testpulse episode ' int2str(trial) 'filtered']);
            subplot(1,2,2)
            plot(timebases,all_cells{i}.dS(:,trial));
            title(['Testpulse episode ' int2str(trial) 'not filtered']);
            %pause(0.2)
        end
    end
    TestVm = mean(dS,2);
    basic_properties{i}.RMP = mean(TestVm(Inputparameter{i}.Baseline(1):Inputparameter{i}.Baseline(2)));
    PeakVm = min(TestVm(Inputparameter{i}.Teststart:Inputparameter{i}.Testend));
    basic_properties{i}.Rm = (PeakVm - basic_properties{i}.RMP) / Inputparameter{i}.TestI*1000;
    Peakbin = find(TestVm(Inputparameter{i}.Teststart:Inputparameter{i}.Testend) == PeakVm,1) + Inputparameter{i}.Teststart-1;
    NormVm = TestVm - PeakVm + Inputparameter{i}.a0(1);
    xdata = timebases(Inputparameter{i}.Teststart:Peakbin);
    ydata = NormVm(Inputparameter{i}.Teststart:Peakbin)';
    fprintf('cell %d start fitting',i);
    [estimates, model] = fitcurvedemo(xdata,ydata);
    basic_properties{i}.Timeconst = 1/estimates(2)*1000;
    basic_properties{i}.Cm = basic_properties{i}.Timeconst/basic_properties{i}.Rm*1000;
    [~, FittedCurve] = model(estimates);
    Fitted = FittedCurve;
    if strcmp(show_average_section,'yes')
        f=figure;
        set(f,'color','w');
        plot(timebases,NormVm,'b'); hold on
        plot(xdata,Fitted,'g'); hold on
        xlabel('Time (sec)')
        ylabel('Potential (mV)')
        title(['Test pulse and Fit ', func2str(model)]);
        legend('Test1','Fit1','Location','SouthEast');
        title(['Testpulse for ' Inputparameter{i}.expName]);
    end
end



