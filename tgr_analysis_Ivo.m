
clear
[num,txt,raw] = xlsread('E:\NZ\DATA\AP-Shape_CC_analysis.xlsx');

% fn = 'E:\NZ\DATA\121025\2012_10_25_0001.abf';
% [d,si,h] = abfload(fn);
% data{1} = squeeze(d(:,1,:));
% plot(data{1})

Inputparameter{1}.Baseline(1) = 1;
Inputparameter{1}.Baseline(2) = 10000;
Inputparameter{1}.Fs = 20000;
Inputparameter{1}.Ms = Inputparameter{1}.Fs/1000;
Inputparameter{1}.show_single_epis='yes';
Inputparameter{1}.show_average_section ='yes';
Inputparameter{1}.AP_slope_threshold = 12;
Inputparameter{1}.AP_spike_threshold = [12 5];
Inputparameter{1}.sAHPbaseEnd = 180*Inputparameter{1}.Ms;
Inputparameter{1}.sAHPstart = 1500*Inputparameter{1}.Ms;
Inputparameter{1}.sAHPend = 1900*Inputparameter{1}.Ms;
Inputparameter{1}.IO_start = 501*Inputparameter{1}.Ms;
Inputparameter{1}.IO_end = 1500*Inputparameter{1}.Ms;
Inputparameter{1}.IOsteps = -100:50:600;
Inputparameter{1}.expName = 'defaultExperiment';
Inputparameter{1}.celltype = [];

AP_halfwidth_mean = nan(14,8);
for cell = 1:size(num,1)
    for column = 3:8
        day = num2str(num(cell,1));
        fn{1} = sprintf('E:\\NZ\\DATA\\%d\\20%s_%s_%s_%04d.abf',num(cell,1),day(1:2),day(3:4),day(5:6),num(cell,column));
        data = tgr_abfLoad(fn);
        plot(data{1}.dS)
        token = tgr_abf_RMP(data,Inputparameter);
        RMP(cell,column) = token{1};
        if column > 5 && num(cell,9) ~= 0
            IO_spikeAdapt{cell,column} = tgr_abf_IO_spikeAdapt(data,Inputparameter,'yes');
            [~, pos] = min(abs(IO_spikeAdapt{cell,column}{1,1}.ISIfreq-15));
            for i = 1:size(IO_spikeAdapt{cell,column}{1,1}.APs,1)
                if ~isempty(IO_spikeAdapt{cell,column}{1,1}.APs{i,pos})
                    AP2use{1} = IO_spikeAdapt{cell,column}{1,1}.APs{i,pos};
                    AP_waveform = tgr_AP_waveform(AP2use,Inputparameter);
                    AP_halfwidth{cell,column}(i) = AP_waveform{1,1}.APhalf_time;
                    AP_halfwidth_mean(cell,column) = mean(AP_halfwidth{cell,column});
                end
            end
            disp(txt{cell+1,2})
            pause
        end
    end
end

for cell = 1:size(num,1)
    for column = 6:8
        if num(cell,9) ~= 0
            [~, pos] = min(abs(IO_spikeAdapt{cell,column}{1,1}.ISIfreq-15));
            switch column
                case 6
                    subplot(3,1,1)
                    plot(IO_spikeAdapt{cell,column}{1,1}.ISI{pos}); hold on
                    ylim([0 0.2])
                case 7
                    subplot(3,1,2)
                    plot(IO_spikeAdapt{cell,column}{1,1}.ISI{pos}); hold on
                    ylim([0 0.2])
                case 8
                    subplot(3,1,3)
                    plot(IO_spikeAdapt{cell,column}{1,1}.ISI{pos}); hold on
                    ylim([0 0.2])
            end
        end
    end
end

figure(1)
subplot(2,3,1)
plot([1:3],RMP(1:4,3:5),'-rs','MarkerSize',5);hold on
ylim([-80 -45])
subplot(2,3,2)
plot([1:3],RMP(5:10,3:5),'-bs','MarkerSize',5)
ylim([-80 -45])
subplot(2,3,3)
plot([1:3],RMP(11:14,3:5),'-gs','MarkerSize',5)
ylim([-80 -45])
subplot(2,3,4)
plot([1:3],RMP(1:4,6:8),'-rs','MarkerSize',5);hold on
ylim([-80 -45])
subplot(2,3,5)
plot([1:3],RMP(5:10,6:8),'-bs','MarkerSize',5)
ylim([-80 -45])
subplot(2,3,6)
plot([1:3],RMP(11:14,6:8),'-gs','MarkerSize',5)
ylim([-80 -45])


