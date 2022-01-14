%% TFRs Averaged
% September 2021
% The script will extact time-frequency wavelets per participant, extract the baseline from the post intervention measure and collate the data in a
% common structure ready for statistical analyses

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Scripts');
configuration

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Data\Pre_post')
all_Pre_TFR_theta = importdata('all_Theta_Pre.mat');
all_Post_TFR_theta = importdata('all_Theta_Post.mat');
all_Diff_theta = importdata('all_Theta_Diff.mat');

all_Pre_TFR_alpha = importdata('all_Alpha_Pre.mat');
all_Post_TFR_alpha = importdata('all_Alpha_Post.mat');
all_Diff_alpha = importdata('all_Alpha_Diff.mat');


%% Tools
 
  %plot theta
    cfg = [];
    %cfg.latency = [0.2 0.3];
    cfg.showlabels = 'yes';
    cfg.layout = layout_file;
    cfg.zlim = [-0.15 0.4];
    ft_multiplotTFR(cfg, G1_Theta_Pre);
    
   %plot alpha
    cfg = [];
    cfg.latency = [-0.1 0.3];
    cfg.showlabels = 'yes';
    cfg.layout = layout_file;
    cfg.zlim = [-0.1 0.3];
    ft_multiplotTFR(cfg, ET_Alpha_Pre);
    
    %plot difference
    %theta
    cfg = [];
    %cfg.latency = [0.2 0.4];
    cfg.showlabels = 'yes';
    cfg.layout = layout_file;
    ft_multiplotER(cfg, Diff_Theta);
    
    %alpha
    cfg = [];
    %cfg.latency = [0.2 0.4];
    cfg.showlabels = 'yes';
    cfg.layout = layout_file;
    ft_multiplotER(cfg, Diff_Alpha);
    
    

%% Set up a loop

