%% Remove ICA components
% August 2021

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration

%% Open the folder for each participant
%This will not be done in a loop as it is a pretty manual process where
%researcher has to examine all components, pick the ones for rejection and
%then add the component number to the code (see example on line 57)

%participants number
k = 1;

datapath = subjects(k).folder ; %address of the folder
outputpath = ('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Qual_Figs'); %this is were quality figures will go at the end
cd(datapath); %change the working directory to the address specified above


%% ------------------------------   Plot ICA for pre-intervention file  -------------------------------
%import the data file 
datafile_pre = dir('*pre_preprocessed*.mat'); 
mydata_pre_preprocessed = importdata(datafile_pre.name); %this is the name of the pre intervention file
%import the comp file
compfile = dir('comp_pre.mat');
comp_pre = importdata(compfile.name);

% Toporgraphy View split into three figures
cfg                 = [];
cfg.layout          = layout_file;
cfg.marker          = 'off';
cfg.component       = [1:20];
figure; ft_topoplotIC(cfg, comp_pre)

cfg                 = [];
cfg.layout          = layout_file;
cfg.marker          = 'off';
cfg.component       = [21:40];
figure; ft_topoplotIC(cfg, comp_pre)

cfg                 = [];
cfg.layout          = layout_file;
cfg.marker          = 'off';
cfg.component       = [41:length(comp_pre.label)];
figure; ft_topoplotIC(cfg, comp_pre)


%Temporal view for all components (in one window)
cfg                 = [];
cfg.viewmode        = 'component';
cfg.layout          = layout_file;
cfg.allowoverlap    = 'yes';
ft_databrowser(cfg, comp_pre);


%% Remove Components 
reject_comp = [10 25]; %list the components selected for removal

cfg = [];
cfg.component = reject_comp;
cfg.updatesens = 'yes';
mydata_pre_ica = ft_rejectcomponent(cfg, comp_pre, mydata_pre_preprocessed);

%save the rejected components to a structure 
allRejectedComponents(k).subjects = subjects(k).name; 
allRejectedComponents(k).pre_comp = reject_comp;

%save the rejected components structure
save(fullfile(projectdir, 'allRejectedComponents.mat'), 'allRejectedComponents')

%save the datafile after removing components
FileName = [num2str(subjects(k).name), '_pre_ica.mat'];
save(fullfile(datapath, FileName), 'mydata_pre_ica');


%% One more artefact rejection
%One last artefact rejection run will help to ensure that there is no more
%noise in the data. It is not necessary to run this step but it is a good
%sanity check.

cfg                 = [];
cfg.method          = 'summary';
mydata_pre_clean    = ft_rejectvisual(cfg, mydata_pre_ica);

%save the length of removed trials
originaltrials = length(mydata_pre_ica.trial);

try
    trialskept = length(mydata_pre_clean.trial);
catch
    trialskept = 0;
end

removedtrials = originaltrials-trialskept;

allRemovedTrials(k).subjects = subjects(k).name;
allRemovedTrials(k).pre_ica = removedtrials; 

%clear these remp objects
clear originaltrials
clear trialskept
clear removedtrials

%save the data after artefacts were removed 
FileName = [num2str(subjects(k).name), '_pre_clean.mat'];
save(fullfile(datapath, FileName), 'mydata_pre_clean');

%save the number of remaining trials
allRemovedTrials(k).pre_remaining = length(mydata_pre_clean.trial);

%save the removed trials structure
save(fullfile(projectdir, 'allRemovedTrials.mat'), 'allRemovedTrials');

%% Quality check
cd(outputpath)

%ERP wave
cfg = [];
cfg.baseline = [-0.1 0];
%cfg.latency = [0.2 0.4];
tmp = ft_timelockanalysis(cfg, mydata_pre_clean);
cfg.showlabels = 'yes';
cfg.layout = layout_file;
ft_multiplotER(cfg, tmp);

FigName = [num2str(subjects(k).name),'_pre_wave']; 
savefig(FigName)

openfig(FigName)



%% ------------------------------   Plot ICA for post-intervention file  -------------------------------
cd(datapath)
%import the data file 
datafile_post = dir('*post_preprocessed*.mat'); 
mydata_post_preprocessed = importdata(datafile_post.name); %this is the name of the pre intervention file
%import the comp file
compfile = dir('comp_post.mat');
comp_post = importdata(compfile.name);

% Toporgraphy View split into three figures
cfg                 = [];
cfg.layout          = layout_file;
cfg.marker          = 'off';
cfg.component       = [1:20];
figure; ft_topoplotIC(cfg, comp_post)

cfg                 = [];
cfg.layout          = layout_file;
cfg.marker          = 'off';
cfg.component       = [21:40];
figure; ft_topoplotIC(cfg, comp_post)

cfg                 = [];
cfg.layout          = layout_file;
cfg.marker          = 'off';
cfg.component       = [41:length(comp_post.label)];
figure; ft_topoplotIC(cfg, comp_post)


%Temporal view for all components (in one window)
cfg                 = [];
cfg.viewmode        = 'component';
cfg.layout          = layout_file;
cfg.allowoverlap    = 'yes';
ft_databrowser(cfg, comp_post);


%% Remove Components 
reject_comp = [21 22]; %list the components selected for removal

cfg = [];
cfg.component = reject_comp;
cfg.updatesens = 'yes';
mydata_post_ica = ft_rejectcomponent(cfg, comp_post, mydata_post_preprocessed);

