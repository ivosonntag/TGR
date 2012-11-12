function IV_curve_Ri_Ih = tgr_IV_curve_Ri_Ih(all_cells,Inputparameter,show_single_epis,show_average_section)

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

IV_curve_Ri_Ih = cell(1,length(all_cells));

for i = 1:max(length(all_cells))
    %if all_cells{i}.name == Inputparameter{i}.expName
        % Notch filter settings
        Order = 3;
        Wn1 = [40/(Inputparameter{i}.Fs/2) 60/(Inputparameter{i}.Fs/2)];
        [b1 a1] = butter(Order,Wn1,'stop');
        % Savitzky-Golay filter
        smoothwinL = 0.5;     % (ms)
        order = 1;
        binwidth = ceil(smoothwinL/1000*Inputparameter{i}.Fs);
        if mod(binwidth,2) == 0
            [~,g] = sgolay(order,binwidth-1);
        else
            [~,g] = sgolay(order,binwidth);
        end
        lg = size(g(:,2),1);
        extrabins = floor(lg/2); % delay caused by filtering, in bins
        % % Plot I-V curve and calculate Ri & Ih
        for trial = 1:size(Inputparameter{i}.state{3},2)
            data = filtfilt(b1,a1,all_cells{i}.rawdata(:,Inputparameter{i}.state{3}(trial)));
            sgSignal = filter(g(:,1),1,data);
            sgSignal = [sgSignal(lg)*ones(extrabins,1); sgSignal(lg:end); sgSignal(end)*ones(extrabins,1)];
            dS = all_cells{i}.cfs_info.yScales(1) * sgSignal + all_cells{i}.cfs_info.yOffsets(1);
            timebases = all_cells{i}.timebases;
            BaseVm(:,trial) = mean(dS(Inputparameter{i}.Baseline(1):Inputparameter{i}.Baseline(2)));
            if trial <= 10
                if find(dS(Inputparameter{i}.IVstart:Inputparameter{i}.IVend) == -100,1)
                    PeakVm(:,trial) = NaN;
                    IhVm(:,trial) = NaN;
                else
                    PeakVm(:,trial) = min(dS(Inputparameter{i}.IVstart:Inputparameter{i}.IVend));
                    IhVm(:,trial) = mean(dS(Inputparameter{i}.IHstart:Inputparameter{i}.IVend));
                end
                Vpeak(:,trial) = PeakVm(:,trial) - BaseVm(:,trial);
                IhV(:,trial) = IhVm(:,trial) - BaseVm(:,trial);
                Vsag(:,trial) = Vpeak(:,trial) - IhV(:,trial);
                Ihsag(:,trial) = Vsag(:,trial) / IhV(:,trial);
            elseif trial == 11
                PeakVm(:,trial) = mean(dS(Inputparameter{i}.IVstart:Inputparameter{i}.IVend));
                Vpeak(:,trial) = PeakVm(:,trial) - BaseVm(:,trial);
            else
                PeakVm(:,trial) = max(dS(Inputparameter{i}.IVstart:Inputparameter{i}.Fs));
                if PeakVm(:,trial) < -20
                    Vpeak(:,trial) = PeakVm(:,trial) - BaseVm(:,trial);
                else
                    Vpeak(:,trial) = NaN;
                end
            end            
            if strcmp(show_single_epis,'yes')
                h = figure(6);
                plot(timebases,dS); hold on
                title(['I-V episode ' int2str(trial) ', cell: ' Inputparameter{i}.expName]);
                %pause(0.2)
            end
        end
        stats = regstats(Vpeak(Inputparameter{i}.Ri_steps),Inputparameter{i}.IVsteps(Inputparameter{i}.Ri_steps),'linear',{'yhat' 'beta' 'rsquare' 'fstat'});
        IVfit = stats.yhat;
        IVslope = stats.beta(2);
        IVx0 = stats.beta(1);
        IVr2 = stats.rsquare;
        IVp = stats.fstat.pval;
        if strcmp(show_average_section,'yes')
            f = figure(5);
            set(f,'color','w');
            plot(Inputparameter{i}.IVsteps,Vpeak, 'k.'); hold on
            plot(Inputparameter{i}.IVsteps(Inputparameter{i}.Ri_steps),IVfit, 'r'); hold off
            %set(gca,'xLim',[-200 100],'ylim',[-60 40]);
            ylabel('Peak potential (mV)');
            xlabel('Step current (pA)');
            title(['I-V curve of cell ' Inputparameter{i}.expName]);
        end
        IV_curve_Ri_Ih{i}.Ih = nanmean(Ihsag(1:5));
        IV_curve_Ri_Ih{i}.Ri = IVslope * 1000;
        IV_curve_Ri_Ih{i}.PeakVm = PeakVm;
        IV_curve_Ri_Ih{i}.Vpeak = Vpeak;
        IV_curve_Ri_Ih{i}.IhV = IhV;
        IV_curve_Ri_Ih{i}.IhVm = IhVm;
        IV_curve_Ri_Ih{i}.Vsag = Vsag;
        IV_curve_Ri_Ih{i}.Ihsag= Ihsag;
        hold off
    %end
end
