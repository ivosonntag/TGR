function [fhandle,cfs_info] = loadCFS4tgr01(fullfilename)

% loadCFSdata.m
% generic CFS data loading file (adapted from loadCFSfile.m)
% 27.10.11: version 1, MJO
% requires MATCFS32.DLL AND CFS32.DLL

% CFS constants
INT1=0;
WRD1=1;
INT2=2;
WRD2=3;
INT4=4;
RL4=5;
RL8=6;
LSTR=7;
EQUALSPACED=0;
MATRIX=1;
SUBSIDIARY=2;
FILEVAR=0;
DSVAR=1;
READONLY=0;
WRITE=1;

%[shortname, cfsdir]=uigetfile({'*.cfs','CFS files (*.cfs)'}, 'Choose a file to load');

[fhandle]=MATCFS32('cfsOpenFile',fullfilename,0,0);

if (fhandle >=0)
    [cfs_info.time,cfs_info.filedate,cfs_info.comment]=MATCFS32('cfsGetGenInfo',fhandle);
    [cfs_info.channels,cfs_info.fileVars,cfs_info.DSVars,cfs_info.data_Sections]=MATCFS32('cfsGetFileInfo',fhandle);
    cfs_info.dataKinds=[];
    cfs_info.dataTypes=[];
    for j=1:cfs_info.channels
        [cfs_info.channelName,cfs_info.yUnit,cfs_info.xUnit,cfs_info.dataType,cfs_info.dataKind,cfs_info.spacing,cfs_info.other]=MATCFS32('cfsGetFileChan',fhandle,j-1);
        eval(['cfs_info.yUnit' int2str(j-1) '=cfs_info.yUnit;']);
        eval(['cfs_info.xUnit' int2str(j-1) '=cfs_info.xUnit;']);
        eval(['cfs_info.chName' int2str(j-1) '=cfs_info.channelName;']);
        cfs_info.dataKinds=[cfs_info.dataKinds cfs_info.dataKind];
        cfs_info.dataTypes=[cfs_info.dataTypes cfs_info.dataType];
    end
    % this part like simpler.c
    disp(['File information:']);
    disp([fullfilename ' (created on ' cfs_info.filedate ' at ' cfs_info.time ')']);
    if  ~(isempty(cfs_info.comment))
        disp(['comment: ' cfs_info.comment]);
    end
    disp([int2str(cfs_info.fileVars) ' file variable(s)' ]);
    disp([int2str(cfs_info.DSVars) ' data section variable(s)']);
    disp([int2str(cfs_info.data_Sections) ' data section(s)']);
    disp([int2str(cfs_info.channels) ' channel(s): ']);
    for j=1:cfs_info.channels
        cfs_info.chName=[];
        eval(['cfs_info.chanN = cfs_info.chName' int2str(j-1) ';']);
        disp(['Chan' int2str(j-1) ' is ' cfs_info.chanN]);
    end
    %    disp('paused');
else
    disp(['fhandle not valid = ' int2str(fhandle)]);
    return
end


cfs_info.pointsArr=[];
cfs_info.yScales=[];
cfs_info.yOffsets=[];
cfs_info.xScales=[];
cfs_info.xOffsets=[];
for j=1:cfs_info.channels
    [cfs_info.startOffset,cfs_info.points,cfs_info.yScale,cfs_info.yOffset,cfs_info.xScale,cfs_info.xOffset]=MATCFS32('cfsGetDSChan',fhandle,j-1,1);
    cfs_info.pointsArr=[cfs_info.pointsArr cfs_info.points];
    cfs_info.yScales=[cfs_info.yScales cfs_info.yScale];
    cfs_info.yOffsets=[cfs_info.yOffsets cfs_info.yOffset];
    if cfs_info.dataKinds(j)==EQUALSPACED
        cfs_info.xScales=[cfs_info.xScales cfs_info.xScale];
        cfs_info.xOffsets=[cfs_info.xOffsets cfs_info.xOffset];
    else
        cfs_info.xScales=[cfs_info.xScales 1];
        cfs_info.xOffsets=[cfs_info.xOffsets 0];
    end
    % check for matrix type channels
end % for j=

ch=0;
for n=1:cfs_info.channels
    if cfs_info.dataKinds(n)==0   % implies equalspaced, OK
        ch=ch+1;
    end
end    % for n

cfs_info.chVec=[0]; % Channel vectors to read (0 first) e.g [0 1] for Vm & Icomd
cfs_info.dS=[];
cfs_info.timebases=[];