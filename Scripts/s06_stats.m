%% Stats for intervention analyses
% December 2021
% The script will run between-subject and regression permutation analyses on the intervention ERPs 

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration

%load the data
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Intervention');
ET_ERP_Int = importdata('ET_ERP_Int.mat');
TS_ERP_Int = importdata('TS_ERP_Int.mat');
all_Int_ERP_noage = importdata('all_ERP_int_noage.mat');
    
%%                                                  BETWEEN GROUP TESTS
%% Prepare the groups

% Place the group value in a separate array 
group = ones(1, (length(TS_ERP_Int)+length(ET_ERP_Int)));
group((length(TS_ERP_Int)+1): end) = 2;

%% Setup study design 
% Define the study design: in this example it is a between-group t-test.
% ivar = the independent variable, i.e. group or condition.
% uvar = unit of observation, i.e. identifier per subject 

n_ctrl = sum(group == 1); % number of TS
n_Dptns = sum(group == 2); % number of ET

ivar  = [ones(n_ctrl,1); ones(n_Dptns,1)*2]; %this is the group variable as a column
uvar  = 1:length(group); %number of participants
design = [group; uvar]';

%% Between-group permutation P300a

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Stats');

cfg = [];
cfg.method              = 'montecarlo'; 
cfg.statistic           = 'ft_statfun_indepsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;        
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;            % = two-tailed hypothesis
cfg.alpha               = 0.025;        % = 0.05/2 for two-tailed hypothesis
cfg.channel             = [12 13 14]; %F1, Fz, F2
cfg.latency             = [0.15 0.3]; 
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.ivar                = 1; %group identifier specifies the column in the matrix "design" which is the independent variable
stats = ft_timelockstatistics(cfg, TS_ERP_Int{:}, ET_ERP_Int{:}); 

save stats_P300a_int stats;

%%Plot t-values for clusters
cfg               = [];
cfg.marker        = 'on';
cfg.layout        = layout_file;
cfg.channel       = 'EEG';
cfg.parameter     = 'stat';  % plot the t-value
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'box';
figure; ft_multiplotER(cfg, stats);

% identify the cluster latency P300
pos = stats.posclusterslabelmat == 1;
pos =[pos;stats.time];

save cluster_P300a_int pos;


%% Between-group permutation N200

cfg = [];
cfg.method              = 'montecarlo'; 
cfg.statistic           = 'ft_statfun_indepsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;        
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;            % = two-tailed hypothesis
cfg.alpha               = 0.025;        % = 0.05/2 for two-tailed hypothesis
cfg.channel             = [49 50 51]; %P1 Pz P2
cfg.latency             = [0.2 0.25]; 
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.ivar                = 1; %group identifier specifies the column in the matrix "design" which is the independent variable
stats = ft_timelockstatistics(cfg, TS_ERP_Int{:}, ET_ERP_Int{:}); 

save stats_N200_int stats;

%%Plot t-values for clusters
cfg               = [];
cfg.marker        = 'on';
cfg.layout        = layout_file;
cfg.channel       = 'EEG';
cfg.parameter     = 'stat';  % plot the t-value
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'box';
figure; ft_multiplotER(cfg, stats);

% identify the cluster latency P300
neg = stats.negclusterslabelmat == 1;
neg =[neg;stats.time];

save cluster_N200_int neg;


%% Between-group permutation P300b

cfg = [];
cfg.method              = 'montecarlo'; 
cfg.statistic           = 'ft_statfun_indepsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;        
cfg.clusterstatistic    = 'maxsum';
cfg.tail                = 0;
cfg.clustertail         = 0;            % = two-tailed hypothesis
cfg.alpha               = 0.025;        % = 0.05/2 for two-tailed hypothesis
cfg.channel             = [49 50 51]; %P1 Pz P2
cfg.latency             = [0.3 0.4]; 
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.ivar                = 1; %group identifier specifies the column in the matrix "design" which is the independent variable
stats = ft_timelockstatistics(cfg, TS_ERP_Int{:}, ET_ERP_Int{:}); 

save stats_P300b_int stats;



%% ----------------------- REGRESSION WITH TASK ACCURACY
%make sure that the design structre doesn't get confused with the
%between-subject design so clear it first
clear design
clear stats
%accuracy corrected for age
n1 = 18; 
design(1,1:n1)       = [94.62105 87.08857 79.55000 91.97027 99.64000 99.51000 94.48421 99.51000 99.51000 91.97027 99.64000 99.36000 99.36000 96.99744 97.13077 79.38750 96.99744 99.64000]; % add the accuracy variable 


%--------------------------- P300a

cfg = [];
cfg.statistic        = 'ft_statfun_indepsamplesregrT';
cfg.method           = 'montecarlo';
cfg.numrandomization = 1000;
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;   
cfg.alpha            = 0.025;
cfg.channel          = [12 13 14]; %F1, Fz, F2
cfg.neighbours       = neighbours;
cfg.latency          = [0.15 0.3]; 
cfg.design           = design;
cfg.ivar             = 1;

stats = ft_timelockstatistics(cfg, all_Int_ERP_noage{:});

save regr_P300a_int stats;


%--------------------------- N200

