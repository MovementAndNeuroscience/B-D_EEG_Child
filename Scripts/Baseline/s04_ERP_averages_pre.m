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

for k=1:length(subjects)
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

%In addition, from quality assessment of the intervention files, sub-12
%also cannot be included in the analyses of the intervention data. To make
%sure that we compare the baseline between participants who are included in
%the main intervention analyses, sub-12 will be excluded from the
%comparisons below as well.

all_ERP_Pre_noage = all_ERP_Pre_noage([subjects.name] ~= 1010 & [subjects.name] ~= 1017 &[subjects.name] ~= 1023); 
subjects = subjects([subjects.name] ~= 1010 & [subjects.name] ~= 1017& [subjects.name] ~= 1023); 


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

%% -----------------------------PLOT------------------------------------
%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.linewidth = 1;
ft_multiplotER(cfg, ET_ERP_Pre, TS_ERP_Pre);



%% ---------------------------------- STATS-----------------------------
%% Prepare the groups

ET_ERP_Pre = all_ERP_Pre_noage([subjects.group] == 2);
TS_ERP_Pre = all_ERP_Pre_noage([subjects.group] == 1);

% Place the group value in a separate array 
group = ones(1, (length(TS_ERP_Pre)+length(ET_ERP_Pre)));
group((length(TS_ERP_Pre)+1): end) = 2;

%% Setup study design 
% Define the study design: in this example it is a between-group t-test.
% ivar = the independent variable, i.e. group or condition.
% uvar = unit of observation, i.e. identifier per subject 

n_ctrl = sum(group == 1); % number of TS
n_Dptns = sum(group == 2); % number of ET

ivar  = [ones(n_ctrl,1); ones(n_Dptns,1)*2]; %this is the group variable as a column
uvar  = 1:length(group); %number of participants
design = [group; uvar]';

%% Between-group permutation Fz

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Stats\Baseline');

cfg = [];
cfg.method              = 'montecarlo'; 
cfg.statistic           = 'ft_statfun_indepsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;        
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;            % = two-tailed hypothesis
cfg.alpha               = 0.025;        % = 0.05/2 for two-tailed hypothesis
cfg.channel             = {'F1', 'Fz', 'F2'}; %F1, Fz and F2
cfg.latency             = [0.15 0.4]; 
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.ivar                = 1; %group identifier specifies the column in the matrix "design" which is the independent variable
stats = ft_timelockstatistics(cfg, TS_ERP_Pre{:}, ET_ERP_Pre{:}); 

save stats_Fz_pre stats;

%get information about the time of the cluster
cluster1 = stats.negclusterslabelmat;

cfg = [];
cfg.latency = [0.15 0.4];
timeData = ft_selectdata(cfg, TS_ERP_Pre{1});

cluster1(4,:) = timeData.time;

%execute cluster1 to check the time of the cluster for each of the three
%channels

%% Between-group permutation Pz

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Stats\Baseline');

cfg = [];
cfg.method              = 'montecarlo'; 
cfg.statistic           = 'ft_statfun_indepsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;        
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;            % = two-tailed hypothesis
cfg.alpha               = 0.025;        % = 0.05/2 for two-tailed hypothesis
cfg.channel             = {'P1', 'Pz', 'P2'}; 
cfg.latency             = [0.15 0.4];
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.ivar                = 1; %group identifier specifies the column in the matrix "design" which is the independent variable
stats = ft_timelockstatistics(cfg, TS_ERP_Pre{:}, ET_ERP_Pre{:}); 

save stats_Pz_pre stats;








