function Inputparameter = tgr_infof2struct(info_fpath,info_fname)
%%% This function converts the info files for cfs data analysis into a
%%% structure variable that is equal the 'Inputparameter' variable requested by the tgr_XXX functions
%%% for data-analysis.
%%% Inputs: 
%%% info_fpath -> the path including the filename 
%%% on windows filepath = 'X:\path\filename.m' 
%%% on unix filepath = '/home/path/filename.m'
%%% This variable has to be a cell array of strings, so that multiple files can be read in.
%%% info_fname -> this variable was supposed to connect the Infoparameters with the data and will be removed


if nargin<1
    fpaths = uipickfiles;
    for i = 1:size(fpaths,2)
        info_fpath{i} = fpaths{i}(1:max(strfind(fpaths{i},'/')));
        info_fname{i} = fpaths{i}(max(strfind(fpaths{i},'/'))+1:end-2);
    end
end

if length(info_fpath) == length(info_fname)    
    for i = 1:length(info_fpath)
        cd(info_fpath{i});
        eval(info_fname{i});        
        %Inputparameter{i}.day = day;
        Inputparameter{i}.expName = neuron;
        Inputparameter{i}.IVsteps20 = IVsteps20;
        Inputparameter{i}.IVsteps50 = IVsteps50;
        Inputparameter{i}.Basic = Basic;
        Inputparameter{i}.IV20steps = IV20steps;
        Inputparameter{i}.IV50steps = IV50steps;
        Inputparameter{i}.AP20epis = AP20epis;
        Inputparameter{i}.AP50epis = AP50epis;
        Inputparameter{i}.state{1} = state{1};
        Inputparameter{i}.state{2} = state{2};
        Inputparameter{i}.state{3} = state{3};
        Inputparameter{i}.state{4} = state{4};
        Inputparameter{i}.state{5} = state{5};
        Inputparameter{i}.state{6} = a0;
        Inputparameter{i}.APepis = APepis;
        for j = 1 : length(AHP)
        Inputparameter{i}.AHP{j} = AHP{j};
        end
        Inputparameter{i}.AHPsteps = AHPsteps;
        Inputparameter{i}.Fs = Fs;
        Inputparameter{i}.Ms = Ms;
        Inputparameter{i}.Baseline = Baseline;
        Inputparameter{i}.IVbaseline = IVbaseline;
        Inputparameter{i}.sAHPbaseEnd = sAHPbaseEnd;
        Inputparameter{i}.sAHPstart = sAHPstart;
        Inputparameter{i}.sAHPend = sAHPend;
        Inputparameter{i}.IO_start = IO_start;
        Inputparameter{i}.IO_end = IO_end;
        Inputparameter{i}.Teststart = Teststart;
        Inputparameter{i}.Testend = Testend;
        Inputparameter{i}.TestI = TestI;
        Inputparameter{i}.IVstart = IVstart;
        Inputparameter{i}.IVstart =IVstart;
        Inputparameter{i}.IHstart =IHstart;
        Inputparameter{i}.IVend = IVend;
        Inputparameter{i}.IV50start = IV50start;
        Inputparameter{i}.IV20start = IV20start;
        Inputparameter{i}.IH50start = IH50start;
        Inputparameter{i}.IH20start = IH20start;
        Inputparameter{i}.IV50end = IV50end;
        Inputparameter{i}.IV20end = IV20end;
        Inputparameter{i}.IVsteps = IVsteps;
        Inputparameter{i}.IOsteps= IOsteps;
        Inputparameter{i}.Ri_steps = Ri_steps;
        Inputparameter{i}.Ri50steps = Ri50steps;
        Inputparameter{i}.AP_slope_threshold = AP_slope_threshold;
        Inputparameter{i}.AP_spike_threshold = AP_spike_threshold;
        Inputparameter{i}.a0 = a0;
    end
else
    disp('Dimensions of file and folder list don''t match!');
end
