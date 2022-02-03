%% Script to import data 
% August 2021
% Aim of the script: Import the EEG recording pre intervention

%Set up the working directory by specifying the paths and extracting the
%files that will be needed (i.e. layout files, subjects info etc.)
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration


%% Set up a loop to import all data 
% This will import data into a Fieldtrip format 

for k=1:length(subjects)
    
    %Progress message - prints a message every time it starts working on a
    %new subject
    fprintf('Working on %s', subjects(k).sub)
    
    %Paths for participant data
    datapath = subjects(k).raw_data ;
    cd(datapath);
    
    %Files
    currentFolder = dir; %list files in the subject's folder
    
    %Data
    datafile_pre = dir('*before*.bdf'); 
    datafile_pre = datafile_pre.name; %this is the name of the pre intervention file
    
    
    
    %% Import the pre intervention file
    
    %specify the data header
    hdr = ft_read_header(datafile_pre);

    cfg                         = [];
    cfg.dataset                 = datafile_pre; %name of the dataset
    cfg.trialfun                = 'ft_trialfun_general'; % this is the default
    cfg.trialdef.eventtype      = 'STATUS'; %this is what biosemi calls the events
    cfg.trialdef.eventvalue     = [100 200]; % the values of the stimulus trigger for b(100) and d (200) letters
    cfg.trialdef.prestim        = 1; % time in seconds
    cfg.trialdef.poststim       = 2; % time in seconds

    cfg = ft_definetrial(cfg);  %make sure that the trials are going to be defined

    cfg.channel = 'eeg'; %select only eeg channels - the recording has some reduntant "channels"
    mydata_pre = ft_preprocessing(cfg);

    %% Save the data ready for preprocessing
    FileName = [subjects(k).sub, '_step1_pre_imported.mat']; %create a new file name based on subject number
    outputpath = subjects(k).folder_baseline; %save in the right folder
    
    save(fullfile(outputpath, FileName), 'mydata_pre')
    clear FileName
    
end 

