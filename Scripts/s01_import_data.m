%% Script to import data 
% August 2021
% Aim of the script: Import both pre and post intervention EEG recoding files for preprocessing

%Set up the working directory by specifying the paths and extracting the
%files that will be needed (i.e. layout files, subjects info etc.)
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Scripts');
configuration

%% Tools
% These can be used at any point to check through the data, the lines will

% Vertical plot
%cfg             = [];
%cfg.plotlabels  = 'yes';
%cfg.layout      = layout_file; 
%cfg             = ft_databrowser(cfg, mydata_pre);

%% Set up a loop to import all data 
% This will import data into a Fieldtrip format - make all necessary
% adjustments to the data to start pre-processing as the next step
% In this case, I will import all data already divided into trials

for k=23:length(subjects)
    
    %Loop Iteraction - prints a message every time it starts working on a
    %new subject
    fprintf('Working on %s', num2str(subjects(k).name))
    
    %Paths for participant data
    datapath = subjects(k).folder ;
    outputpath = ('C:\Users\dqz718\Desktop\b_d_EEG\Analyses\Data\Qual_Figs');
    cd(datapath);
    
    %Files
    currentFolder = dir; %list files in the subject's folder
    
    %Data
    datafile_pre = dir('*pre*.bdf'); 
    datafile_pre = datafile_pre.name; %this is the name of the pre intervention file
    
    datafile_post = dir('*post*.bdf'); 
    datafile_post = datafile_post.name; %this is the name of the post intervention file
    
    FileName = [num2str(subjects(k).name), '_', subjects(k).int, '.bdf'];
    datafile_int = dir(FileName); 
    datafile_int = datafile_int.name; %this is the name of the intervention file
    
    
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
    FileName = [num2str(subjects(k).name), '_imported_pre.mat']; %create a new file name based on subject number
    save(fullfile(datapath, FileName), 'mydata_pre')
    clear FileName
  
        
   %% Import the post intervention file
    
    %specify the data header
    hdr = ft_read_header(datafile_post);

    cfg                         = [];
    cfg.dataset                 = datafile_post; %name of the dataset
    cfg.trialfun                = 'ft_trialfun_general'; % this is the default
    cfg.trialdef.eventtype      = 'STATUS'; %this is what biosemi calls the events
    cfg.trialdef.eventvalue     = [100 200]; % the values of the stimulus trigger for b(100) and d (200) letters
    cfg.trialdef.prestim        = 1; % time in seconds
    cfg.trialdef.poststim       = 2; % time in seconds

    cfg = ft_definetrial(cfg);  %make sure that the trials are going to be defined

    cfg.channel = 'eeg'; %select only eeg channels - the recording has some reduntant "channels"
    mydata_post = ft_preprocessing(cfg);

    %% Save the data ready for preprocessing
    FileName = [num2str(subjects(k).name), '_imported_post.mat']; %create a new file name based on subject number
    save(fullfile(datapath, FileName), 'mydata_post')
    clear FileName
    
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
    FileName = [num2str(subjects(k).name), '_imported_int.mat']; %create a new file name based on subject number
    save(fullfile(datapath, FileName), 'mydata_int')
    clear FileName
    
end 

