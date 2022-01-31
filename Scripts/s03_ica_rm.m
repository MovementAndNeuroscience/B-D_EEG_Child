%% Remove ICA components
% August 2021

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration

%% Open the folder for each participant
%This will not be done in a loop as it is a pretty manual process where the
%researcher has to examine all components, pick the ones for rejection and
%then add the component number to the code 

%participant number
k = 1;

%Participant files
datapath = subjects(k).folder ; %address of the folder
outputpath = ('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Qual_Figs'); %this is were quality figures will go at the end
cd(datapath); %change the working directory to the address specified above


%% ------------------------------   Component Removal  -------------------------------
%Import the data file 
datafile_int = dir('*_preprocessed*.mat'); 
mydata_int_preprocessed = importdata(datafile_int.name); %this is the name of the pre intervention file

%Import the comp file
compfile = dir('*_comp*.mat');
comp_int = importdata(compfile.name);

% Toporgraphy View split into three figures 
cfg                 = [];
cfg.layout          = layout_file;
cfg.marker          = 'off';
cfg.component       = [1:20];
figure; ft_topoplotIC(cfg, comp_int)

cfg                 = [];
cfg.layout          = layout_file;
cfg.marker          = 'off';
cfg.component       = [21:40];
figure; ft_topoplotIC(cfg, comp_int)

cfg                 = [];
cfg.layout          = layout_file;
cfg.marker          = 'off';
cfg.component       = [41:length(comp_int.label)];
figure; ft_topoplotIC(cfg, comp_int)


%Temporal view for all components (in one window)
cfg                 = [];
cfg.viewmode        = 'component';
cfg.layout          = layout_file;
cfg.allowoverlap    = 'yes';
ft_databrowser(cfg, comp_int);


%% Remove Components 
reject_comp = [15 18 27]; %this must be manually changed for each participant

cfg = [];
cfg.component = reject_comp; %selected components will be rejected
cfg.updatesens = 'yes';
mydata_int_ica = ft_rejectcomponent(cfg, comp_int, mydata_int_preprocessed);

%Add the rejected components to a structure 
allRejectedComponents(k).subjects = subjects(k).sub; 
allRejectedComponents(k).int_comp = reject_comp;

%Save the rejected components structure
save(fullfile(outputdir, 'allRejectedComponents.mat'), 'allRejectedComponents')

%Save the datafile after removing components
FileName = [subjects(k).sub, '_step5_int_ica.mat'];
save(fullfile(datapath, FileName), 'mydata_int_ica');


%% One more artefact rejection
%One last artefact rejection run will help to ensure that there is minial
%noise in the data. It is not necessary to run this step but it is a good
%sanity check. 

cfg                 = [];
cfg.method          = 'summary';
mydata_int_clean    = ft_rejectvisual(cfg, mydata_int_ica);

%Calculate the number of removed trials
originaltrials = length(mydata_int_ica.trial);

try
    trialskept = length(mydata_int_clean.trial);
catch
    trialskept = 0;
end

removedtrials = originaltrials-trialskept;

%Add these to the same data structure as the one used in preprocessing s02
allRemovedTrials(k).subjects = subjects(k).sub;
allRemovedTrials(k).int_ica = removedtrials; 

%Also add the number of remaining trials to that same structure
allRemovedTrials(k).int_remaining = length(mydata_int_clean.trial);

%Clear the remp objects
clear originaltrials
clear trialskept
clear removedtrials

%save the data after artefacts were removed 
FileName = [subjects(k).sub, '_step6_int_clean.mat'];
save(fullfile(datapath, FileName), 'mydata_int_clean');

%Save the removed/remaining trials structure
save(fullfile(outputdir, 'allRemovedTrials.mat'), 'allRemovedTrials');





%% ------------------------------   Quality Checks  -------------------------------

%% Quality Check 1 - Conitnous Data 
% Assess if there are slow drifts in the data  

% Plot
cfg                 = [];
cfg.allowoverlap    = 'yes';
cfg.viemode         = 'vertical';
cfg                 = ft_databrowser(cfg, mydata_int_clean);

%% Quality Check 2 - ERP
%Porduce the ERP plot to check if the data is not too noisy
cd(outputpath)

%ERP wave
cfg = [];
cfg.baseline = [-0.1 0];
tmp = ft_timelockanalysis(cfg, mydata_int_clean); %temporary averaging
cfg.showlabels = 'yes';
cfg.layout = layout_file;
ft_multiplotER(cfg, tmp);

%Save the individual averaged figure for that participant
FigName = [subjects(k).sub,'_int_wave']; 
savefig(FigName)