for k=1:length(subjects)
    %get all the data
    datapath = subjects(k).folder;
    outputpath = 'I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Data\Pre_post';
    cd(datapath);
    
    %Current file info
    fprintf('Working on %s\n', num2str(subjects(k).name))
    
    %Files 
    currentFolder = dir;
    
    %Data pre
    mydata_pre_clean_file = dir('*pre_clean*.mat');
    mydata_pre_clean = importdata(mydata_pre_clean_file.name);
    
    %Data post
    mydata_post_clean_file = dir('*post_clean*.mat');
    mydata_post_clean = importdata(mydata_post_clean_file.name);
    
 %% EXTRACT THE WAVELETS PRE
 %wavelet
    cfg             = [];
    cfg.output      = 'pow';
    cfg.method      = 'wavelet';
    cfg.channel     = 'eeg';
    cfg.gwidth      = 3;
    cfg.width       = 5;
    cfg.foi         = 4:1:30;
    cfg.toi         = -1.00:0.0625:2.00;
    cfg.keeptrials  = 'yes';
    
    Pre_TFR         = ft_freqanalysis(cfg, mydata_pre_clean); 
    
  %baseline correction
    cfg                 = [];
    cfg.parameter       = 'powspctrm';
    cfg.baseline        = [-inf inf];
    cfg.baselinetype    = 'relchange';
    Pre_TFR             = ft_freqbaseline(cfg, Pre_TFR);
    
  %Average theta
    cfg = [];
    cfg.frequency = [4 8];
    cfg.latency = [-0.1 1];
    cfg.avgoverrpt = 'yes';
    Pre_TFR_theta = ft_selectdata(cfg, Pre_TFR);
  
  %Average alpha
    cfg = [];
    cfg.frequency = [8 12];
    cfg.latency = [-0.1 1];
    cfg.avgoverrpt = 'yes';
    Pre_TFR_alpha = ft_selectdata(cfg, Pre_TFR);
 
    
 
 %% EXTRACT THE WAVELETS POST
  %wavelet
    cfg             = [];
    cfg.output      = 'pow';
    cfg.method      = 'wavelet';
    cfg.channel     = 'eeg';
    cfg.gwidth      = 3;
    cfg.width       = 5;
    cfg.foi         = 4:1:30;
    cfg.toi         = -1.00:0.0625:2.00;
    cfg.keeptrials  = 'yes';
    
    Post_TFR        = ft_freqanalysis(cfg, mydata_post_clean); 
    
  %baseline correction
    cfg                 = [];
    cfg.parameter       = 'powspctrm';
    cfg.baseline        = [-inf inf];
    cfg.baselinetype    = 'relchange';
    Post_TFR            = ft_freqbaseline(cfg, Post_TFR);
    
  %Average theta
    cfg             = [];
    cfg.frequency   = [4 8];
    cfg.latency     = [-0.1 1];
    cfg.avgoverrpt  = 'yes';
    Post_TFR_theta  = ft_selectdata(cfg, Post_TFR);
  
  %Average alpha
    cfg             = [];
    cfg.frequency   = [8 12];
    cfg.latency     = [-0.1 1];
    cfg.avgoverrpt  = 'yes';
    Post_TFR_alpha  = ft_selectdata(cfg, Post_TFR);
 
 %% EXTRACT THE DIFFERENCE WAVELETS
 
 %theta
    cfg             = [];
    cfg.operation   = 'x2-x1';
    cfg.parameter   ='powspctrm';
    
    Diff_theta      = ft_math(cfg, Post_TFR_theta, Pre_TFR_theta); 
    
  %alpha
    cfg             = [];
    cfg.operation   = 'x2-x1';
    cfg.parameter   ='powspctrm';
    
    Diff_alpha      = ft_math(cfg, Post_TFR_alpha, Pre_TFR_alpha); 
 
 %% SAVE
 %save the indivisual files (datapath)
  FileName = [num2str(subjects(k).name), '_Pre_Theta.mat'];
  save(fullfile(datapath, FileName), 'Pre_TFR_theta');
 
  FileName = [num2str(subjects(k).name), '_Post_Theta.mat'];
  save(fullfile(datapath, FileName), 'Post_TFR_theta');
  
  FileName = [num2str(subjects(k).name), '_Diff_Theta.mat'];
  save(fullfile(datapath, FileName), 'Diff_theta');
  
  
  FileName = [num2str(subjects(k).name), '_Pre_Alpha.mat'];
  save(fullfile(datapath, FileName), 'Pre_TFR_alpha');
 
  FileName = [num2str(subjects(k).name), '_Post_Alpha.mat'];
  save(fullfile(datapath, FileName), 'Post_TFR_alpha');
  
  FileName = [num2str(subjects(k).name), '_Diff_Alpha.mat'];
  save(fullfile(datapath, FileName), 'Diff_alpha');
  
 %save to a structure file for stats and grand averages 
 all_Pre_TFR_theta{k} = Pre_TFR_theta;
 all_Post_TFR_theta{k} = Post_TFR_theta;
 all_Diff_theta{k} = Diff_theta;
 
 all_Pre_TFR_alpha{k} = Pre_TFR_alpha;
 all_Post_TFR_alpha{k} = Post_TFR_alpha;
 all_Diff_alpha{k} = Diff_alpha;
 
 %save the structure file (outputpath)
 save(fullfile(outputpath, 'all_Theta_Pre.mat'), 'all_Pre_TFR_theta');
 save(fullfile(outputpath, 'all_Theta_Post.mat'), 'all_Post_TFR_theta');
 save(fullfile(outputpath, 'all_Theta_Diff.mat'), 'all_Diff_theta');
 
 save(fullfile(outputpath, 'all_Alpha_Pre.mat'), 'all_Pre_TFR_alpha');
 save(fullfile(outputpath, 'all_Alpha_Post.mat'), 'all_Post_TFR_alpha');
 save(fullfile(outputpath, 'all_Alpha_Diff.mat'), 'all_Diff_alpha');
 
end

