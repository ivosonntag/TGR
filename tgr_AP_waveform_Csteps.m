function AP_waveform = tgr_AP_waveform_Csteps(all_cells,Inputparameter,show_single_epis)


while ab<lbin
    if sum(Slope(ab:lbin)>Inputparameter.AP_spike_threshold(1))
        ab=find(Slope(ab:lbin)>Inputparameter.AP_spike_threshold(1),1)+ab-1;
        %%% Interpolate the Data and the differential
        testDS = dS(ab:ab+500,trial);
        AP_slope = diff(testDS);
        DS_interp = interp1(1:100:50100,testDS,1:50000);
        slope_interp = interp1(1:100:50000,AP_slope,1:50000);
        Slope_interp = slope_interp*Inputparameter.Ms;
        %%% identify the closest AP and determine its
        %%% start/end, maximum and 50/75% width
        AP_start = ab;
        [AP_max_value_Vm AP_max_time_Vm] = max(DS_interp(ab:ab+500));
        AP_peak = AP_max_time_Vm+ab-1;
        AP_end = find(DS_interp(AP_peak:AP_peak+500)<=DS_interp(AP_start),1)+AP_peak-1;
        AP_Amp = DS_interp(AP_peak)-DS_interp(AP_start);
        [~, AP_half1] = min(abs(DS_interp(AP_start:AP_peak)'-repmat(DS_interp(AP_start)+AP_Amp*0.5,length(DS_interp(AP_start:AP_peak)),1)));
        [~, AP_half2] = min(abs(DS_interp(AP_peak:AP_end)'-repmat(DS_interp(AP_start)+AP_Amp*0.5,length(DS_interp(AP_peak:AP_end)),1)));
        [~, AP_75_1] = min(abs(DS_interp(AP_start:AP_peak)'-repmat(DS_interp(AP_start)+AP_Amp*0.75,length(DS_interp(AP_start:AP_peak)),1)));
        [~, AP_75_2] = min(abs(DS_interp(AP_peak:AP_end)'-repmat(DS_interp(AP_start)+AP_Amp*0.75,length(DS_interp(AP_peak:AP_end)),1)));
        AP_half1 = AP_half1+AP_start-1;
        AP_half2 = AP_half2+AP_peak-1;
        AP_75_1 = AP_75_1+AP_start-1;
        AP_75_2 = AP_75_2+AP_peak-1;
        if sum(dS(AP_peak-5:AP_peak+34,trial)>Inputparameter.AP_spike_threshold(2))
            count1 = count1+1;
            time_AP_max(count1) = AP_peak;
            time_AP_count(count1) = ab;
            APs{count1,trial}.shape = dS(ab:ab+200,trial);
            APs{count1,trial}.dp_width = [AP_start AP_end];
            APs{count1,trial}.halfwidth = AP_end-AP_start;
            APs{count1,trial}.dp_halfwidth = [AP_half1 AP_half2];
            APs{count1,trial}.halfwidth = AP_half2-AP_half1;
            APs{count1,trial}.dp_width75 = [AP_75_1 AP_75_2];
            APs{count1,trial}.width75 = AP_75_2-AP_75_1;
            APs{count1,trial}.amp = AP_Amp;
            APs{count1,trial}.peak = AP_peak;
        end
        ab=AP_peak+50;
    else
        ab=lbin;
    end
end