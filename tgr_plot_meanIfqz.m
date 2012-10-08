function tgr_plot_meanIfqz(Inputdata,ISIcutoff,plotstruct)

if nargin < 2
    ISIcutoff = 0;
end

plotpreset.title = sprintf('mean Instantaneous Frequency of current steps with at least %d action potentials',ISIcutoff);
plotpreset.xlabel = 'Current step in nA';
plotpreset.ylabel = 'mean Instantaneous Frequency';
plotpreset.ylim = [0 200];
plotpreset.color = [0 0 1];
plotpreset.cstep_size = 50;
plotpreset.first_cstep = 50;

if nargin < 3
    plotstruct = [];
end

if ~isfield(plotstruct,'title')
    plotstruct.title = plotpreset.title;
else
    plotstruct.title = [plotstruct.title,' ',plotpreset.title]; 
end
if ~isfield(plotstruct,'xlabel')
    plotstruct.xlabel = plotpreset.xlabel;
end
if ~isfield(plotstruct,'ylabel')
    plotstruct.ylabel = plotpreset.ylabel;
end
if ~isfield(plotstruct,'ylim')
    plotstruct.ylim = plotpreset.ylim;
end
if ~isfield(plotstruct,'color')
    plotstruct.color = plotpreset.color;
end
if ~isfield(plotstruct,'cstep_size')
    plotstruct.cstep_size = plotpreset.cstep_size;
end
if ~isfield(plotstruct,'first_cstep')
    plotstruct.first_cstep = plotpreset.first_cstep;
end

IOsteps = Inputdata{1,1}.IO_spikeAdapt{1,1}.IOsteps;
for cell = 1:size(Inputdata,2)
    for trial = 1:size(Inputdata{cell}.IO_spikeAdapt{1,1}.Ifqz,2)
        if size(Inputdata{cell}.IO_spikeAdapt{1,1}.Ifqz{1,trial},1) >= ISIcutoff
            if size(Inputdata{cell}.IO_spikeAdapt{1,1}.Ifqz,2) >= trial
                data4plot(cell,trial) = nanmean(Inputdata{cell}.IO_spikeAdapt{1,1}.Ifqz{1,trial});
            else
                data4plot(cell,trial) = nan;
            end
        else
            data4plot(cell,trial) = nan;
        end
    end
    data4plot(data4plot==0) = nan;
    plot(plotpreset.first_cstep:plotpreset.cstep_size:plotpreset.cstep_size * size(data4plot,2),...
        data4plot(cell,:),'Linewidth',2,'Color',plotstruct.color); hold on
end

plotpreset.xlim = [0 plotpreset.cstep_size * size(data4plot,2)];
if ~isfield(plotstruct,'xlim')
    plotstruct.xlim = plotpreset.xlim;
end

title(plotstruct.title)
xlabel(plotstruct.xlabel)
ylabel(plotstruct.ylabel)
ylim(plotstruct.ylim)
xlim(plotstruct.xlim)
