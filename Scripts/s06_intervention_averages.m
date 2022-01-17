%% Intervention Averages
% September 2021
% The script will average the ERPs and TFRs from the intervention file to
% see what the activity looks like

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Intervention');
all_Int_theta = importdata('all_Theta_Int.mat');
all_Int_alpha = importdata('all_Alpha_Int.mat');
all_Int_beta = importdata('all_Beta_Int.mat');
all_Int_ERP = importdata('all_ERP_Int.mat');

outputpath = ('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Intervention');

%% TOOLS
%ERP Plot
cfg = [];
%cfg.latency = [0.2 0.4];
cfg.showlabels = 'yes';
cfg.layout = layout_file;
ft_multiplotER(cfg, all_Int_ERP{23});

%TFR Plot
cfg = [];
%cfg.latency = [0.2 0.4];
cfg.showlabels = 'yes';
cfg.layout = layout_file;
ft_multiplotTFR(cfg, Int_theta);

%TFR wave plot
cfg = [];
%cfg.latency = [0.2 0.4];
cfg.showlabels = 'yes';
cfg.layout = layout_file;
ft_multiplotER(cfg, Int_beta);
%% Set up a loop

for k=1:length(subjects)
    %get all the data
    datapath = subjects(k).folder;
    outputpath = 'I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Data\Intervention';
    cd(datapath);
    
    %Current file info
    fprintf('Working on %s\n', num2str(subjects(k).name))
    
    %Files 
    currentFolder = dir;
    
    %Data Intervention
    mydata_int_clean_file = dir('*int_clean*.mat');
    mydata_int_clean = importdata(mydata_int_clean_file.name);
    
   
 %%                                          ERP

    cfg = [];
    cfg.baseline = [-0.1 0];
    cfg.latency = [-0.1 1];
    Int_ERP = ft_timelockanalysis(cfg, mydata_int_clean);
    
    %Correct the baseline
    cfg = [];
    cfg.baseline = [-0.1, 0];
    Int_ERP_baseline = ft_timelockbaseline(cfg, Int_ERP);
    
 %SAVE
  
  FileName = [num2str(subjects(k).name), '_Int_ERP.mat'];
  save(fullfile(datapath, FileName), 'Int_ERP_baseline');
  
 
  %save in a structure
  all_Int_ERP{k} = Int_ERP_baseline;
  all_ERP_subjects(k) = subjects(k).name;
  
  %Save the structure file
  save(fullfile(outputpath, 'all_ERP_int.mat'), 'all_Int_ERP');
  save(fullfile(outputpath, 'all_ERP_subjects.mat'), 'all_ERP_subjects');
  
for k=1:length(subjects)
    %get all the data
    datapath = subjects(k).folder;
    outputpath = 'I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Data\Intervention';
    cd(datapath);
    
    %Current file info
    fprintf('Working on %s\n', num2str(subjects(k).name))
    
    %Files 
    currentFolder = dir;
    
    %Data Intervention
    mydata_int_clean_file = dir('*int_clean*.mat');
    mydata_int_clean = importdata(mydata_int_clean_file.name);
    
    
  
 %%                                         TFR
 %wavelet
    cfg             = [];
    cfg.output      = 'pow';
    cfg.method      = 'wavelet';
    cfg.channel     = 'eeg';
    cfg.gwidth      = 3;
    cfg.width       = 5;
    cfg.foi         = 4:0.5:30;
    cfg.toi         = -1.00:0.03125:2.00;
    cfg.keeptrials  = 'yes';
    
    Int_TFR         = ft_freqanalysis(cfg, mydata_int_clean); 
    
  %baseline correction
    cfg                 = [];
    cfg.parameter       = 'powspctrm';
    cfg.baseline        = [-inf inf]; %[-0.4 0]; %[-inf inf];
    cfg.baselinetype    = 'relchange';
    Int_TFR             = ft_freqbaseline(cfg, Int_TFR);
    
  %Average theta
    cfg = [];
    cfg.frequency = [4 8];
    cfg.latency = [-0.4 1];
    cfg.avgoverrpt = 'yes';
    Int_theta = ft_selectdata(cfg, Int_TFR);
  
  %Average alpha
    cfg = [];
    cfg.frequency = [8 12];
    cfg.latency = [-0.4 1];
    cfg.avgoverrpt = 'yes';
    Int_alpha = ft_selectdata(cfg, Int_TFR);
    
  %Average beta
    cfg = [];
    cfg.frequency = [12 30];
    cfg.latency = [-0.4 1];
    cfg.avgoverrpt = 'yes';
    Int_beta = ft_selectdata(cfg, Int_TFR);
    
    
  %SAVE
  
  FileName = [num2str(subjects(k).name), '_Int_theta.mat'];
  save(fullfile(datapath, FileName), 'Int_theta');
  
  FileName = [num2str(subjects(k).name), '_Int_alpha.mat'];
  save(fullfile(datapath, FileName), 'Int_alpha');
  
  FileName = [num2str(subjects(k).name), '_Int_beta.mat'];
  save(fullfile(datapath, FileName), 'Int_beta');
  
 
  %save in a structure
  all_Int_theta{k} = Int_theta;
  all_Int_alpha{k} = Int_alpha;
  all_Int_beta{k} = Int_beta;
  
 %% Save structure files
 
 save(fullfile(outputpath, 'all_Theta_Int.mat'), 'all_Int_theta');
 save(fullfile(outputpath, 'all_Alpha_Int.mat'), 'all_Int_alpha');
 save(fullfile(outputpath, 'all_Beta_Int.mat'), 'all_Int_beta');
 
