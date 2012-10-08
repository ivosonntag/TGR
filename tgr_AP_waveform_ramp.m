function AP_waveform = tgr_AP_waveform_ramp(all_cells,Inputparameter,show_single_epis)

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

if length(Inputparameter) ~= length(all_cells)
    disp('Dimension mismatch of cell and info inputs');
end

AP_waveform = cell(1,length(all_cells));

for i = 1:max(length(all_cells))
    %if all_cells{i}.name == Inputparameter{i}.expName
        clear variables!!!
        trial = Inputparameter{i}.APepis;
        dS = all_cells{i}.dS(:,trial);
        slope = diff(dS);
        Slope = [slope * Inputparameter{i}.Ms; slope(end) * Inputparameter{i}.Ms;];
        timebases = all_cells{i}.timebases;
        %%% calculate AP waveform parameters
        APmaxSlopes = [max(Slope) min(Slope)];
        APthreshBin = find(Slope > Inputparameter{i}.AP_slope_threshold, 1 );
        AP_threshold = dS(APthreshBin);
        AP_peakVm = max(dS);
        if APthreshBin < Inputparameter{i}.RampEnd-2000
            mAHPbin = find(dS(APthreshBin:APthreshBin+2000) == min(dS(APthreshBin:APthreshBin+2000)),1) + APthreshBin-1;
        else
            mAHPbin = find(dS(APthreshBin:Inputparameter{i}.RampEnd) == min(dS(APthreshBin:Inputparameter{i}.RampEnd)),1) + APthreshBin-1;
        end
        mAHPVm = mean(dS(mAHPbin-10:mAHPbin+10));       
        APamp_peak_ahp = AP_peakVm - mAHPVm;
        AP_amplitude = AP_peakVm - AP_threshold;
        APhalfAmp = AP_amplitude / 2 + AP_threshold;
        APhalfBin1 = find(dS(APthreshBin:APthreshBin+100) > APhalfAmp, 1 ) + APthreshBin-1;
        APhalfBin2 = find(dS(APhalfBin1:APhalfBin1+60) < APhalfAmp, 1 ) + APhalfBin1-1;
        APhalf_time = (APhalfBin2-APhalfBin1) / Inputparameter{i}.Ms;
        max_ADP_bin = APthreshBin + 25 * Inputparameter{i}.Ms;
        max_fAHP_bin = APthreshBin + floor(APhalf_time * 6.6 * Inputparameter{i}.Ms);
        fAHPbin = find(dS(APthreshBin+20:max_fAHP_bin) == min(dS(APthreshBin+20:max_fAHP_bin)), 1 ) + APthreshBin + 19;
        if fAHPbin < max_fAHP_bin-10
            fAhpVm=dS(fAHPbin);
            AdpVm=max(dS(fAHPbin:max_ADP_bin));
            fAHP = AP_threshold - fAhpVm;
            ADP = AdpVm - fAhpVm;
        else
            fAHP = NaN; 
            ADP = NaN;
        end
        if strcmp(show_single_epis,'yes')
%             try
            h = figure(2);
            set(h,'color','w');
            plot(timebases,dS,'b'); hold on
%             plot(timebases,Slope,'r');
            plot([APhalfBin1/Inputparameter{i}.Fs APhalfBin2/Inputparameter{i}.Fs],[APhalfAmp APhalfAmp],'g.','MarkerSize',20); hold on
            if ~isnan(fAHP)
                plot(fAHPbin/Inputparameter{i}.Fs,fAhpVm,'r.','MarkerSize',20); hold on
            end
            plot(mAHPbin/Inputparameter{i}.Fs,mAHPVm,'b.','MarkerSize',20); hold on
            set(gca,'XLim',[APthreshBin/Inputparameter{i}.Fs-0.01 APthreshBin/Inputparameter{i}.Fs+0.1]);
            set(gca,'YLim',[mAHPVm-5 AP_peakVm+5]);
            title(['AP waveform for ' Inputparameter{i}.expName ', episode: ' int2str(trial)]);
%             pause(0.2)
%             catch
%                 lasterr
%             end
        end
        AP_waveform{i}.expName = Inputparameter{i}.expName;
        AP_waveform{i}.AP = dS(APthreshBin-100:APthreshBin+1000);
        slope_AP = diff(AP_waveform{i}.AP);
        AP_waveform{i}.APmaxSlopes = [max(slope_AP) min(slope_AP)] .* 20; 
        AP_waveform{i}.AP_peakVM = AP_peakVm;
        AP_waveform{i}.AP_amplitude = AP_amplitude;
        AP_waveform{i}.APhalf_time = APhalf_time;
        AP_waveform{i}.fAHP = fAHP;
        AP_waveform{i}.ADP = ADP;
        AP_waveform{i}.mAHP = mAHPVm - AP_threshold;
        AP_waveform{i}.APamp_peak_ahp = APamp_peak_ahp;
        AP_waveform{i}.AP_threshold = AP_threshold;
        AP_waveform{i}.AP = dS(APthreshBin-50:APthreshBin+200);
        hold off
    %end
end



