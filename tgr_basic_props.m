function basic_properties = tgr_basic_props(all_cells,Inputparameter,show_single_epis,show_average_section)

%%% This function calculates the basic properties RMP (resting membrane
%%% potential), Rm (membrane resistance), Cm (membrane capacitance) and the
%%% timeconstant, using the dataformat of tgr_loadData2 and the
%%% Inputparameters loaded with tgr_infof2struct.
%%% 
%%% Inputs:
%%% all_cells -> list of recorded-cells, load using tgr_loadData2
%%% Inputparameter -> list of experiment parameters for each recorded-cell
%%%     the order and dimensions have to match the all_cells array.
%%% show_single_epis -> 'yes' or 'no', specifies wether to show each trace
%%%     or not. Default is 'no'.
%%% show_average_section -> 'yes' or 'no', specifies wether to show the 
%%%     averaged traces or not. Default is 'yes'.

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
doublexp='k(1)*exp(-x/k(2))+k(3).*exp(-x./k(4))+k(5)';
myfun=inline(doublexp, 'k','x');
% kinit=[1,0.02,-1.5, 0.7,0.01];
options = statset('MaxIter',1000);

for i = 1:max(length(all_cells))
    % if all_cells{i}.name == Inputparameter{i}.expName
    % Notch filter settings
    Order = 3;
    Wn1 = [40/(Inputparameter{i}.Fs/2) 60/(Inputparameter{i}.Fs/2)];
    [b1 a1] = butter(Order,Wn1,'stop');
    % % Analyse Test pulse states for RMP and Rm
    clear dS timebases Peakbin xdata ydata yFit PeakVm NormdS NormVm TestVm
    for trial = 1:length(Inputparameter{i}.state{1})
        dS(:,trial) = all_cells{i}.dS(:,Inputparameter{i}.state{1}(trial));
        timebases = all_cells{i}.timebases;
        if strcmp(show_single_epis,'yes')
            h = figure(3);
            plot(timebases,dS(:,trial));
            title(['Testpulse episode ' int2str(trial) ' not filtered']);
        end
    end
    TestVm = mean(dS,2);
    basic_properties{i}.RMP = mean(TestVm(Inputparameter{i}.Baseline(1):Inputparameter{i}.Baseline(2)));
    NormdS = dS - mean(TestVm(Inputparameter{i}.Baseline(1):Inputparameter{i}.Baseline(2))); % basic_properties{i}.RMP;
    NormVm = mean(NormdS,2);
    PeakVm = min(NormVm(Inputparameter{i}.Teststart:Inputparameter{i}.Testend));
    basic_properties{i}.Rm = PeakVm / Inputparameter{i}.TestI*1000;
    Peakbin = find(NormVm(Inputparameter{i}.Teststart:Inputparameter{i}.Testend) == PeakVm,1) + Inputparameter{i}.Teststart-1;
    xdata = timebases(Inputparameter{i}.Teststart:Peakbin);
    ydata = NormVm(Inputparameter{i}.Teststart:Peakbin)';
    kinit=[1,0.02,PeakVm-Inputparameter{i}.InitOffset, 0.7,0.01];
    [k]=nlinfit(xdata,ydata,myfun,kinit,options);
    yFit=myfun(k,xdata);
    basic_properties{i}.Timeconst = k(2)*1000;
    basic_properties{i}.Cm = basic_properties{i}.Timeconst/basic_properties{i}.Rm*1000;
    if strcmp(show_average_section,'yes')
        f = figure(1);
        set(f,'color','w');
        plot(timebases,NormVm,'b'); hold on
        plot(xdata,yFit,'g'); hold on
        %set(gca,'XLim',[0.32 0.52]);
        xlabel('Time (sec)')
        ylabel('Potential (mV)')
        legend('Test1','Fit1','Location','NorthEast');
        title(['Testpulse for cell ' Inputparameter{i}.expName]);
    end
    hold off
    basic_properties{i}.peakVm = PeakVm;
    basic_properties{i}.trial = Inputparameter{i}.state{1};
    basic_properties{i}.Peakbin = Peakbin;
end