end 

%% SELECT PARTICIPANTS - remove those that have not been matched 
all_Int_alpha = all_Int_alpha([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
all_Int_theta = all_Int_theta([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
all_Int_beta = all_Int_beta([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
all_Int_ERP = all_Int_ERP([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
subjects = subjects([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);

%all_Int_ERP{23} = [];
%all_Int_ERP{19} = [];
%all_Int_ERP{17} = [];
%all_Int_ERP{8} = [];
%all_Int_ERP{1} = [];

%all_Int_ERP = all_Int_ERP(~cellfun('isempty',all_Int_ERP));

 %%                                                GRAND AVERAGES 
 
 %%                                         Grand averages 
%-------------ERP Grand Average
%------------ Regress out the confound
% I have checked the function for grandaveraging and it does not use
% individual variance to compute the grand averages so the code below
% should be valid for regressing out the impact of the dummy grade variable
% - the dummy grade variable was used instead of continuous age, as the
% continuous age variable is not parametric. Below are data structures for
% both corrected and uncorrected data. The differences can be compared by
% plotting. 

%prepare the grade dummy confound table
age = zeros(length(subjects), 1);
age(:,1) = [subjects.age];

%the individual data would need to be arranged in a new sctructure
for k = 1:length(subjects)
    trials(k,:,:) = all_Int_ERP{k}.avg;
end

all_averaged_ERPs.time = all_Int_ERP{1}.time;
all_averaged_ERPs.label = all_Int_ERP{1}.label;
all_averaged_ERPs.elec = all_Int_ERP{1}.elec;
all_averaged_ERPs.dimord = 'rpt_chan_time';
all_averaged_ERPs.trial = trials;

%remove the confound
cfg = [];
cfg.confound = age;
all_averaged_ERPs_con = ft_regressconfound(cfg, all_averaged_ERPs);

%put these back in a new structure
all_Int_ERP_noage = all_Int_ERP; %copy the old structure
trials_noage = all_averaged_ERPs_con.trial;

for k = 1:length(subjects)
    all_Int_ERP_noage{k}.avg = squeeze(trials_noage(k,:,:));
end


%--------------Grand Average
%cfg = [];
%ERP_Int_all_av = ft_timelockgrandaverage(cfg, all_Int_ERP{:});

cfg = [];
ERP_Int_all_av_noage = ft_timelockgrandaverage(cfg, all_Int_ERP_noage{:});

%plot 
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, ERP_Int_all_av_noage);

%Grand averages for groups

%devide by intervention
%ET_ERP_Int = all_Int_ERP([subjects.group] == 2);
%TS_ERP_Int = all_Int_ERP([subjects.group] == 1);

ET_ERP_Int_noage = all_Int_ERP_noage([subjects.group] == 2);
TS_ERP_Int_noage = all_Int_ERP_noage([subjects.group] == 1);


save(fullfile(outputpath, 'ET_ERP_Int.mat'), 'ET_ERP_Int');
save(fullfile(outputpath, 'TS_ERP_Int.mat'), 'TS_ERP_Int');


%ET
%cfg = [];
%ET_ERP_Int = ft_timelockgrandaverage(cfg, ET_ERP_Int{:});

cfg = [];
ET_ERP_Int_noage = ft_timelockgrandaverage(cfg, ET_ERP_Int_noage{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, ET_ERP_Int, ET_ERP_Int_noage);


%TS
%cfg = [];
%TS_ERP_Int = ft_timelockgrandaverage(cfg, TS_ERP_Int{:});

cfg = [];
TS_ERP_Int_noage = ft_timelockgrandaverage(cfg, TS_ERP_Int_noage{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
%ft_multiplotER(cfg, TS_ERP_Int, ET_ERP_Int);
ft_multiplotER(cfg, TS_ERP_Int, TS_ERP_Int_noage);

%plot with a mask
TS_ERP_Int_noage.mask = stats.mask; %mask
ET_ERP_Int_noage.mask = stats.mask;

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
%cfg.xlim = [0.2 0.25]; 
%cfg.channel = [49 50 52];
%cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
%cfg.maskstyle     = 'box';
ft_multiplotER(cfg, ET_ERP_Int_noage, TS_ERP_Int_noage);

%Standardised topoplot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.xlim = [0.25 0.35]; %time
cfg.ylim = [-3 4]; %amplitude
%ft_multiplotER(cfg, TS_ERP_Int, ET_ERP_Int);
ft_topoplotER (cfg, ET_ERP_Int_noage, TS_ERP_Int_noage);




%---------------------Theta 
%------------ Regress out the confound
% The age effect will have to be regressed out of the three dimensional 
% pwspctrm structure. Below are data structures for
% both corrected and uncorrected data. The differences can be compared by
% plotting. 

%prepare the grade dummy confound table
age = zeros(length(subjects), 1);
age(:,1) = [subjects.age];

%the individual data would need to be arranged in a new sctructure
for k = 1:length(subjects)
    powspctrm(k,:,:,:) = all_Int_theta{k}.powspctrm;
end

all_averaged_theta.time = all_Int_theta{1}.time;
all_averaged_theta.label = all_Int_theta{1}.label;
all_averaged_theta.elec = all_Int_theta{1}.elec;
all_averaged_theta.dimord = 'rpt_chan_freq_time';
all_averaged_theta.freq = all_Int_theta{1}.freq;
all_averaged_theta.powspctrm = powspctrm;

%remove the confound
cfg = [];
cfg.confound = age;
all_averaged_theta_con = ft_regressconfound(cfg, all_averaged_theta);

%put these back in a new structure
all_Int_theta_noage = all_Int_theta; %copy the old structure
powspctrm_noage = all_averaged_theta_con.powspctrm;

for k = 1:length(subjects)
    all_Int_theta_noage{k}.powspctrm = squeeze(powspctrm_noage(k,:,:,:));
end



%For all
cfg = [];
Theta_Int_all_av = ft_freqgrandaverage(cfg, all_Int_theta{:});

cfg = [];
Theta_Int_all_av_noage = ft_freqgrandaverage(cfg, all_Int_theta_noage{:});

%plot 
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.2 0.2];
ft_multiplotTFR(cfg, Theta_Int_all_av_noage);

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, Theta_Int_all_av, Theta_Int_all_av_noage);

%For groups
%devide by intervention
ET_Theta_Int = all_Int_theta([subjects.group] == 2);
TS_Theta_Int = all_Int_theta([subjects.group] == 1);

ET_Theta_Int_noage = all_Int_theta_noage([subjects.group] == 2);
TS_Theta_Int_noage = all_Int_theta_noage([subjects.group] == 1);

save(fullfile(outputpath, 'ET_Theta_Int.mat'), 'ET_Theta_Int');
save(fullfile(outputpath, 'TS_Theta_Int.mat'), 'TS_Theta_Int');
 
%ET
cfg = [];
ET_Theta_Int = ft_freqgrandaverage(cfg, ET_Theta_Int{:});

cfg = [];
ET_Theta_Int_noage = ft_freqgrandaverage(cfg, ET_Theta_Int_noage{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.2 0.2];
ft_multiplotTFR(cfg, ET_Theta_Int_noage);

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.2 0.2];
ft_multiplotER(cfg, ET_Theta_Int, ET_Theta_Int_noage);

%TS
cfg = [];
TS_Theta_Int = ft_freqgrandaverage(cfg, TS_Theta_Int{:});

cfg = [];
TS_Theta_Int_noage = ft_freqgrandaverage(cfg, TS_Theta_Int_noage{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.2 0.2];
ft_multiplotTFR(cfg, TS_Theta_Int_noage);

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.2 0.2];
ft_multiplotER(cfg, TS_Theta_Int, TS_Theta_Int_noage);


%Diff plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, TS_Theta_Int_noage, ET_Theta_Int_noage);


%---------------------Alpha 
%------------ Regress out the confound
% The age effect will have to be regressed out of the three dimensional 
% pwspctrm structure. Below are data structures for
% both corrected and uncorrected data. The differences can be compared by
% plotting. 

%prepare the grade dummy confound table
age = zeros(length(subjects), 1);
age(:,1) = [subjects.age];

%the individual data would need to be arranged in a new sctructure
for k = 1:length(subjects)
    powspctrm(k,:,:,:) = all_Int_alpha{k}.powspctrm;
end

all_averaged_alpha.time = all_Int_alpha{1}.time;
all_averaged_alpha.label = all_Int_alpha{1}.label;
all_averaged_alpha.elec = all_Int_alpha{1}.elec;
all_averaged_alpha.dimord = 'rpt_chan_freq_time';
all_averaged_alpha.freq = all_Int_alpha{1}.freq;
all_averaged_alpha.powspctrm = powspctrm;

%remove the confound
cfg = [];
cfg.confound = age;
all_averaged_alpha_con = ft_regressconfound(cfg, all_averaged_alpha);

%put these back in a new structure
all_Int_alpha_noage = all_Int_alpha; %copy the old structure
powspctrm_noage = all_averaged_alpha_con.powspctrm;

for k = 1:length(subjects)
    all_Int_alpha_noage{k}.powspctrm = squeeze(powspctrm_noage(k,:,:,:));
end




%For all
cfg = [];
Alpha_Int_all_av = ft_freqgrandaverage(cfg, all_Int_alpha{:});

cfg = [];
Alpha_Int_all_av_noage = ft_freqgrandaverage(cfg, all_Int_alpha_noage{:});

%plot 
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.1 0.2];
ft_multiplotTFR(cfg, Alpha_Int_all_av_noage);

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, TS_Alpha_Int_noage{:});

%For groups
%devide by intervention
ET_Alpha_Int = all_Int_alpha([subjects.group] == 2);
TS_Alpha_Int = all_Int_alpha([subjects.group] == 1);

ET_Alpha_Int_noage = all_Int_alpha_noage([subjects.group] == 2);
TS_Alpha_Int_noage = all_Int_alpha_noage([subjects.group] == 1);

save(fullfile(outputpath, 'ET_Alpha_Int.mat'), 'ET_Alpha_Int');
save(fullfile(outputpath, 'TS_Alpha_Int.mat'), 'TS_Alpha_Int');
 
%ET
cfg = [];
ET_Alpha_Int = ft_freqgrandaverage(cfg, ET_Alpha_Int{:});

cfg = [];
ET_Alpha_Int_noage = ft_freqgrandaverage(cfg, ET_Alpha_Int_noage{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.1 0.2];
ft_multiplotTFR(cfg, ET_Alpha_Int_noage);

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.1 0.2];
ft_multiplotER(cfg, ET_Alpha_Int, ET_Alpha_Int_noage);

%TS
cfg = [];
TS_Alpha_Int = ft_freqgrandaverage(cfg, TS_Alpha_Int{:});

cfg = [];
TS_Alpha_Int_noage = ft_freqgrandaverage(cfg, TS_Alpha_Int_noage{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.1 0.2];
ft_multiplotTFR(cfg, TS_Alpha_Int_noage);

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.1 0.2];
ft_multiplotER(cfg, TS_Alpha_Int, TS_Alpha_Int_noage);


%Diff plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, TS_Alpha_Int_noage, ET_Alpha_Int_noage);


%---------------------Beta 
%For all
cfg = [];
Beta_Int_all_av = ft_freqgrandaverage(cfg, all_Int_beta{:});

%plot 
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotTFR(cfg, Beta_Int_all_av);

%For groups
%devide by intervention
ET_Beta_Int = all_Int_beta([subjects.group] == 1);
TS_Beta_Int = all_Int_beta([subjects.group] == 2);

save(fullfile(outputpath, 'ET_Beta_Int.mat'), 'ET_Beta_Int');
save(fullfile(outputpath, 'TS_Beta_Int.mat'), 'TS_Beta_Int');
 
%ET
cfg = [];
ET_Beta_Int = ft_freqgrandaverage(cfg, ET_Beta_Int{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotTFR(cfg, ET_Beta_Int);

%TS
cfg = [];
TS_Beta_Int = ft_freqgrandaverage(cfg, TS_Beta_Int{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotTFR(cfg, TS_Beta_Int);


%Diff plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, TS_Beta_Int, ET_Beta_Int);


    
 
 