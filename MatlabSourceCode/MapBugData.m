%% ===================MAPPING BUG RAW DATA==============
close('all');
clear;

% MAPPING
% load raw datasets
fid=fopen('/Users/Shariful/Documents/BugDataKorosh/Dataset/Gnome/StatusReassigned');
tline = fgetl(fid);

% initialize dictionary
mapObj = containers.Map('KeyType','char','ValueType','double');
allSeq = cell(1,1);
count = 0;
keyFlag = length(mapObj)+1;

% TRACING FILES
while ischar(tline) 
    words = textscan(tline,'%s');
    words = words{1,1}(1:end-1,:);
    words = words';
    
    unqwrd = unique(words);
    tf = isKey(mapObj,unqwrd);
    newKeys = unqwrd(1,~tf);
    if(~isempty(newKeys))
        newVals = keyFlag:keyFlag+length(newKeys)-1;
        newMap = containers.Map(newKeys,newVals);
        mapObj = [mapObj; newMap];
        keyFlag = newVals(end)+1;
    end
    
    seq = values(mapObj, words);
    count = count + 1;
    allSeq{count,1} = cell2mat(seq);
    
    tline = fgetl(fid); %reading next line
    sprintf('processed %d sequences, MapSize:%d & MaxKeyVal:%d', count, length(mapObj),keyFlag-1)
end
fclose(fid);

% saving mapping sequences and dictionary
save('/Users/Shariful/Documents/BugReAssgn/PreparedData/Gnome/OriginalSeqDataset/Status/StatusReAsgnd.mat', 'allSeq');
save('/Users/Shariful/Documents/BugReAssgn/PreparedData/Gnome/OriginalSeqDataset/Status/MapKeysVals_Status.mat', 'mapObj');
