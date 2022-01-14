%% Stats for pre-post ERPs
% October 2021
% The script will run permutation analyses on the ERPs

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Scripts');
configuration

% Load the data
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Data\Pre_post');
ET_P300_Pre = importdata('ET_P300_Pre.mat');
ET_P300_Post = importdata('ET_P300_Post.mat');
TS_P300_Pre = importdata('TS_P300_Pre.mat');
TS_P300_Post = importdata('TS_P300_Post.mat');
ET_P300_Diff = importdata('ET_P300_Diff.mat');
TS_P300_Diff = importdata('TS_P300_Diff.mat');

%%                                                  BETWEEN GROUP TESTS
%% Prepare the groups

% Place the group value in a separate array 
group = ones(1, (length(TS_P300_Diff)+length(ET_P300_Diff)));
group((length(TS_P300_Diff)+1): end) = 2;

%% Setup study design 
% Define the study design: in this example it is a between-group t-test.
% ivar = the independent variable, i.e. group or condition.
% uvar = unit of observation, ie.e identifier per subject 

n_ctrl = sum(group == 1); % number of TS
n_Dptns = sum(group == 2); % number of ET

ivar  = [ones(n_ctrl,1); ones(n_Dptns,1)*2]; %this is the group variable as a column
uvar  = 1:length(group); %number of participants
design = [group; uvar]';

%% Difference wave permutation
%The latency of the comparison can be adjusted depending on which ERP peak
%is to be compared, otherwise, the whole time window will be compared

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Data\Stats');

cfg = [];
cfg.method              = 'montecarlo'; 
cfg.statistic           = 'ft_statfun_indepsamplesT'; % use ft_statfun_depsamplesT for within-subject factors
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;        
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;            % = two-tailed hypothesis
cfg.alpha               = 0.025;        % = 0.05/2 for two-tailed hypothesis
fg.channel             = 'Cz';
cfg.latency             = [0.6 0.8]; 
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.ivar                = 1; %group identifier specifies the column in the matrix "design" which is the independent variable
stats = ft_timelockstatistics(cfg, TS_P300_Diff{:}, ET_P300_Diff{:}); % or ft_timelockstatistics(cfg, alldata_group1{:}, alldata_group2{:})

save stats_P300 stats;

%%Plot for clusters
cfg               = [];
cfg.marker        = 'on';
cfg.layout        = layout_file;
cfg.channel       = 'EEG';
cfg.parameter     = 'stat';  % plot the t-value
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'box';

figure; ft_multiplotER(cfg, stats);

