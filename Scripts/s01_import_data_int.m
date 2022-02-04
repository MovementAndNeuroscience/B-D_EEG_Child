%% Script to import data 
% August 2021
% Aim of the script: Import intervention EEG recoding files for preprocessing

%Set up the working directory by running the configuration

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration


%% Set up a loop to import all data 
% This will import data into a Fieldtrip format - make all necessary
% adjustments to the data to start pre-processing as the next step
% In this case, I will import all data already divided into trials

% Do not import data for sub-07 and sub-17 which were excluded at the
% baseline


for k=1:length(subjects)
    %skip the participants who were identified for removal from the
    %baseline
    
    if subjects(k).included == 0
       continue
    end

        
    %Progress message - prints a message every time it starts working on a
    %new subject
    fprintf('Working on %s', subjects(k).sub)
    
    %Path for participant data 
    datapath = subjects(k).raw_data ;
    cd(datapath);
    
    %Files
    currentFolder = dir; %list files in the subject's folder
    
    %Data
    FileName = [num2str(subjects(k).sub), '_int.bdf'];
    datafile_int = dir(FileName); 
    datafile_int = datafile_int.name; %this is the name of the intervention file
    
    
   
    
    %% Import the intervention file
    
    %specify the data header
    hdr = ft_read_header(datafile_int);

    cfg                         = [];
    cfg.dataset                 = datafile_int; %name of the dataset
    cfg.trialfun                = 'ft_trialfun_general'; % this is the default
    cfg.trialdef.eventtype      = 'STATUS'; %this is what biosemi calls the events
    cfg.trialdef.eventvalue     = [100 200]; % the values of the stimulus trigger for b(100) and d (200) letters
    cfg.trialdef.prestim        = 1; % time in seconds
    cfg.trialdef.poststim       = 2; % time in seconds

    cfg = ft_definetrial(cfg);  %make sure that the trials are going to be defined

    cfg.channel = 'eeg'; %select only eeg channels - the recording has some reduntant "channels"
    mydata_int = ft_preprocessing(cfg);

    %% Save the data ready for preprocessing
    FileName = [subjects(k).sub, '_step1_int_imported.mat']; %create a new file name based on subject number
    outputpath = subjects(k).folder_int; %save in the right folder
    
    save(fullfile(outputpath, FileName), 'mydata_int')
    
    clear FileName
   
    
end 



