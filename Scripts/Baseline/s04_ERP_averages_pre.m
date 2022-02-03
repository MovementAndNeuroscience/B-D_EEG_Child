%% ERPs Averaged
% September 2021
% The script will calculate stimulus-locked ERPs per participant for
% comparison as the baseline measurement to check whether there are any
% pre-existing differences between the groups

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration

outputpath = ('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Baseline');
cd(outputpath);


%% Set up a loop

for k=2:length(subjects)
    %get all the data
    datapath = subjects(k).folder;
    cd(datapath);
    
    %Current file info
    fprintf('Working on %s\n', num2str(subjects(k).name))
    
    %Files 
    currentFolder = dir;
    
    %Data pre
    mydata_pre_clean_file = dir('*pre_clean*.mat');
    mydata_pre_clean = importdata(mydata_pre_clean_file.name);
    
    
 %%                                          PRE

    cfg = [];
    cfg.baseline = [-0.1 0];
    cfg.latency = [-0.1 0.8];
    Pre_ERP = ft_timelockanalysis(cfg, mydata_pre_clean);
    
    %Correct the baseline
    cfg = [];
    cfg.baseline = [-0.1, 0];
    Pre_ERP_baseline = ft_timelockbaseline(cfg, Pre_ERP);
  
 
  %%                                          SAVE
  %save in a structure
  all_ERP_Pre{k} = Pre_ERP_baseline;
    
end

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Baseline')
save(fullfile(outputpath, 'all_ERP_Pre.mat'), 'all_ERP_Pre');


%% ------------ Regress out the confound
% Age is not equal between the two groups and this needs to be controlled
% for. It can be done with the use the ft_regressconfound() function which
% was suggested on the fieldtrip mailing list. However, the function is
% written for correcting noise across trials and so the data has to be
% restructured here to ensure that the function can be applied to the
% ERP averages across participants. 

%The confound is specified as participants' age


%prepare the age dummy confound table
age = zeros(length(subjects), 1);
age(:,1) = [subjects.age];

%Each participants' averaged data needs to be arranged in a new sctructure
%with the field called "trials" which us required by the function. Here the
%"trials" are actually participants' averaged data
for k = 1:length(subjects)
    trials(k,:,:) = all_ERP_Pre{k}.avg;
end

%Arrange the structure that will be compatibale with the function
all_averaged_ERPs.time = all_ERP_Pre{1}.time;
all_averaged_ERPs.label = all_ERP_Pre{1}.label;
all_averaged_ERPs.elec = all_ERP_Pre{1}.elec;
all_averaged_ERPs.dimord = 'rpt_chan_time';
all_averaged_ERPs.trial = trials;

%Remove the confound
cfg = [];
cfg.confound = age;
all_averaged_ERPs_con = ft_regressconfound(cfg, all_averaged_ERPs);

%Now these corrected values must be extracted and inserted back into the
%original data structure with all avergaed ERPs for each participant
all_ERP_Pre_noage = all_ERP_Pre; %Copy the old structure
trials_noage = all_averaged_ERPs_con.trial; %Copy all of the corrected averages

for k = 1:length(subjects)
    all_ERP_Pre_noage{k}.avg = squeeze(trials_noage(k,:,:)); %select the corrected average and insert back to the original data structure
end

save(fullfile(outputpath, 'all_ERP_Pre_noage.mat'), 'all_ERP_Pre_noage');

%% Check baseline activity for all participants to find outliers

for k = 1:length(subjects)
    cfg = [];
    cfg.channel = 'Cz';
    cfg.latency = [0.15 0.3];
    select = ft_selectdata(cfg, all_ERP_Pre_noage{k});
    
    all_select(k).amp = max(select.avg);
    all_select(k).sub = subjects(k).sub;
end

%Looks like sub-07 and sub-17 are outliers and will need to be excluded
%from analyses

all_ERP_Pre_noage = all_ERP_Pre_noage([subjects.name] ~= 1010 & [subjects.name] ~= 1023); 
subjects = subjects([subjects.name] ~= 1010 & [subjects.name] ~= 1023); 


%%                                         Grand averages 
%for all
cfg = [];
ERP_Pre_all_av = ft_timelockgrandaverage(cfg, all_ERP_Pre_noage{:});

%plot 
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, ERP_Pre_all_av);

%Grand averages for groups

cd(outputpath)
%devide by intervention
ET_ERP_Pre = all_ERP_Pre_noage([subjects.group] == 2);
TS_ERP_Pre = all_ERP_Pre_noage([subjects.group] == 1);

save(fullfile(outputpath, 'ET_ERP_Pre.mat'), 'ET_ERP_Pre');
save(fullfile(outputpath, 'TS_ERP_Pre.mat'), 'TS_ERP_Pre'); 

%ET
cfg = [];
ET_ERP_Pre = ft_timelockgrandaverage(cfg, ET_ERP_Pre{:});

%TS
cfg = [];
TS_ERP_Pre = ft_timelockgrandaverage(cfg, TS_ERP_Pre{:});


%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.linewidth = 1;
ft_multiplotER(cfg, ET_ERP_Pre, TS_ERP_Pre);










