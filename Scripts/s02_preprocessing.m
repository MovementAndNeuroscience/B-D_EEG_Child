%% Preprocessing pipeline
% August 2021
% The script will fully preprocess the intervention files

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration


%% Set up a loop to preprocess the data 

for k=1:length(subjects)
    
    %Progress message - prints a message every time it starts working on a
    %new subject
    fprintf('Working on %s\n', subjects(k).sub)
    
    %Paths for participant data
    datapath = subjects(k).folder ;
    outputpath = subjects(k).folder;
    cd(datapath);
    
    %Files
    currentFolder = dir; %list files in the subject's folder
    
    % Intervention Data    
    datafile_int = dir('*_imported*.mat'); 
    mydata_int = importdata(datafile_int.name); 

    
 %%                               INTERVENTION FILE
    %% Correct the baseline so that the offset value is the same for all electrodes
    % Plus remove the line noise 
    cfg                 = [];
    cfg.demean          = 'yes'; %use the demeaning function to correct the different offset values/baseline
    cfg.baselinewindow  = [-inf inf]; %demeaning/baseline correction of the full window
    cfg.bsfilter        = 'yes'; %band stop filter to remove line noise
    cfg.bsfreq          = [48 52]; %line noise frequency to be filtered
    mydata_int_bs      = ft_preprocessing(cfg, mydata_int);


    %% Identify bad channels 
    cfg                 = []; 
    cfg.method          = 'summary'; %this will display outlying channels
    cfg.keepchannel     = 'no'; %do not remove channels identified as bad
    temp                = ft_rejectvisual (cfg, mydata_int_bs); %save in a temporary object so that these channels are not removed from the main file

    %list the bad channels for rejection
    badchannels = setdiff(mydata_int_bs.label, temp.label); %list the bad channels identified in the temporary data structure

    %Add the bad channels to data structure to keep track
    allBadchannels(k).subjects = subjects(k).sub;
    allBadchannels(k).int_channels = badchannels;
    


    %% Interpolate bad channels
    cfg                 = [];
    cfg.method          = 'spline'; %this method requires the 3D electrode structure below
    cfg.badchannel      = badchannels; %identified bad channels
    cfg.neighbours      = neighbours;
    cfg.layout          = layout_file;%layout
    cfg.elec            = elec; %3D structure
    mydata_int_interpolated = ft_channelrepair(cfg, mydata_int_bs); %call the interpolation function

    %save the interpolated data 
    FileName = [subjects(k).sub, '_step2_int_inerpolated.mat'];
    save(fullfile(datapath, FileName), 'mydata_int_interpolated');
    
    clear badchannels %clear so that it doesn't get confused in the loop
    clear FileName
    
    
        %% Re-reference
    %only after interpolation was already performed to avoid spreading
    %noise
    cfg                 = [];
    cfg.reref           = 'yes';
    cfg.refmethod       = 'avg'; %there are different methods but this is a standard one
    cfg.refchannel      = 'all'; %reference to the average of all channels
    mydata_int_ref      = ft_preprocessing(cfg, mydata_int_interpolated);

    
    %% Remove artefacts
    %Remove noisy trials
    cfg                 = [];
    cfg.method          = 'summary'; %this will display outlying trials
    mydata_int_artrm    = ft_rejectvisual(cfg, mydata_int_ref);

    %Calculate the number of removed trials
    originaltrials = length(mydata_int_ref.trial);

    try
        trialskept = length(mydata_int_artrm.trial);
    catch
        trialskept = 0;
    end

    removedtrials = originaltrials-trialskept;
    
    %Add this to a data structure to keep track
    allRemovedTrials(k).subjects = subjects(k).sub;
    allRemovedTrials(k).int_preprocessing = removedtrials; 

    %clear the temp objects
    clear originaltrials
    clear trialskept
    clear removedtrials

    %save the data after artefacts were removed 
    FileName = [subjects(k).sub, '_step3_int_artrm.mat'];
    save(fullfile(datapath, FileName), 'mydata_int_artrm');
    
    clear FileName
    
    %% Detrend
    %There is a slow wave drift in some files which causes issues later on
    %so it should be removed - applied to all files for consistency
    cfg             = [];
    cfg.channel     = 'all';
    cfg.demean      = 'yes';
    cfg.polyremoval = 'yes'; %use the detrending option
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
    %Generally this should be done after filtering and after the events are
    %already marked
    cfg                      = [];
    cfg.resamplefs           = 512; %new sampling value
    mydata_int_preprocessed  = ft_resampledata(cfg, mydata_int_filt); 


    %save the data 
    FileName = [subjects(k).sub, '_step4_int_preprocessed.mat'];
    save(fullfile(datapath, FileName), 'mydata_int_preprocessed');
    
    clear FileName
    

    %% Run ICA and save comp
    %Filter the data with a higher high-pass filter for better quality ICA,
    %but do not save this filtered data, it is only used to extract the
    %components
    
    cfg                 = [];
    cfg.hpfilter        = 'yes'; %we want high pass filter
    cfg.hpfreq          = 1; %high pass filter value at 1Hz
    mydata_int_temp     = ft_preprocessing(cfg, mydata_int_preprocessed); %temp file

    cfg                 = [];
    cfg.numcomponent    = 64; %how many components we are expecting
    cfg.method          = 'fastica'; %this is a good, reliable and fast ICA method
    comp_int            = ft_componentanalysis(cfg, mydata_int_temp); 
    
    FileName = [subjects(k).sub, '_int_comp.mat'];
    save(fullfile(datapath, FileName), 'comp_int'); %save the extracted components
    
    
    %% Save the files with bad channels and trials that were removed

cd(outputdir)

%calculate how many channels were removed per person
for k = 1:length(allBadchannels)
    allBadchannels(k).int_n = length(allBadchannels(k).int_channels);    
end
%change the order of the fields 
P = [1 3 2];
allBadchannels = orderfields(allBadchannels,P);

%save as matlab file
save(fullfile(outputdir, 'allBadchannels.mat'), 'allBadchannels');
%save in csv for an R script
writetable(struct2table(allBadchannels), 'allBadchannels.csv');

%save as matlab file
save(fullfile(outputdir, 'allRemovedTrials.mat'), 'allRemovedTrials');
%save in csv for an R script
writetable(struct2table(allRemovedTrials), 'allRemovedTrials.csv');


    
end