%save the rejected components to a structure 
allRejectedComponents(k).subjects = subjects(k).name; 
allRejectedComponents(k).post_comp = reject_comp;

%save the rejected components structure
save(fullfile(projectdir, 'allRejectedComponents.mat'), 'allRejectedComponents')

%save the datafile after removing components
FileName = [num2str(subjects(k).name), '_post_ica.mat'];
save(fullfile(datapath, FileName), 'mydata_post_ica');


%% One more artefact rejection
%One last artefact rejection run will help to ensure that there is no more
%noise in the data. It is not necessary to run this step but it is a good
%sanity check.

cfg                 = [];
cfg.method          = 'summary';
mydata_post_clean    = ft_rejectvisual(cfg, mydata_post_ica);

%save the length of removed trials
originaltrials = length(mydata_post_ica.trial);

try
    trialskept = length(mydata_post_clean.trial);
catch
    trialskept = 0;
end

removedtrials = originaltrials-trialskept;

allRemovedTrials(k).subjects = subjects(k).name;
allRemovedTrials(k).post_ica = removedtrials; 

%clear these remp objects
clear originaltrials
clear trialskept
clear removedtrials

%save the data after artefacts were removed 
FileName = [num2str(subjects(k).name), '_post_clean.mat'];
save(fullfile(datapath, FileName), 'mydata_post_clean');

%save the number of remaining trials
allRemovedTrials(k).post_remaining = length(mydata_post_clean.trial);

%save the removed trials structure
save(fullfile(projectdir, 'allRemovedTrials.mat'), 'allRemovedTrials');

%% Quality check
cd(outputpath)

%ERP wave
cfg = [];
cfg.baseline = [-0.1 0];
tmp = ft_timelockanalysis(cfg, mydata_post_clean);
cfg.showlabels = 'yes';
cfg.layout = layout_file;
ft_multiplotER(cfg, tmp);

FigName = [num2str(subjects(k).name),'_post_wave']; 
savefig(FigName)

openfig(FigName)






%% ------------------------------   Plot ICA for intervention file  -------------------------------
cd(datapath)
%import the data file 
datafile_int = dir('*int_preprocessed*.mat'); 
mydata_int_preprocessed = importdata(datafile_int.name); %this is the name of the pre intervention file
%import the comp file
compfile = dir('comp_int.mat');
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
reject_comp = [15 18 27]; %list the components selected for removal

cfg = [];
cfg.component = reject_comp;
cfg.updatesens = 'yes';
mydata_int_ica = ft_rejectcomponent(cfg, comp_int, mydata_int_preprocessed);

%save the rejected components to a structure 
allRejectedComponents(k).subjects = subjects(k).name; 
allRejectedComponents(k).int_comp = reject_comp;

%save the rejected components structure
save(fullfile(projectdir, 'allRejectedComponents.mat'), 'allRejectedComponents')

%save the datafile after removing components
FileName = [num2str(subjects(k).name), '_int_ica.mat'];
save(fullfile(datapath, FileName), 'mydata_int_ica');


%% One more artefact rejection
%One last artefact rejection run will help to ensure that there is no more
%noise in the data. It is not necessary to run this step but it is a good
%sanity check.

cfg                 = [];
cfg.method          = 'summary';
mydata_int_clean    = ft_rejectvisual(cfg, mydata_int_ica);

%save the length of removed trials
originaltrials = length(mydata_int_ica.trial);

try
    trialskept = length(mydata_int_clean.trial);
catch
    trialskept = 0;
end

removedtrials = originaltrials-trialskept;

allRemovedTrials(k).subjects = subjects(k).name;
allRemovedTrials(k).int_ica = removedtrials; 

%clear these remp objects
clear originaltrials
clear trialskept
clear removedtrials

%save the data after artefacts were removed 
FileName = [num2str(subjects(k).name), '_int_clean.mat'];
save(fullfile(datapath, FileName), 'mydata_int_clean');

%save the number of remaining trials
allRemovedTrials(k).int_remaining = length(mydata_int_clean.trial);

%save the removed trials structure
save(fullfile(projectdir, 'allRemovedTrials.mat'), 'allRemovedTrials');

%% Quality check
cd(outputpath)

%ERP wave
cfg = [];
cfg.baseline = [-0.1 0];
tmp = ft_timelockanalysis(cfg, mydata_int_clean);
cfg.showlabels = 'yes';
cfg.layout = layout_file;
ft_multiplotER(cfg, tmp);

FigName = [num2str(subjects(k).name),'_int_wave']; 
savefig(FigName)

openfig(FigName)




%% Check quality of individual files to assess for drifts 

k = 3;

datapath = subjects(k).folder ; %address of the folder
cd(datapath); %change the working directory to the address specified above

%import the pre intervention data file 
datafile_pre_clean = dir('*pre_clean*.mat'); 
mydata_pre_clean = importdata(datafile_pre_clean.name); 

%import the post intervention data file 
datafile_post_clean = dir('*post_clean*.mat'); 
mydata_post_clean = importdata(datafile_post_clean.name);

%import the intervention data file 
datafile_int_clean = dir('*int_clean*.mat'); 
mydata_int_clean = importdata(datafile_int_clean.name);


% visualise the data
cfg                 = [];
cfg.allowoverlap    = 'yes';
cfg.viemode         = 'vertical';
cfg                 = ft_databrowser(cfg, mydata_int_clean);




