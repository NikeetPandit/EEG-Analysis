% --- Function Summary --- %
% Function reads in an EDF file specified by its path and where its stored.
% Then it time stamps the data assuming an even sample rate because the way 
% data is given is such that each second has 256 samples. 
% i.e, 0 seconds has 256 samples and so fourth

% Inputs
% 1. path: Path for where data is stored... end with a '/'

% path example: path = append(pwd, '/', 'EEG-Data', '/'); 
% (pwd function just gets current directory) 

% 2. Data_File_String: 'String of data file to read including extension 
% Data_File_String example: Data_File_String = 'chb01_01.edf'; % in strings

% data = read_data(path, Data_File_String); % call funciton like this...

% ******** I reccommend placing all the data into one folder and remove the subfolders ******** %

% Outputs 
%1 Datastruct: Statistically meaningful channels ONLY of all channels with time-tag
% ['P3_O1', 'FP2_F8', 'P8_O2', 'P7_T7', 'T7_FT9', 'FT10_T8']
% Described in Jana, Ranjan, and Imon Mukherjee. "Deep Learning Based Efficient 
% Epileptic Seizure Prediction with EEG Channel Optimization.” Biomedical signal processing and control 68 (2021): 102767–.

% Code written by Nikeet Pandit

function [datastruct] = read_data(path, Data_File_String)

%--- Read in data file (in this example 'chb01_01.edf'
dataIn = edfread(append(path, Data_File_String)); %--- DataIn refers to the orignal edg

%--- Extract variable names from data
VarNames = dataIn.Properties.VariableNames; 

%--- Extract index of the informative channels
[ind_extract, chnl_inform] = extract_informative_channels(VarNames);

%--- Extract informative channels only 

for i = 1:length(ind_extract)
    dataOut{i} = (timetable2table(dataIn(:,ind_extract(i)))); %--- DataOut refers to the informative channels only 
end

for i = 1:length(ind_extract)
    dataOut{2,i} = upper(chnl_inform{i});
end

%--- Put data into columns for data and time 
temp = []; 
temp1 = []; 
len = length(dataOut); 
for j = 1:len
    [m, ~] = size(dataOut{1,j});
    for i = 1:m
        temp = [temp; cell2mat(table2array(dataOut{1,j}(i,2)))];
    end
    dataOut{3,j} = temp; 
    temp = []; 
end

for i = 1:len
    if mod(length(dataOut{3,i}), 256) ~= 0
        warning("This is most probably an error with the time stamping of this data. Please investigate."); 
    end
end

%--- Make time stamsp since its not given linearly interpolating each time stamp 
% since its impossible for 256 measurements to be taken at 0 sec for example... therefore assuming
% ~even sample rate
for i = 1:len
    time_vector_start_stop(:,i) = [seconds(table2array(dataOut{1,i}(1,1))) seconds(table2array(dataOut{1, i}(end,1)))]; 
end

if numel(unique(time_vector_start_stop(1,:))) ~= numel(unique(time_vector_start_stop(2,:)))
    warning("This is most probably an error with the time stamping of this data. Please investigate."); 
end

for i = 1:len
    time(:,i) = linspace(time_vector_start_stop(1,1), time_vector_start_stop(2,1), length(dataOut{3,i})); 
end

for i = 1:len
    dataOut{4,i} = time(:,i); 
end

for i = 1:len
    if length(dataOut{3,i}) ~= length(dataOut{4,j})
        warning("There is 100% an error in the time stamping of this data. Investigate"); 
    end
end

for i = 1:len
    time(:,i) = dataOut{4,i}; 
    data(:,i) = dataOut{3,i}; 
end

% Each column refers to channel ['P3_O1', 'FP2_F8', 'P8_O2', 'P7_T7', 'T7_FT9', 'FT10_T8']

for i = 1:2:len
    if ~isequal(time(:,i), time(:,i+1))
        error("Time vectors are all not equal. Something is not valid with equal sampling assumption. See note at top of function."); 
    end
end


datastruct.P3_01 = data(:,1); 
datastruct.FP2_F8 = data(:,2); 
datastruct.P8_02 = data(:,3); 
datastruct.P7_T7 = data(:,4); 
datastruct.T7_FT9 = data(:,5); 
datastruct.FT10_T8 = data(:,6); 
datastruct.time = time(:,1); 

end

function [ind_extract, chnl_string_to_extract] = extract_informative_channels(var_names)

var_names = lower(var_names); 
chnl_string_to_extract = lower({'P3_O1', 'FP2_F8', 'P8_O2', 'P7_T7', 'T7_FT9', 'FT10_T8'}); 

for i = 1:length(chnl_string_to_extract)   
    temp_var{i} = strfind(var_names, chnl_string_to_extract{i}); 
end

for i = 1:length(temp_var)  
    temp_var{i}(cellfun('isempty',temp_var{i})) = {NaN};
end

for i = 1:length(temp_var)
    temp_var{i} = cell2mat(temp_var{i}); 
end

for i =1:length(temp_var)
    ind_extract(i) = find(temp_var{i} > 0);
end
end













