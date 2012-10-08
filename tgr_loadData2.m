function all_cells = tgr_loadData2(filepath,expName)

%%% This function is based on Manfred Oswald's analysis and parsing script,
%%% dealing with the CFS data in Ruth Empsons lab (University of Otago) and
%%% has been rewritten by Ivo Sonntag. It depends on the ....
%%% 
%%% Inputs:
%%%
%%% Outputs:
%%%
if (nargin<1 || isempty(filepath)) 
    tgr_filelist = uipickfiles';
else 
    tgr_filelist = filepath;
end
if nargin<2
    expName = 'random';
end


%%% predefine the cell array that will carry the data
all_cells = cell(1,size(tgr_filelist,1));

%%% Check the filelist dimension, if the cells are not sorted row-wise, dimensions are flipped.
%%% The function assumes the number of total cells is higher, than the
%%% number of single files per individual cell.

if size(tgr_filelist,1)<size(tgr_filelist,2)
    tgr_filelist = tgr_filelist';
end

for cellnum = 1:size(tgr_filelist,1)    
    trial_count = 0;
    for filenum = 1:size(tgr_filelist,2)
        if ~isempty(tgr_filelist{cellnum,filenum})
            all_cells{cellnum}.name = [expName,sprintf('n%d',cellnum)];
            [fhandle,cfs_info] = loadCFS4tgr01(tgr_filelist{cellnum,filenum});
            %%% Loop through each data_Section that was found in the given file. The number of
            %%% data_Sections should correspond to the number of current
            %%% steps used.
            for trial=1:cfs_info.data_Sections
                trial_count = trial_count+1;
                rawdata = MATCFS32('cfsGetChanData',fhandle,cfs_info.chVec,trial,0,cfs_info.pointsArr(1),cfs_info.dataTypes(1));
                dS = cfs_info.yScales(1)*rawdata+cfs_info.yOffsets(1);
                z=1:cfs_info.pointsArr(1)';
                timebases = cfs_info.xScales(1)*z+cfs_info.xOffsets(1);
                %%% the next lines write the traces into the output array, 
                %%% the steps are separated to retain readability
                all_cells{cellnum}.rawdata(:,trial_count) = rawdata;
                all_cells{cellnum}.dS(:,trial_count) = dS;
                all_cells{cellnum}.timebases(:,trial_count) = timebases;
            end
            all_cells{cellnum}.cfs_info = cfs_info;
        end
    end
end