%% SELECT PARTICIPANTS - remove those that have not been matched 
all_Diff_theta = all_Diff_theta([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
all_Diff_alpha = all_Diff_alpha([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
all_Post_TFR_alpha = all_Post_TFR_alpha([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
all_Post_TFR_theta = all_Post_TFR_theta([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
all_Pre_TFR_alpha = all_Pre_TFR_alpha([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
all_Pre_TFR_theta = all_Pre_TFR_theta([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
subjects = subjects([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);

%%                                                GRAND AVERAGES 
%---------------------Theta 
%For all
cfg = [];
Theta_Pre_all_av = ft_freqgrandaverage(cfg, all_Pre_TFR_theta{:});

cfg = [];
Theta_Post_all_av = ft_freqgrandaverage(cfg, all_Post_TFR_theta{:});

%plot 
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, Theta_Pre_all_av, Theta_Post_all_av);

%For groups
%devide by intervention
ET_Theta_Pre = all_Pre_TFR_theta([subjects.group] == 2);
TS_Theta_Pre = all_Pre_TFR_theta([subjects.group] == 1);

ET_Theta_Post = all_Post_TFR_theta([subjects.group] == 2);
TS_Theta_Post = all_Post_TFR_theta([subjects.group] == 1);

ET_Theta_Diff = all_Diff_theta([subjects.group] == 2);
TS_Theta_Diff = all_Diff_theta([subjects.group] == 1);

save(fullfile(outputpath, 'ET_Theta_Pre.mat'), 'ET_Theta_Pre');
save(fullfile(outputpath, 'TS_Theta_Pre.mat'), 'TS_Theta_Pre'); 
save(fullfile(outputpath, 'ET_Theta_Post.mat'), 'ET_Theta_Post'); 
save(fullfile(outputpath, 'TS_Theta_Post.mat'), 'TS_Theta_Post');
save(fullfile(outputpath, 'ET_Theta_Diff.mat'), 'ET_Theta_Diff'); 
save(fullfile(outputpath, 'TS_Theta_Diff.mat'), 'TS_Theta_Diff'); 

%ET
cfg = [];
ET_Theta_Pre = ft_freqgrandaverage(cfg, ET_Theta_Pre{:});

cfg = [];
ET_Theta_Post = ft_freqgrandaverage(cfg, ET_Theta_Post{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, ET_Theta_Pre, ET_Theta_Post);

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.15 0.4];
ft_multiplotTFR(cfg, ET_Theta_Post);


%TS
cfg = [];
TS_Theta_Pre = ft_freqgrandaverage(cfg, TS_Theta_Pre{:});

cfg = [];
TS_Theta_Post = ft_freqgrandaverage(cfg, TS_Theta_Post{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.linecolor = colours;
%ft_multiplotER(cfg, TS_Theta_Pre, TS_Theta_Post);
ft_multiplotER(cfg, TS_Theta_Pre, ET_Theta_Pre);


%Diff
cfg = [];
TS_Theta_Diff = ft_freqgrandaverage(cfg, TS_Theta_Diff{:});
%these are the wrong way round so have to be flipped
TS_Theta_Diff.powspctrm = TS_Theta_Diff.powspctrm*-1;

cfg = [];
ET_Theta_Diff = ft_freqgrandaverage(cfg, ET_Theta_Diff{:});
%these are the wrong way round so have to be flipped
ET_Theta_Diff.powspctrm = ET_Theta_Diff.powspctrm*-1;

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.linecolor = colours;
%ft_multiplotER(cfg, TS_Theta_Diff, ET_Theta_Diff);
ft_multiplotER(cfg, TS_Theta_Pre, TS_Theta_Post, ET_Theta_Pre, ET_Theta_Post, TS_Theta_Diff, ET_Theta_Diff);

%% Divide by age
G0_Theta_Pre = all_Pre_TFR_theta([subjects.grade] == 0);
G1_Theta_Pre = all_Pre_TFR_theta([subjects.grade] == 1);

G0_Theta_Post = all_Post_TFR_theta([subjects.grade] == 0);
G1_Theta_Post = all_Post_TFR_theta([subjects.grade] == 1);

G0_Theta_Diff = all_Diff_theta([subjects.grade] == 0);
G1_Theta_Diff = all_Diff_theta([subjects.grade] == 1);

%average
cfg = [];
G0_Theta_Pre = ft_freqgrandaverage(cfg, G0_Theta_Pre{:});

cfg = [];
G1_Theta_Pre = ft_freqgrandaverage(cfg, G1_Theta_Pre{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.linecolor = colours;
ft_multiplotER(cfg, G0_Theta_Pre, G1_Theta_Pre);


%---------------------Alpha 
%For all
cfg = [];
Alpha_Pre_all_av = ft_freqgrandaverage(cfg, all_Pre_TFR_alpha{:});

cfg = [];
Alpha_Post_all_av = ft_freqgrandaverage(cfg, all_Post_TFR_alpha{:});

%plot 
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, Alpha_Pre_all_av, Alpha_Post_all_av);

%For groups
%devide by intervention
ET_Alpha_Pre = all_Pre_TFR_alpha([subjects.group] == 2);
TS_Alpha_Pre = all_Pre_TFR_alpha([subjects.group] == 1);

ET_Alpha_Post = all_Post_TFR_alpha([subjects.group] == 2);
TS_Alpha_Post = all_Post_TFR_alpha([subjects.group] == 1);

ET_Alpha_Diff = all_Diff_alpha([subjects.group] == 2);
TS_Alpha_Diff = all_Diff_alpha([subjects.group] == 1);

save(fullfile(outputpath, 'ET_Alpha_Pre.mat'), 'ET_Alpha_Pre');
save(fullfile(outputpath, 'TS_Alpha_Pre.mat'), 'TS_Alpha_Pre'); 
save(fullfile(outputpath, 'ET_Alpha_Post.mat'), 'ET_Alpha_Post'); 
save(fullfile(outputpath, 'TS_Alpha_Post.mat'), 'TS_Alpha_Post');
save(fullfile(outputpath, 'ET_Alpha_Diff.mat'), 'ET_Alpha_Diff'); 
save(fullfile(outputpath, 'TS_Alpha_Diff.mat'), 'TS_Alpha_Diff'); 

%ET
cfg = [];
ET_Alpha_Pre = ft_freqgrandaverage(cfg, ET_Alpha_Pre{:});

cfg = [];
ET_Alpha_Post = ft_freqgrandaverage(cfg, ET_Alpha_Post{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, ET_Alpha_Pre, ET_Alpha_Post);

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.zlim = [-0.15 0.4];
ft_multiplotTFR(cfg, TS_Alpha_Post);


%TS
cfg = [];
TS_Alpha_Pre = ft_freqgrandaverage(cfg, TS_Alpha_Pre{:});

cfg = [];
TS_Alpha_Post = ft_freqgrandaverage(cfg, TS_Alpha_Post{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.linecolor = colours;
ft_multiplotER(cfg, TS_Alpha_Pre, ET_Alpha_Pre);


%Diff
cfg = [];
TS_Alpha_Diff = ft_freqgrandaverage(cfg, TS_Alpha_Diff{:});
%these are the wrong way round so have to be flipped
TS_Alpha_Diff.powspctrm = TS_Alpha_Diff.powspctrm*-1;

cfg = [];
ET_Alpha_Diff = ft_freqgrandaverage(cfg, ET_Alpha_Diff{:});
%these are the wrong way round so have to be flipped
ET_Alpha_Diff.powspctrm = ET_Alpha_Diff.powspctrm*-1;

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.linecolor = colours;
%ft_multiplotER(cfg, TS_Alpha_Diff, ET_Alpha_Diff);
ft_multiplotER(cfg, TS_Alpha_Pre, TS_Alpha_Post, ET_Alpha_Pre, ET_Alpha_Post, TS_Alpha_Diff, ET_Alpha_Diff);


%% Divide by age
G0_Alpha_Pre = all_Pre_TFR_alpha([subjects.grade] == 0);
G1_Alpha_Pre = all_Pre_TFR_alpha([subjects.grade] == 1);

G0_Alpha_Post = all_Post_TFR_alpha([subjects.grade] == 0);
G1_Alpha_Post = all_Post_TFR_alpha([subjects.grade] == 1);

G0_Alpha_Diff = all_Diff_alpha([subjects.grade] == 0);
G1_Alpha_Diff = all_Diff_alpha([subjects.grade] == 1);

%average
cfg = [];
G0_Alpha_Pre = ft_freqgrandaverage(cfg, G0_Alpha_Pre{:});

cfg = [];
G1_Alpha_Pre = ft_freqgrandaverage(cfg, G1_Alpha_Pre{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.linecolor = colours;
ft_multiplotER(cfg, G0_Alpha_Pre, G1_Alpha_Pre);

 