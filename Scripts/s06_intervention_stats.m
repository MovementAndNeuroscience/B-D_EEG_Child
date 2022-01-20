%% Stats for intervention analyses
% October 2021
% The script will run permutation analyses on the intervention ERPs and
% TFRs

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Scripts');
configuration

%load the data
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Data\Intervention');
ET_ERP_Int = importdata('ET_ERP_Int.mat');
TS_ERP_Int = importdata('TS_ERP_Int.mat');

ET_Theta_Int = importdata('ET_Theta_Int.mat');
TS_Theta_Int = importdata('TS_Theta_Int.mat');

ET_Alpha_Int = importdata('ET_Alpha_Int.mat');
TS_Alpha_Int = importdata('TS_Alpha_Int.mat');


    
%%                                                  BETWEEN GROUP TESTS
%%                                                          ERPs
%% Prepare the groups

% Place the group value in a separate array 
group = ones(1, (length(TS_ERP_Int_noage)+length(ET_ERP_Int_noage)));
group((length(TS_ERP_Int_noage)+1): end) = 2;

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

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Stats');

cfg = [];
cfg.method              = 'montecarlo'; 
cfg.statistic           = 'ft_statfun_indepsamplesT'; % use ft_statfun_depsamplesT for within-subject factors
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;        
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;            % = two-tailed hypothesis
cfg.alpha               = 0.025;        % = 0.05/2 for two-tailed hypothesis
cfg.channel             = [49 50 51]; %[49 50 52]; %[12 13 14 21 22 23];  %[49 50 52] %'Fz'; %AFz, Fz, FCz [6 13 22] [5 6 7 12 13 14 21 22 23] [12 13 14 21 22 23 30 31 32]
cfg.latency             = [0.2 0.3]; 
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.ivar                = 1; %group identifier specifies the column in the matrix "design" which is the independent variable
stats = ft_timelockstatistics(cfg, TS_ERP_Int_noage{:}, ET_ERP_Int_noage{:}); % or ft_timelockstatistics(cfg, alldata_group1{:}, alldata_group2{:})

save stats_P300_int stats;

clear design

%%Plot for clusters

cfg               = [];
cfg.marker        = 'on';
cfg.layout        = layout_file;
cfg.channel       = 'EEG';
cfg.parameter     = 'stat';  % plot the t-value
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'box';

figure; ft_multiplotER(cfg, stats);

clear design
% ----------------------- REGRESSION WITH TASK ACCURACY
%uncorrected accuracy
n1 = 18; 
design(1,1:n1)       = [95 87.5   80 92.5  100  100   95  100  100  92.5   100   100   100  97.5  97.5    80  97.5   100]; % add the accuracy variable 

%accuracy corrected for age
n1 = 18; 
design(1,1:n1)       = [94.62105 87.08857 79.55000 91.97027 99.64000 99.51000 94.48421 99.51000 99.51000 91.97027 99.64000 99.36000 99.36000 96.99744 97.13077 79.38750 96.99744 99.64000]; % add the accuracy variable 


cfg = [];
cfg.statistic        = 'ft_statfun_indepsamplesregrT';
cfg.method           = 'montecarlo';
cfg.numrandomization = 1000;
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;   
cfg.alpha            = 0.025;
cfg.channel          = [12 13 14 21 22 23];% [12 13 14 21 22 23 ]; %'Fz'; %AFz, Fz, FCz [6 13 22];
cfg.neighbours       = neighbours;
cfg.latency          = [0.15 0.25]; 
cfg.design           = design;
cfg.ivar             = 1;

stats = ft_timelockstatistics(cfg, all_Int_ERP_noage{:});


%%                                                          THETA
%% Difference wave permutation
%The latency of the comparison can be adjusted depending on which TFR peak
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
cfg.channel             = 'Fz'; %AFz, Fz, FCz [6 13 22];
cfg.latency             = [0.1 0.4]; 
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.ivar                = 1; %group identifier specifies the column in the matrix "design" which is the independent variable
stats = ft_freqstatistics(cfg, TS_Theta_Int_noage{:}, ET_Theta_Int_noage{:}); % or ft_timelockstatistics(cfg, alldata_group1{:}, alldata_group2{:})

