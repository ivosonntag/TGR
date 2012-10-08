function tgr_plot_fqzFit(Inputdata,plotstruct)

plotpreset.title = sprintf('mean Instantaneous Frequency of current steps with at least %d action potentials',ISIcutoff);
plotpreset.xlabel = 'Current step in nA';
plotpreset.ylabel = 'mean Instantaneous Frequency';
plotpreset.ylim = [0 200];
plotpreset.color = [0 0 1];

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

IOsteps = Inputdata{1,1}.IO_spikeAdapt{1,1}.IOsteps;

plotcount = 1;
for i=1:size(Inputdata,2)
    freq = Inputdata{i}.IO_spikeAdapt{1,1}.Mfqz;
    sigmoidstring = 'k(1)./(1+exp((k(2)-I)./k(3)))';
    myfun = inline(sigmoidstring, 'k','I');
    Isteps = [1:1:1000];
    [k,rsig] = nlinfit(IOsteps(1:size(freq,2)),freq,myfun, [100 100 40]);
    ISI1_r{i} = rsig;
    yFit = myfun(k,Isteps);
    I50(i) = k(2);
    Fmax(i) = k(1);
    [index] = find(yFit>0.25*Fmax(i) & yFit<0.75*Fmax(i));
    statssig = regstats(yFit(index),Isteps(index),'linear',{'yhat' 'beta' 'rsquare' 'fstat'});
    FIfitsig = statssig.yhat;
    FIslopesig(i) = statssig.beta(2);
    FIx0sig(i) = statssig.beta(1);
    FIr2sig(i) = statssig.rsquare;
    FIpsig(i) = statssig.fstat.pval;
    statslin = regstats(freq,IOsteps(1:size(freq,2)),'linear',{'yhat' 'beta' 'rsquare' 'fstat' 'r'});
    FIfitlin = statslin.yhat';
    FIslopelin(i) = statslin.beta(2);
    FIx0lin(i) = statslin.beta(1);
    FIr2lin(i) = statslin.rsquare;
    FIplin(i) = statslin.fstat.pval;
    rlin = statslin.r';
    subplot(1,size(Inputdata,2),plotcount)
    plotcount = plotcount + 1;
    plot(IOsteps(1:size(freq,2)),freq,'.'); hold on
    if nansum(rsig.^2) > nansum(rlin.^2)
        plot(IOsteps(1:size(freq,2)),FIfitlin, 'r-');
        all_gain(i) = FIslopelin(i);
        %[value currentstep] = min(abs(allfreq{type}(i,:)-max(allfreq{type}(i,:))/2));
        all_threshold(i) = NaN;
        all_max(i) = NaN;
    else
        plot(Isteps,yFit); hold on
        plot(Isteps(index),FIfitsig, 'r-'); hold off
        all_gain(i) = FIslopesig(i);
        all_max(i) = max(yFit);
        [value currentstep] = min(abs(yFit-(max(yFit)*0.5)));
        %[value IOSTEP] = min(abs(IOsteps-currentstep));
        all_threshold(i) = currentstep;
    end
end
