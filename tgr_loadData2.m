function all_cells = tgr_loadData2(filepath,expName)

%%% This function is based on Manfred Oswald's analysis and parsing script,
%%% dealing with the CFS data in Ruth Empsons lab (University of Otago) and
%%% has been rewritten by Ivo Sonntag. It depends on the ....
%%% 
%%% Inputs:
%%% filepath -> the path including the filename 
%%% on windows filepath = 'X:\path\filename.cfs' 
%%% on unix filepath = '/home/path/filename.cfs'
%%% This variable has to be a cell array of strings, so that multiple files can be read in.
%%% The function assumes rows of the cell array to contain recordings from different cells, so that each colum of 
%%% a row will be treated as part of one cell and the data will be concatanated. The data inputed will be 
%%% transposed, so that the longest dimension is assumed to be the rows.
%%%
%%% expName -> just a simple string, so the files can later be identified easier
%%%
%%% If no experiment Name is specified, the exName variable will be set to 'random'.
%%% If no directory is specified, a gui is provided (uigetfiles.m Copyright (c) 2007, Douglas M. Schwarz), 
%%% so that a list of files can be picked. This does not support concatanation of recordings.
%%%
%%% Outputs: 
%%% The output is a {1 by number of input rows} cell array for each cell-recording/row. This cell contains a 
%%% structure with 5 fields. 
%%% {1,1}.name is equal to the specified Experiment Name
%%% {1,1}.rawdata is an (m,n) array with length of m corresponding to the number of data samples (1 second of 20KiloHz 
%%%     sampling frequency will return an m of length 20000), and n with a length of the Input cell-recordings/rows.
%%% {1,1}.dS has the same dimensions as {1,1}.rawdata, but reflects the scaled Output that has been corrected 
%%%     for it's offset -> this is the actual Data in mV. Note, that m does not reflect miliseconds but is scaled to
%%%     the sampling frequency (if 20KiloHz one bin is equal to 50 milliseconds)
%%% {1,1}.timebases is an (m,n) array that has the same size as rawdata/dS. Each value corresponds to the millisecond in 
%%% which the same value was sampled in rawdata/dS. It can be used to provide a y-scale when plotting the data.
%%% {1,1}.cfs_info is a structure containing the cfs files basic information. It's created by MATCFS32 (add (c)), 
%%% refer to the MATCFS32 documentation for further information.  
%%% 
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



