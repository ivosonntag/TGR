function AP_waveform = tgr_AP_waveform(all_cells,Inputparameter,show_single_epis)

if nargin<3
    show_single_epis = 'yes';
end

AP_waveform = cell(1,length(all_cells));

for i = 1:max(length(all_cells))
    %if all_cells{i}.name == Inputparameter{i}.expName
    clear variables!!!
    dS = all_cells{i}(:,1);
    slope = diff(dS);
    Slope = [slope * Inputparameter{i}.Ms; slope(end) * Inputparameter{i}.Ms;];
    timebases = 1:size(dS,1);
    %%% calculate AP waveform parameters
    APmaxSlopes = [max(Slope) min(Slope)];
    APthreshBin = find(Slope > Inputparameter{i}.AP_slope_threshold, 1 );
    AP_threshold = dS(APthreshBin);
    [AP_peakVm AP_peakBin] = max(dS);
    [~, mAHPbin] = min(dS(AP_peakBin:end));
    mAHPbin = mAHPbin + APthreshBin-1;
    mAHPVm = mean(dS(mAHPbin-10:mAHPbin+10));
    APamp_peak_ahp = AP_peakVm - mAHPVm;
    AP_amplitude = AP_peakVm - AP_threshold;
    APhalfAmp = AP_amplitude / 2 + AP_threshold;
    APhalfBin1 = find(dS(APthreshBin:APthreshBin+100) > APhalfAmp, 1 ) + APthreshBin-1;
    APhalfBin2 = find(dS(APhalfBin1:end) < APhalfAmp, 1 ) + APhalfBin1-1;
    APhalf_time = (APhalfBin2-APhalfBin1) / Inputparameter{i}.Ms;
    %max_ADP_bin = APthreshBin + 25 * Inputparameter{i}.Ms;
    max_fAHP_bin = APthreshBin + floor(APhalf_time * 6.6 * Inputparameter{i}.Ms);
    %fAHPbin = find(dS(APthreshBin+20:max_fAHP_bin) == min(dS(APthreshBin+20:max_fAHP_bin)), 1 ) + APthreshBin + 19;
    %if fAHPbin < max_fAHP_bin-10
    %    fAhpVm=dS(fAHPbin);
    %    AdpVm=max(dS(fAHPbin:end));
    %    fAHP = AP_threshold - fAhpVm;
    %    ADP = AdpVm - fAhpVm;
    %else
    %    fAHP = NaN;
    %    ADP = NaN;
    %end
    if strcmp(show_single_epis,'yes')
        figure(4)
        %             try
        h = figure(2);
        set(h,'color','w');
        plot(timebases,dS,'b'); hold on
        %             plot(timebases,Slope,'r');
        plot([APhalfBin1 APhalfBin2],[APhalfAmp APhalfAmp],'g.','MarkerSize',20); hold on
        %if ~isnan(fAHP)
        %    plot(fAHPbin,fAhpVm,'r.','MarkerSize',20); hold on
        %end
        plot(mAHPbin,mAHPVm,'b.','MarkerSize',20); hold on
        set(gca,'YLim',[mAHPVm-5 AP_peakVm+5]);
        title(['AP waveform for ' Inputparameter{i}.expName ', episode: ' int2str(1)]);
        %             pause(0.2)
        %             catch
        %                 lasterr
        %             end
    end
    AP_waveform{i}.expName = Inputparameter{i}.expName;
    AP_waveform{i}.AP_peakVM = AP_peakVm;
    AP_waveform{i}.AP_amplitude = AP_amplitude;
    AP_waveform{i}.APhalf_time = APhalf_time;
    %AP_waveform{i}.fAHP = fAHP;
    %AP_waveform{i}.ADP = ADP;
    AP_waveform{i}.mAHP = mAHPVm - AP_threshold;
    AP_waveform{i}.APamp_peak_ahp = APamp_peak_ahp;
    AP_waveform{i}.AP_threshold = AP_threshold;
    hold off
    %end
end



