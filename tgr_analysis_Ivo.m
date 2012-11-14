
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
Inputparameter{1}.sAHPstart = 1200*Inputparameter{1}.Ms;
Inputparameter{1}.sAHPend = 1600*Inputparameter{1}.Ms;
Inputparameter{1}.IO_start = 501*Inputparameter{1}.Ms;
Inputparameter{1}.IO_end = 1500*Inputparameter{1}.Ms;
Inputparameter{1}.IOsteps = -100:50:600;
Inputparameter{1}.expName = 'defaultExperiment';
Inputparameter{1}.celltype = [];

csteps = 50:50:600;

AP_halfwidth_mean = nan(14,8);
for cell = 1:size(num,1)
    clf
    h = figure(1);
    for column = 3:8
        day = num2str(num(cell,1));
        fn{1} = sprintf('E:\\NZ\\DATA\\%d\\20%s_%s_%s_%04d.abf',num(cell,1),day(1:2),day(3:4),day(5:6),num(cell,column));
        data = tgr_abfLoad(fn);
        timebasesAP = data{1}.timebases(1:250);
        %plot(data{1}.dS)
        token = tgr_abf_RMP(data,Inputparameter);
        RMP(cell,column) = token{1};
        if column > 5 && num(cell,9) ~= 0
            evalc('IO_spikeAdapt{cell,column} = tgr_abf_IO_spikeAdapt(data,Inputparameter,''no'')');
            if size(IO_spikeAdapt{cell,column}{1,1}.ISIfreq,2)>7
                %[~, pos] = min(abs(IO_spikeAdapt{cell,column}{1,1}.ISIfreq(1:7)-15));
                [~, pos] = find(IO_spikeAdapt{cell,column}{1,1}.ISIfreq(1:end)>14,1);
            else
                %[~, pos] = min(abs(IO_spikeAdapt{cell,column}{1,1}.ISIfreq(1:end)-15));
                [~, pos] = find(IO_spikeAdapt{cell,column}{1,1}.ISIfreq(1:end)>14,1);
            end
            freq = IO_spikeAdapt{cell,column}{1,1}.ISIfreq(pos);
            for i = 1:size(IO_spikeAdapt{cell,column}{1,1}.APs,1)
                if ~isempty(IO_spikeAdapt{cell,column}{1,1}.APs{i,pos})
                    AP2use{1} = IO_spikeAdapt{cell,column}{1,1}.APs{i,pos};
                    APs_inAnal{cell,column}(i,:) = AP2use{1};
                    evalc('AP_waveform = tgr_AP_waveform(AP2use,Inputparameter,''no'')');
                    AP_halfwidth{cell,column}(i) = AP_waveform{1,1}.APhalf_time;
                    AP_halfwidth_mean(cell,column) = mean(AP_halfwidth{cell,column});
                end
            end
            switch column
                case 6
                    subplot(3,3,1)
                    boundedline(timebasesAP*1000,mean(APs_inAnal{cell,column}),std(APs_inAnal{cell,column}),'r')
                    xlabel('ms')
                    ylabel('mV')
                    title({'mean and std of APs in current step';'closest to 15Hz'})
                    ylim([-60 80])
                    subplot(3,3,4)
                    plot(data{1}.timebases,IO_spikeAdapt{cell,column}{1,1}.dS(:,pos),'r');
                    xlabel('s')
                    ylabel('mV')
                    title({'corresponding spike train';[sprintf('Fqz = %d ',freq),sprintf('Cstep = %d',csteps(pos))]})
                    ylim([-80 80])
                    %annotation('textbox',[0.3 0.29 0.1 0.1],'String',{sprintf('Fqz = %d',freq);sprintf('Cstep = %d',csteps(pos))})
                    subplot(3,3,7)
                    plot(AP_halfwidth{cell,column},'r'); hold all
                    xlabel('number of AP')
                    ylabel('AP half width')
                    title('Half-width')
                    subplot(3,3,8)
                    hold on
                    plot(IO_spikeAdapt{cell,column}{1,1}.ISI{1,pos},'r');
                    xlabel('number of ISI')
                    ylabel('ISI')
                    title('Inter-spike interval')
                case 7
                    subplot(3,3,2)
                    boundedline(timebasesAP*1000,mean(APs_inAnal{cell,column}),std(APs_inAnal{cell,column}),'g')
                    xlabel('ms')
                    ylabel('mV')
                    title({'mean and std of APs in current step';'closest to 15Hz'})
                    ylim([-60 80])
                    subplot(3,3,5)
                    plot(data{1}.timebases,IO_spikeAdapt{cell,column}{1,1}.dS(:,pos),'g')
                    xlabel('s')
                    ylabel('mV')
                    title({'corresponding spike train';[sprintf('Fqz = %d ',freq),sprintf('Cstep = %d',csteps(pos))]})
                    ylim([-80 80])
                    %annotation('textbox',[0.58 0.29 0.1 0.1],'String',{sprintf('Fqz = %d Hz',freq),sprintf('Cstep = %d pA',csteps(pos))})
                    subplot(3,3,7)
                    plot(AP_halfwidth{cell,column},'g');
                    xlabel('number of AP')
                    ylabel('AP half width in ms')
                    title('Half-width')
                    subplot(3,3,8)
                    hold on
                    plot(IO_spikeAdapt{cell,column}{1,1}.ISI{1,pos},'g');
                    xlabel('number of ISI in s')
                    ylabel('ISI')
                    title('Inter-spike interval')
                case 8
                    subplot(3,3,3)
                    boundedline(timebasesAP*1000,mean(APs_inAnal{cell,column}),std(APs_inAnal{cell,column}),'b')
                    xlabel('ms')
                    ylabel('mV')
                    title({'mean and std of APs in current step';'closest to 15Hz'})
                    ylim([-60 80])
                    subplot(3,3,6)
                    plot(data{1}.timebases,IO_spikeAdapt{cell,column}{1,1}.dS(:,pos),'b')
                    xlabel('s')
                    ylabel('mV')
                    title({'corresponding spike train';[sprintf('Fqz = %d ',freq),sprintf('Cstep = %d',csteps(pos))]})
                    ylim([-80 80])
                    %annotation('textbox',[0.77 0.29 0.1 0.1],'String',{sprintf('Fqz = %d',freq);sprintf('Cstep = %d',csteps(pos))})
                    subplot(3,3,7)
                    plot(AP_halfwidth{cell,column},'b');
                    xlabel('number of AP')
                    ylabel('AP half width')
                    title('Half-width')
                    subplot(3,3,8)
                    hold on
                    plot(IO_spikeAdapt{cell,column}{1,1}.ISI{1,pos},'b'); hold on
                    xlabel('number of ISI')
                    ylabel('ISI')
                    title('Inter-spike interval')
            end
            %pause
        end
    end
    annotation('textbox',[0.75 0.1 0.12 0.12],'String',{sprintf('date = %s',day);sprintf('Cell = %s',raw{cell+1,2}(3));...
        sprintf('Slice = %s',raw{cell+1,2}(1));sprintf('Cell ID = %d',cell)})
    saveas(h,['E:\NZ\DATA\CELL-FIGURES\',day,'_',raw{cell+1,2},'.pdf'],'pdf');
    %pause
end

count = 1;
for i = [1 2 7 8 9 11 13 14]
    AP_hw_norm(count,:) = AP_halfwidth_mean(i,6:8)-AP_halfwidth_mean(i,6);
    AP_hw_per(count,:) = ((AP_halfwidth_mean(i,6:8)-AP_halfwidth_mean(i,6))./AP_halfwidth_mean(i,6:8))*100;
    count = count+1;
end

figure(2)
subplot(1,2,1)
plot(1:3,AP_hw_norm,'-.o','MarkerSize',5)
xlim([1 4])
title('normalized AP half width')
ylabel('change from baseline in ms')
set(gca,'Xtick',1:4,'XTickLabel',{'baseline','EGTA','Cd2+','',''})
subplot(1,2,2)
plot(1:3,AP_hw_per,'-.o','MarkerSize',5)
xlim([1 4])
title('AP half width change in %')
ylabel('change from baseline in %')
set(gca,'Xtick',1:4,'XTickLabel',{'baseline','EGTA','Cd2+','',''})
% %%
% for cell = 1:size(num,1)
%     for column = 6:8
%         if num(cell,9) ~= 0
%             [~, pos] = min(abs(IO_spikeAdapt{cell,column}{1,1}.ISIfreq-15));
%             switch column
%                 case 6
%                     subplot(3,1,1)
%                     plot(IO_spikeAdapt{cell,column}{1,1}.ISI{pos}); hold on
%                     ylim([0 0.2])
%                 case 7
%                     subplot(3,1,2)
%                     plot(IO_spikeAdapt{cell,column}{1,1}.ISI{pos}); hold on
%                     ylim([0 0.2])
%                 case 8
%                     subplot(3,1,3)
%                     plot(IO_spikeAdapt{cell,column}{1,1}.ISI{pos}); hold on
%                     ylim([0 0.2])
%             end
%         end
%     end
% end
%
% figure(1)
% subplot(2,3,1)
% plot([1:3],RMP(1:4,3:5),'-rs','MarkerSize',5);hold on
% ylim([-80 -45])
% subplot(2,3,2)
% plot([1:3],RMP(5:10,3:5),'-bs','MarkerSize',5)
% ylim([-80 -45])
% subplot(2,3,3)
% plot([1:3],RMP(11:14,3:5),'-gs','MarkerSize',5)
% ylim([-80 -45])
% subplot(2,3,4)
% plot([1:3],RMP(1:4,6:8),'-rs','MarkerSize',5);hold on
% ylim([-80 -45])
% subplot(2,3,5)
% plot([1:3],RMP(5:10,6:8),'-bs','MarkerSize',5)
% ylim([-80 -45])
% subplot(2,3,6)
% plot([1:3],RMP(11:14,6:8),'-gs','MarkerSize',5)
% ylim([-80 -45])


