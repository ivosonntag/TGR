%%% Script for plotting the average Instantaneous frequency per
%%% sweep(trial) using only sweeps with a minimum number of
%%% Actionpotentials
clear 

load('E:\NZ\MalindaDATA\CS_ISIs.mat')
load('E:\NZ\MalindaDATA\CCS_ISIs.mat')
load('E:\NZ\TGR\output4mat.mat')
load('E:\NZ\ManfredData\TGR-Malinda_Data.mat')

cth26_count = 1;
cc26_count = 1;
cstr26_count = 1;
csp26_count = 1;
cth36_count = 1;
cc36_count = 1;
cstr36_count = 1;
csp36_count = 1;
for i = 2:size(output4mat,2)
    if xls_output{i,2} == 26
        if ~isempty(strfind(xls_output{i,1},'CTh'))
            CTh_26{cth26_count} = output4mat{i};
            cth26_count = cth26_count+1;
        elseif ~isempty(strfind(xls_output{i,1},'CC'))
            CC_26{cc26_count} = output4mat{i};
            cc26_count = cc26_count+1;
        elseif ~isempty(strfind(xls_output{i,1},'CStr'))
            CStr_26{cstr26_count} = output4mat{i};
            cstr26_count = cstr26_count+1;
        elseif ~isempty(strfind(xls_output{i,1},'CSp'))
            CSp_26{csp26_count} = output4mat{i};
            csp26_count = csp26_count+1;
        end
    else
        if ~isempty(strfind(xls_output{i,1},'CTh'))
            CTh_36{cth36_count} = output4mat{i};
            cth36_count = cth36_count+1;
        elseif ~isempty(strfind(xls_output{i,1},'CC'))
            CC_36{cc36_count} = output4mat{i};
            cc36_count = cc36_count+1;
        elseif ~isempty(strfind(xls_output{i,1},'CStr'))
            CStr_36{cstr36_count} = output4mat{i};
            cstr36_count = cstr36_count+1;
        elseif ~isempty(strfind(xls_output{i,1},'CSp'))
            CSp_36{csp36_count} = output4mat{i};
            csp36_count = csp36_count+1;
        end
    end
end

%%% add malindas Data

for i = 1:size(CC,2)
    CC_26{end+1}.IO_spikeAdapt{1,1}.Ifqz = CC{i}.IO_spikeAdapt{1,1}.Ifqz(:,4:end);
    CC_26{end}.IO_spikeAdapt{1,1}.Mfqz = CC{i}.IO_spikeAdapt{1,1}.Mfqz(:,4:end);
    CTh_26{end+1}.IO_spikeAdapt{1,1}.Ifqz = CTh{i}.IO_spikeAdapt{1,1}.Ifqz(:,4:end);
    CTh_26{end}.IO_spikeAdapt{1,1}.Mfqz = CTh{i}.IO_spikeAdapt{1,1}.Mfqz(:,4:end);
end

%%% add Manfreds Data

for i = 1:size(Fqz_CCS,1)
    CStr_26{end+1} = [];
    for ii = 1:size(Fqz_CCS,2)
        CStr_26{end}.IO_spikeAdapt{1,1}.Ifqz{1,ii} = Fqz_CCS{i,ii};
        CStr_26{end}.IO_spikeAdapt{1,1}.Mfqz(ii) = size(Fqz_CCS{i,ii},1)+1;   
    end
end
for i = 1:size(Fqz_CS,1)
    CSp_26{end+1} = [];
    for ii = 1:size(Fqz_CCS,2)
        CSp_26{end}.IO_spikeAdapt{1,1}.Ifqz{1,ii} = Fqz_CS{i,ii};
        CSp_26{end}.IO_spikeAdapt{1,1}.Mfqz(ii) = size(Fqz_CS{i,ii},1)+1;   
    end
end



%%% THIS IS THE ACTUAL PLOTTING USING THE NEW PLOTTING FUNCTION

ISIcutoff = 5;