%save stats_theta_int stats;

%%Plot for clusters
cfg               = [];
cfg.marker        = 'on';
cfg.layout        = layout_file;
cfg.channel       = 'EEG';
cfg.parameter     = 'stat';  % plot the t-value
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'box';

figure; ft_multiplotER(cfg, stats);


% ----------------------- REGRESSION WITH TASK ACCURACY
%uncorrected accuracy
n1 = 18; 
design(1,1:n1)       = [95 87.5   80 92.5  100  100   95  100  100  92.5   100   100   100  97.5  97.5    80  97.5   100]; % add the accuracy variable 

%accuracy corrected for agee 
n1 = 18; 
design(1,1:n1)       = [94.62105 87.08857 79.55000 91.97027 99.64000 99.51000 94.48421 99.51000 99.51000 91.97027 99.64000 99.36000 99.36000 96.99744 97.13077 79.38750 96.99744 99.64000]; % add the accuracy variable 

cfg = [];
cfg.statistic        = 'ft_statfun_indepsamplesregrT';
cfg.method           = 'montecarlo';
cfg.numrandomization = 1000;
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;   
cfg.alpha            = 0.025;
cfg.channel          = 'Fz'; %AFz, Fz, FCz [6 13 22];
cfg.neighbours          = neighbours;
cfg.latency          = [0 0.3]; 
cfg.design           = design;
cfg.ivar             = 1;

stats = ft_freqstatistics(cfg, all_Int_theta_noage{:});


for k = 1:length(subjects)
    cfg = [];
    cfg.channel = 'Fz';
    cfg.avgoverfreq = 'yes';
    cfg.latency = [0 0.3];
    cfg.avgovertime = 'yes';
    x = ft_selectdata(cfg, all_Int_theta_noage{k});
    
    powspctrm_theta(k) = x;
end 

power = [powspctrm_theta(:).powspctrm];
acc = [94.62105 87.08857 79.55000 91.97027 99.64000 99.51000 94.48421 99.51000 99.51000 91.97027 99.64000 99.36000 99.36000 96.99744 97.13077 79.38750 96.99744 99.64000];
scatter(acc, power, 'filled')

%%                                                          ALPHA
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
cfg.channel             = 'Cz'; % Cz and CPz [31 40]; 
cfg.latency             = [0 0.6]; 
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.ivar                = 1; %group identifier specifies the column in the matrix "design" which is the independent variable
stats = ft_freqstatistics(cfg, TS_Alpha_Int_noage{:}, ET_Alpha_Int_noage{:}); % or ft_timelockstatistics(cfg, alldata_group1{:}, alldata_group2{:})

%save stats_theta stats;

%%Plot for clusters
cfg               = [];
cfg.marker        = 'on';
cfg.layout        = layout_file;
cfg.channel       = 'EEG';
cfg.parameter     = 'stat';  % plot the t-value
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'box';

figure; ft_multiplotER(cfg, stats);

% ----------------------- REGRESSION WITH TASK ACCURACY
%uncorrected accuracy
n1 = 18; 
design(1,1:n1)       = [95 87.5   80 92.5  100  100   95  100  100  92.5   100   100   100  97.5  97.5    80  97.5   100]; % add the accuracy variable 

%accuracy corrected for gae
n1 = 18; 
design(1,1:n1)       = [94.62105 87.08857 79.55000 91.97027 99.64000 99.51000 94.48421 99.51000 99.51000 91.97027 99.64000 99.36000 99.36000 96.99744 97.13077 79.38750 96.99744 99.64000]; % add the accuracy variable 


cfg = [];
cfg.statistic        = 'ft_statfun_indepsamplesregrT';
cfg.method           = 'montecarlo';
cfg.numrandomization = 1000;
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;   
cfg.alpha            = 0.025;
cfg.channel          = 'Cz'; % %Cz, CPz [31 40];
cfg.neighbours       = neighbours;
cfg.latency          = [0 0.4]; 
cfg.design           = design;
cfg.ivar             = 1;

stats = ft_freqstatistics(cfg, all_Int_alpha_noage{:});