cfg = [];
cfg.statistic        = 'ft_statfun_indepsamplesregrT';
cfg.method           = 'montecarlo';
cfg.numrandomization = 1000;
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;   
cfg.alpha            = 0.025;
cfg.channel          = [49 50 51]; %P1 Pz P2
cfg.neighbours       = neighbours;
cfg.latency          = [0.2 0.25]; 
cfg.design           = design;
cfg.ivar             = 1;

stats = ft_timelockstatistics(cfg, all_Int_ERP_noage{:});

save regr_N200_int stats;




%% Effect sizes for the between subject analyses

%P300a 
%calculate the mean for each channel and then the mean for the whole
%cluster

F1_cluster = [0.1882 0.2117];
Fz_cluster = [0.1824 0.2449];
F2_cluster = [0.1941 0.2449];

P1_cluster = [0.2 0.2292];
Pz_cluster = [0.2 0.2214];
P2_cluster = [0.2 0.2410];



for k=1:length(ET_ERP_Int)

cfg = [];
cfg.latency = F1_cluster;
cfg.channel = 'F1';
F1_ET = ft_selectdata(cfg, ET_ERP_Int{k});
F1_ET = mean(F1_ET.avg);

N200_ET_amp(k).F1 = F1_ET;

cfg = [];
cfg.latency = Fz_cluster;
cfg.channel = 'Fz';
Fz_ET = ft_selectdata(cfg, ET_ERP_Int{k});
Fz_ET = mean(Fz_ET.avg);

N200_ET_amp(k).Fz = Fz_ET;

cfg = [];
cfg.latency = F2_cluster;
cfg.channel = 'F2';
F2_ET = ft_selectdata(cfg, ET_ERP_Int{k});
F2_ET = mean(F2_ET.avg);

N200_ET_amp(k).F2 = F2_ET;


N200_ET_amp(k).clusterF = mean([N200_ET_amp(k).F1, N200_ET_amp(k).Fz, N200_ET_amp(k).F2]);



cfg = [];
cfg.latency = F1_cluster;
cfg.channel = 'F1';
F1_TS = ft_selectdata(cfg, TS_ERP_Int{k});
F1_TS = mean(F1_TS.avg);

N200_TS_amp(k).F1 = F1_TS;

cfg = [];
cfg.latency = Fz_cluster;
cfg.channel = 'Fz';
Fz_TS = ft_selectdata(cfg, TS_ERP_Int{k});
Fz_TS = mean(Fz_TS.avg);

N200_TS_amp(k).Fz = Fz_TS;

cfg = [];
cfg.latency = F2_cluster;
cfg.channel = 'F2';
F2_TS = ft_selectdata(cfg, TS_ERP_Int{k});
F2_TS = mean(F2_TS.avg)

N200_TS_amp(k).F2 = F2_TS;


N200_TS_amp(k).clusterF = mean([N200_TS_amp(k).F1, N200_TS_amp(k).Fz, N200_TS_amp(k).F2]);


% N200
%calculate the mean for each channel and then the mean for the whole
%cluster


cfg = [];
cfg.latency = P1_cluster;
cfg.channel = 'P1';
P1_ET = ft_selectdata(cfg, ET_ERP_Int{k});
P1_ET = mean(P1_ET.avg);

N200_ET_amp(k).P1 = P1_ET;

cfg = [];
cfg.latency = Pz_cluster;
cfg.channel = 'Pz';
Pz_ET = ft_selectdata(cfg, ET_ERP_Int{k});
Pz_ET = mean(Pz_ET.avg);

N200_ET_amp(k).Pz = Pz_ET;

cfg = [];
cfg.latency = P2_cluster;
cfg.channel = 'P2';
P2_ET = ft_selectdata(cfg, ET_ERP_Int{k});
P2_ET = mean(P2_ET.avg);

N200_ET_amp(k).P2 = P2_ET;


N200_ET_amp(k).clusterP = mean([N200_ET_amp(k).P1, N200_ET_amp(k).Pz, N200_ET_amp(k).P2]);



cfg = [];
cfg.latency = P1_cluster;
cfg.channel = 'P1';
P1_TS = ft_selectdata(cfg, TS_ERP_Int{k});
P1_TS = mean(P1_TS.avg);

N200_TS_amp(k).P1 = P1_TS;

cfg = [];
cfg.latency = Pz_cluster;
cfg.channel = 'Pz';
Pz_TS = ft_selectdata(cfg, TS_ERP_Int{k});
Pz_TS = mean(Pz_TS.avg);

N200_TS_amp(k).Pz = Pz_TS;

cfg = [];
cfg.latency = P2_cluster;
cfg.channel = 'P2';
P2_TS = ft_selectdata(cfg, TS_ERP_Int{k});
P2_TS = mean(P2_TS.avg)

N200_TS_amp(k).P2 = P2_TS;


N200_TS_amp(k).clusterP = mean([N200_TS_amp(k).P1, N200_TS_amp(k).Pz, N200_TS_amp(k).P2]);

end 



x1 = [N200_ET_amp.clusterF]; 
x2 = [N200_TS_amp.clusterF]; 
dF = computeCohen_d(x1, x2, 'paired')

x1 = [N200_ET_amp.clusterP]; 
x2 = [N200_TS_amp.clusterP]; 
dP = computeCohen_d(x1, x2, 'paired')



