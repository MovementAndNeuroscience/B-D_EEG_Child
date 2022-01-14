%% Preprocessing pipeline
% August 2021
% The script will fully preprocess all files pre-, post- and intervention

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Scripts');
configuration

%% Tools
% visualise the data
%cfg                 = [];
%cfg.allowoverlap    = 'yes';
%cfg.viemode         = 'vertical';
%cfg                 = ft_databrowser(cfg, mydata_pre_clean);

%% Set up a loop to preprocess all data 
% This will import data that are already in Fieldtrip format ready for
% analyses. Each file will have a saved picture of the

for k=21:length(subjects)
    
    %Loop Iteraction - prints a message every time it starts working on a
    %new subject
    fprintf('Working on %s\n', num2str(subjects(k).name))
    
    %Paths for participant data
    datapath = subjects(k).folder ;
    outputpath = subjects(k).folder;
    cd(datapath);
    
    %Files
    currentFolder = dir; %list files in the subject's folder
    
    %Data
    datafile_pre = dir('*imported_pre*.mat'); 
    mydata_pre = importdata(datafile_pre.name); %this is the name of the pre intervention file
    
    datafile_post = dir('*imported_post*.mat'); 
    mydata_post = importdata(datafile_post.name); %this is the name of the post intervention file
    
    datafile_int = dir('*imported_int*.mat'); 
    mydata_int = importdata(datafile_int.name); %this is the name of the intervention file
    


    %%                               PRE-INTERVENTION FILE
    fprintf('Working pre-intervention file for %s\n', num2str(subjects(k).name))
    
    %% Correct the baseline so that the offset value is the same for all electrodes
    %remove the line noise 
    cfg                 = [];
    cfg.demean          = 'yes';
    cfg.baselinewindow  = [-inf inf];
    cfg.bsfilter        = 'yes';
    cfg.bsfreq          = [48 52]; %remove line noise
    mydata_pre_bs      = ft_preprocessing(cfg, mydata_pre);


    %% Identify bad channels 
    cfg                 = []; 
    cfg.method          = 'summary'; %this will display outlying channels
    cfg.keepchannel     = 'no'; %remove channels identified as bad
    temp                = ft_rejectvisual (cfg, mydata_pre_bs); %save in a temporary object so that these channels are not removed from the main file

    %list the bad channels for rejection
    badchannels = setdiff(mydata_pre_bs.label, temp.label);

    %save bad channels to data structure 
    allBadchannels(k).subjects = subjects(k).name;
    allBadchannels(k).pre_channels = badchannels;
    


    %% Interpolate bad channels
    cfg                 = [];
    cfg.method          = 'spline'; %this method requires the 3D electrode structure below
    cfg.badchannel      = badchannels;
    cfg.neighbours      = neighbours;
    cfg.layout          = layout_file;
    cfg.elec            = elec;
    mydata_pre_interpolated = ft_channelrepair(cfg, mydata_pre_bs);

    %save the interpolated data 
    FileName = [num2str(subjects(k).name), '_pre_inerpolated.mat'];
    save(fullfile(datapath, FileName), 'mydata_pre_interpolated');
    
    clear badchannels %clear so that it doesn't get confused in the loop
    clear FileName

    %% Re-reference
    %only after interpolation was already performed
    cfg                 = [];
    cfg.reref           = 'yes';
    cfg.refmethod       = 'avg'; %there are different methods but this is a standard one
    cfg.refchannel      = 'all'; %reference to the average of all
    mydata_pre_ref      = ft_preprocessing(cfg, mydata_pre_interpolated);
   
    %% Remove artefacts
    %Remove noisy trials
    cfg                 = [];
    cfg.method          = 'summary'; %this will display outlying trials
    mydata_pre_artrm    = ft_rejectvisual(cfg, mydata_pre_ref);

    %save the length of removed trials
    %the code below will calculate this
    originaltrials = length(mydata_pre_ref.trial);

    try
        trialskept = length(mydata_pre_artrm.trial);
    catch
        trialskept = 0;
    end

    removedtrials = originaltrials-trialskept;

    allRemovedTrials(k).subjects = subjects(k).name;
    allRemovedTrials(k).pre_preprocessing = removedtrials; 

    %clear these temp objects
    clear originaltrials
    clear trialskept
    clear removedtrials

    %save the data after artefacts were removed 
    FileName = [num2str(subjects(k).name), '_pre_artrm.mat'];
    save(fullfile(datapath, FileName), 'mydata_pre_artrm');
    
    clear FileName

    %% Detrend
    cfg             = [];
    cfg.channel     = 'all';
    cfg.demean      = 'yes';
    cfg.polyremoval = 'yes';
    cfg.polyorder   = 1; % with cfg.polyorder = 1 is equivalent to cfg.detrend = 'yes'
    mydata_pre_detrend = ft_preprocessing(cfg, mydata_pre_artrm);
    

    %% Filter
    cfg                 = [];
    cfg.hpfilter        = 'yes'; %we want high pass filter
    cfg.hpfreq          = 0.1; %high pass filter value
    cfg.hpfiltord       = 3; %high pass precision set to 3 instead of default 4 as it becomes unstable otherwise due to low cut-off
    cfg.lpfilter        = 'yes'; %we want low pass filter
    cfg.lpfreq          = 40; %low pass filter value

    mydata_pre_filt = ft_preprocessing(cfg, mydata_pre_detrend); 


    %% Downsample & save
    %generally this should be done after filtering and after the events are
    %already marked
    cfg                      = [];
    cfg.resamplefs           = 512; %new sampling value
    mydata_pre_preprocessed  = ft_resampledata(cfg, mydata_pre_filt); 


    %save the data 
    FileName = [num2str(subjects(k).name), '_pre_preprocessed.mat'];
    save(fullfile(datapath, FileName), 'mydata_pre_preprocessed');
    
    clear FileName
    

    %% Run ICA and save comp
    %filter the data with a higher high-pass filter for better quality ICA
    
    cfg                 = [];
    cfg.hpfilter        = 'yes'; %we want high pass filter
    cfg.hpfreq          = 1; %high pass filter value at 1Hz
    mydata_pre_temp     = ft_preprocessing(cfg, mydata_pre_preprocessed);

    cfg                 = [];
    cfg.numcomponent    = 64; %how many components are we expecting
    cfg.method          = 'fastica'; %this is a good, reliable and fast ICA method
    comp_pre            = ft_componentanalysis(cfg, mydata_pre_temp); 

    save(fullfile(datapath, 'comp_pre.mat'), 'comp_pre');
    
    

    
 %%                               POST-INTERVENTION FILE
 fprintf('Working post-intervention file for %s\n', num2str(subjects(k).name))
 
    %% Correct the baseline so that the offset value is the same for all electrodes
    %remove the line noise 
    cfg                 = [];
    cfg.demean          = 'yes';
    cfg.baselinewindow  = [-inf inf];
    cfg.bsfilter        = 'yes';
    cfg.bsfreq          = [48 52];
    mydata_post_bs      = ft_preprocessing(cfg, mydata_post);


    %% Identify bad channels 
    cfg                 = []; 
    cfg.method          = 'summary'; %this will display outlying channels
    cfg.keepchannel     = 'no'; %remove channels identified as bad
    temp                = ft_rejectvisual (cfg, mydata_post_bs); %save in a temporary object so that these channels are not removed from the main file

    %list the bad channels for rejection
    badchannels = setdiff(mydata_post_bs.label, temp.label);

    %save bad channels to data structure 
    allBadchannels(k).subjects = subjects(k).name;
    allBadchannels(k).post_channels = badchannels;
    

    %% Interpolate bad channels
    cfg                 = [];
    cfg.method          = 'spline'; %this method requires the 3D electrode structure below
    cfg.badchannel      = badchannels;
    cfg.neighbours      = neighbours;
    cfg.layout          = layout_file;
    cfg.elec            = elec;
    mydata_post_interpolated = ft_channelrepair(cfg, mydata_post_bs);

    %save the interpolated data 
    FileName = [num2str(subjects(k).name), '_post_inerpolated.mat'];
    save(fullfile(datapath, FileName), 'mydata_post_interpolated');
    
    clear badchannels %clear so that it doesn't get confused in the loop
    clear FileName

    
      %% Re-reference
    %only after interpolation was already performed
    cfg                 = [];
    cfg.reref           = 'yes';
    cfg.refmethod       = 'avg'; %there are different methods but this is a standard one
    cfg.refchannel      = 'all'; %reference to the average of all
    mydata_post_ref      = ft_preprocessing(cfg, mydata_post_interpolated);
    
  
    %% Remove artefacts
    %Remove noisy trials
    cfg                 = [];
    cfg.method          = 'summary'; %this will display outlying trials
    mydata_post_artrm    = ft_rejectvisual(cfg, mydata_post_ref);

    %save the length of removed trials
    %the code below will calculate this
    originaltrials = length(mydata_post_ref.trial);

    try
        trialskept = length(mydata_post_artrm.trial);
    catch
        trialskept = 0;
    end

    removedtrials = originaltrials-trialskept;

    allRemovedTrials(k).subjects = subjects(k).name;
    allRemovedTrials(k).post_preprocessing = removedtrials; 

    %clear these temp objects
    clear originaltrials
    clear trialskept
    clear removedtrials

    %save the data after artefacts were removed 
    FileName = [num2str(subjects(k).name), '_post_artrm.mat'];
    save(fullfile(datapath, FileName), 'mydata_post_artrm');
    
    clear FileName
    
    %% Detrend
    cfg             = [];
    cfg.channel     = 'all';
    cfg.demean      = 'yes';
    cfg.polyremoval = 'yes';
    cfg.polyorder   = 1; % with cfg.polyorder = 1 is equivalent to cfg.detrend = 'yes'
    mydata_post_detrend = ft_preprocessing(cfg, mydata_post_artrm);


    %% Filter
    cfg                 = [];
    cfg.hpfilter        = 'yes'; %we want high pass filter
    cfg.hpfreq          = 0.1; %high pass filter value
    cfg.hpfiltord       = 3; %high pass precision set to 3 instead of default 4 as it becomes unstable otherwise due to low cut-off
    cfg.lpfilter        = 'yes'; %we want low pass filter
    cfg.lpfreq          = 40; %low pass filter value

    mydata_post_filt = ft_preprocessing(cfg, mydata_post_detrend); 


    %% Downsample & save
    %generally this should be done after filtering and after the events are
    %already marked
    cfg                      = [];
    cfg.resamplefs           = 512; %new sampling value
    mydata_post_preprocessed  = ft_resampledata(cfg, mydata_post_filt); 


    %save the data 
    FileName = [num2str(subjects(k).name), '_post_preprocessed.mat'];
    save(fullfile(datapath, FileName), 'mydata_post_preprocessed');
    
    clear FileName
    

    %% Run ICA and save comp
    %filter the data with a higher high-pass filter for better quality ICA
    
    cfg                 = [];
    cfg.hpfilter        = 'yes'; %we want high pass filter
    cfg.hpfreq          = 1; %high pass filter value at 1Hz
    mydata_post_temp     = ft_preprocessing(cfg, mydata_post_preprocessed);

    cfg                 = [];
    cfg.numcomponent    = 64; %how many components are we expecting
    cfg.method          = 'fastica'; %this is a good, reliable and fast ICA method
    comp_post            = ft_componentanalysis(cfg, mydata_post_temp); 

    save(fullfile(datapath, 'comp_post.mat'), 'comp_post');
    
    

    
 %%                               INTERVENTION FILE
   fprintf('Working the intervention file for %s\n', num2str(subjects(k).name))
    %% Correct the baseline so that the offset value is the same for all electrodes
    %remove the line noise 
    cfg                 = [];
    cfg.demean          = 'yes';
    cfg.baselinewindow  = [-inf inf];
    cfg.bsfilter        = 'yes';
    cfg.bsfreq          = [48 52];
    mydata_int_bs      = ft_preprocessing(cfg, mydata_int);


    %% Identify bad channels 
    cfg                 = []; 
    cfg.method          = 'summary'; %this will display outlying channels
    cfg.keepchannel     = 'no'; %remove channels identified as bad
    temp                = ft_rejectvisual (cfg, mydata_int_bs); %save in a temporary object so that these channels are not removed from the main file

    %list the bad channels for rejection
    badchannels = setdiff(mydata_int_bs.label, temp.label);

    %save bad channels to data structure 
    allBadchannels(k).subjects = subjects(k).name;
    allBadchannels(k).int_channels = badchannels;
    


    %% Interpolate bad channels
    cfg                 = [];
    cfg.method          = 'spline'; %this method requires the 3D electrode structure below
    cfg.badchannel      = badchannels;
    cfg.neighbours      = neighbours;
    cfg.layout          = layout_file;
    cfg.elec            = elec;
    mydata_int_interpolated = ft_channelrepair(cfg, mydata_int_bs);

    %save the interpolated data 
    FileName = [num2str(subjects(k).name), '_int_inerpolated.mat'];
    save(fullfile(datapath, FileName), 'mydata_int_interpolated');
    
    clear badchannels %clear so that it doesn't get confused in the loop
    clear FileName
    
    
        %% Re-reference
    %only after interpolation was already performed
    cfg                 = [];
    cfg.reref           = 'yes';
    cfg.refmethod       = 'avg'; %there are different methods but this is a standard one
    cfg.refchannel      = 'all'; %reference to the average of all
    mydata_int_ref      = ft_preprocessing(cfg, mydata_int_interpolated);

    
    %% Remove artefacts
    %Remove noisy trials
    cfg                 = [];
    cfg.method          = 'summary'; %this will display outlying trials
    mydata_int_artrm    = ft_rejectvisual(cfg, mydata_int_ref);

    %save the length of removed trials
    %the code below will calculate this
    originaltrials = length(mydata_int_ref.trial);

    try
        trialskept = length(mydata_int_artrm.trial);
    catch
        trialskept = 0;
    end

    removedtrials = originaltrials-trialskept;

    allRemovedTrials(k).subjects = subjects(k).name;
    allRemovedTrials(k).int_preprocessing = removedtrials; 

    %clear these temp objects
    clear originaltrials
    clear trialskept
    clear removedtrials

    %save the data after artefacts were removed 
    FileName = [num2str(subjects(k).name), '_int_artrm.mat'];
    save(fullfile(datapath, FileName), 'mydata_int_artrm');
    
    clear FileName
    
    %% Detrend
    cfg             = [];
    cfg.channel     = 'all';
    cfg.demean      = 'yes';
    cfg.polyremoval = 'yes';
    cfg.polyorder   = 1; % with cfg.polyorder = 1 is equivalent to cfg.detrend = 'yes'
    mydata_int_detrend = ft_preprocessing(cfg, mydata_int_artrm);
    

    %% Filter
    cfg                 = [];
    cfg.hpfilter        = 'yes'; %we want high pass filter
    cfg.hpfreq          = 0.1; %high pass filter value
    cfg.hpfiltord       = 3; %high pass precision set to 3 instead of default 4 as it becomes unstable otherwise due to low cut-off
    cfg.lpfilter        = 'yes'; %we want low pass filter
    cfg.lpfreq          = 40; %low pass filter value

    mydata_int_filt = ft_preprocessing(cfg, mydata_int_detrend); 


    %% Downsample & save
    %generally this should be done after filtering and after the events are
    %already marked
    cfg                      = [];
    cfg.resamplefs           = 512; %new sampling value
    mydata_int_preprocessed  = ft_resampledata(cfg, mydata_int_filt); 


    %save the data 
    FileName = [num2str(subjects(k).name), '_int_preprocessed.mat'];
    save(fullfile(datapath, FileName), 'mydata_int_preprocessed');
    
    clear FileName
    

    %% Run ICA and save comp
    %filter the data with a higher high-pass filter for better quality ICA
    
    cfg                 = [];
    cfg.hpfilter        = 'yes'; %we want high pass filter
    cfg.hpfreq          = 1; %high pass filter value at 1Hz
    mydata_int_temp     = ft_preprocessing(cfg, mydata_int_preprocessed);

    cfg                 = [];
    cfg.numcomponent    = 64; %how many components are we expecting
    cfg.method          = 'fastica'; %this is a good, reliable and fast ICA method
    comp_int            = ft_componentanalysis(cfg, mydata_int_temp); 

    save(fullfile(datapath, 'comp_int.mat'), 'comp_int');
    
    
    %% Save the files with bad channels and trials that were removed

save(fullfile(projectdir, 'allBadchannels.mat'), 'allBadchannels');
save(fullfile(projectdir, 'allRemovedTrials.mat'), 'allRemovedTrials');


    
end