plotstruct.title = 'CC 26C';
plotstruct.color = [1 0 0];
subplot(2,4,1)
tgr_plot_meanIfqz(CC_26,ISIcutoff,plotstruct)

plotstruct.title = 'CSp 26C';
plotstruct.color = [1 1 0];
subplot(2,4,2)
tgr_plot_meanIfqz(CSp_26,ISIcutoff,plotstruct)

plotstruct.title = 'CStr 26C';
plotstruct.color = [0 1 0];
subplot(2,4,3)
tgr_plot_meanIfqz(CStr_26,ISIcutoff,plotstruct)

plotstruct.title = 'CTh 26C';
plotstruct.color = [0 0 1];
subplot(2,4,4)
tgr_plot_meanIfqz(CTh_26,ISIcutoff,plotstruct)

plotstruct.title = 'CC 36C';
plotstruct.color = [1 0 0];
subplot(2,4,5)
tgr_plot_meanIfqz(CC_36,ISIcutoff,plotstruct)

plotstruct.title = 'CSp 36C';
plotstruct.color = [1 1 0];
subplot(2,4,6)
tgr_plot_meanIfqz(CSp_36,ISIcutoff,plotstruct)

plotstruct.title = 'CStr 36C';
plotstruct.color = [0 1 0];
subplot(2,4,7)
tgr_plot_meanIfqz(CStr_36,ISIcutoff,plotstruct)

plotstruct.title = 'CTh 36C';
plotstruct.color = [0 0 1];
subplot(2,4,8)
tgr_plot_meanIfqz(CTh_36,ISIcutoff,plotstruct)


























%%%% MIGTH NOT BE NEEDED!!
[num,txt,raw] = xlsread('E:\NZ\TGR_current_results_sorted.xls');

ISIcutoff = 5;

typeID = unique(num(:,1));
for cell = 2:size(raw,1)
    alltypes(cell-1) = raw(cell,3);
end
type = unique(alltypes);
temp = unique(num(:,4));


for this_type = 1:size(type,2)
    type_index = strcmp(alltypes,type(this_type));
    data4plot(this_type).name = type{this_type};
    cell_count = 1;
    for cell = find(type_index==1)
        for trial = 1:size(output4mat{cell}.IO_spikeAdapt{1,1}.Ifqz,2)
            if size(output4mat{cell}.IO_spikeAdapt{1,1}.Ifqz,2) >= trial
                if size(output4mat{cell}.IO_spikeAdapt{1,1}.Ifqz{1,trial},1) >= ISIcutoff
                    data4plot(this_type).data(cell_count,trial,find(temp==raw{cell+1,5},1)) = nanmean(output4mat{cell}.IO_spikeAdapt{1,1}.Ifqz{1,trial});
                end
            end
        end
        cell_count = cell_count + 1;
    end
    data4plot(this_type).data(data4plot(this_type).data==0) = nan;
end

colortable = [1 0 0; 0 1 0;
    
figure(1)
for i = 1:size(data4plot)
subplot(size(data4plot(i).data,3),size(data4plot),1)
plot(IOsteps(1:size(data4plot(i).data,2)),data4plot(i).data,'Linewidth',2,'Color','red'); hold on
title('CC all ISI average frequencies')
xlabel('IOSteps')
ylabel('1 \\ average ISI')
ylim([0 200])











subplot(1,4,2)
plot(IOsteps(1:15),ISI1_CCS(:,1:15),'Linewidth',2,'Color','green');
title('CCS all ISI average frequencies')
xlabel('IOSteps')
ylabel('1 \\ average ISI')
ylim([0 200])
subplot(1,4,3)
plot(IOsteps(1:15),ISI1_CS(:,1:15),'Linewidth',2,'Color','blue');
title('CS all ISI average frequencies')
xlabel('IOSteps')
ylabel('1 \\ average ISI')
ylim([0 200])
subplot(1,4,4)
plot(IOsteps,ISI1_CTh(:,1:20),'Linewidth',2,'Color','black');
title('CTh all ISI average frequencies')
xlabel('IOSteps')
ylabel('1 \\ average ISI')
ylim([0 300])