%% ERPs Averaged
% September 2021
% The script will average P300 per participant, extract the baseline from the post intervention measure and collate the data in a
% common structure ready for statistical analyses

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Scripts');
configuration

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\Data\Pre_post');
all_P300_Diff = importdata('all_P300_Diff.mat');
all_P300_Post = importdata('all_P300_Post.mat');
all_P300_Pre = importdata('all_P300_Pre.mat');

%% TOOLS FOR PLOTTING
colours = [0.0 0.1 0.8 %dark blue
           0.0 0.8 0.9 %light blue
           0.1 0.5 0.1 %dark green
           0.1 1 0 %light green
           0.8 0 0.2 %red
           0.8 0.6 0]; %yellow

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, all_P300_Pre{19});

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
    
 %%                                          PRE

    cfg = [];
    cfg.baseline = [-0.1 0];
    cfg.latency = [-0.1 0.8];
    Pre_P300 = ft_timelockanalysis(cfg, mydata_pre_clean);
    
    %Correct the baseline
    cfg = [];
    cfg.baseline = [-0.1, 0];
    Pre_P300_baseline = ft_timelockbaseline(cfg, Pre_P300);
  
  %%                                          POST

    cfg = [];
    cfg.baseline = [-0.1 0];
    cfg.latency = [-0.1 0.8];
    Post_P300 = ft_timelockanalysis(cfg, mydata_post_clean);
    
    %Correct the baseline
    cfg = [];
    cfg.baseline = [-0.1, 0];
    Post_P300_baseline = ft_timelockbaseline(cfg, Post_P300);
    
    
  %%                                          DIFF
  
  cfg = [];
  cfg.operation = 'x2-x1';
  cfg.parameter = 'avg';

  Diff_P300 = ft_math(cfg, Post_P300_baseline, Pre_P300_baseline);
    
  %%                                          SAVE
  
  FileName = [num2str(subjects(k).name), '_Pre_P300.mat'];
  save(fullfile(datapath, FileName), 'Pre_P300_baseline');
  
  FileName = [num2str(subjects(k).name), '_Post_P300.mat'];
  save(fullfile(datapath, FileName), 'Post_P300_baseline');
  
  
  FileName = [num2str(subjects(k).name), '_Diff_P300.mat'];
  save(fullfile(datapath, FileName), 'Diff_P300');
  
  %save in a structure
  all_P300_Pre{k} = Pre_P300_baseline;
  all_P300_Post{k} = Post_P300_baseline;
  all_P300_Diff{k} = Diff_P300;
    
end

save(fullfile(outputpath, 'all_P300_Pre.mat'), 'all_P300_Pre');
save(fullfile(outputpath, 'all_P300_Post.mat'), 'all_P300_Post'); 
save(fullfile(outputpath, 'all_P300_Diff.mat'), 'all_P300_Diff'); 

%% SELECT PARTICIPANTS - remove those that have not been matched 
%all_P300_Diff = all_P300_Diff([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);  
%all_P300_Post = all_P300_Post([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);   
%all_P300_Pre = all_P300_Pre([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010); 
%subjects = subjects([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010); 

all_P300_Diff = all_P300_Diff([subjects.name] ~= 1001 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);  
all_P300_Post = all_P300_Post([subjects.name] ~= 1001 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);   
all_P300_Pre = all_P300_Pre([subjects.name] ~= 1001 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010); 
subjects = subjects([subjects.name] ~= 1001 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010); 




%%                                         Grand averages 
%for all
cfg = [];
P300_Pre_all_av = ft_timelockgrandaverage(cfg, all_P300_Pre{:});

cfg = [];
P300_Post_all_av = ft_timelockgrandaverage(cfg, all_P300_Post{:});

%plot 
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, P300_Pre_all_av, P300_Post_all_av);

%Grand averages for groups

cd(outputpath)
%devide by intervention
ET_P300_Pre = all_P300_Pre([subjects.group] == 2);
TS_P300_Pre = all_P300_Pre([subjects.group] == 1);

ET_P300_Post = all_P300_Post([subjects.group] == 2);
TS_P300_Post = all_P300_Post([subjects.group] == 1);

ET_P300_Diff = all_P300_Diff([subjects.group] == 2);
TS_P300_Diff = all_P300_Diff([subjects.group] == 1);

save(fullfile(outputpath, 'ET_P300_Pre.mat'), 'ET_P300_Pre');
save(fullfile(outputpath, 'TS_P300_Pre.mat'), 'TS_P300_Pre'); 
save(fullfile(outputpath, 'ET_P300_Post.mat'), 'ET_P300_Post'); 
save(fullfile(outputpath, 'TS_P300_Post.mat'), 'TS_P300_Post');
save(fullfile(outputpath, 'ET_P300_Diff.mat'), 'ET_P300_Diff'); 
save(fullfile(outputpath, 'TS_P300_Diff.mat'), 'TS_P300_Diff'); 

%ET
cfg = [];
ET_P300_Pre = ft_timelockgrandaverage(cfg, ET_P300_Pre{:});

cfg = [];
ET_P300_Post = ft_timelockgrandaverage(cfg, ET_P300_Post{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, ET_P300_Pre, ET_P300_Post);



%TS
cfg = [];
TS_P300_Pre = ft_timelockgrandaverage(cfg, TS_P300_Pre{:});

cfg = [];
TS_P300_Post = ft_timelockgrandaverage(cfg, TS_P300_Post{:});

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
%ft_multiplotER(cfg, TS_P300_Pre, TS_P300_Post);
cfg.linecolor = colours;
ft_multiplotER(cfg, TS_P300_Pre, TS_P300_Post, ET_P300_Pre, ET_P300_Post, TS_P300_Diff, ET_P300_Diff);
%ft_multiplotER(cfg, TS_P300_Pre, ET_P300_Pre);

%Diff
cfg = [];
TS_P300_Diff = ft_timelockgrandaverage(cfg, TS_P300_Diff{:});
%these are the wrong way round so have to be flipped
TS_P300_Diff.avg = TS_P300_Diff.avg*-1;

cfg = [];
ET_P300_Diff = ft_timelockgrandaverage(cfg, ET_P300_Diff{:});
%these are the wrong way round so have to be flipped
ET_P300_Diff.avg = ET_P300_Diff.avg*-1;

%plot
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
%cfg.linecolor = 'brgkyr';
ft_multiplotER(cfg, TS_P300_Diff, ET_P300_Diff);
%ft_multiplotER(cfg, TS_P300_Pre, TS_P300_Post, ET_P300_Pre, ET_P300_Post, TS_P300_diff, ET_P300_diff);



%% Devide by grade
G0_P300_Pre = all_P300_Pre([subjects.grade] == 0);
G1_P300_Pre = all_P300_Pre([subjects.grade] == 1);

G0_P300_Post = all_P300_Post([subjects.grade] == 0);
G1_P300_Post = all_P300_Post([subjects.grade] == 1);

G0_P300_Diff = all_P300_Diff([subjects.grade] == 0);
G1_P300_Diff = all_P300_Diff([subjects.grade] == 1);

%average
cfg = [];
G0_P300_Pre = ft_timelockgrandaverage(cfg, G0_P300_Pre{:});
cfg = [];
G1_P300_Pre = ft_timelockgrandaverage(cfg, G1_P300_Pre{:});


%plot baseline
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
%ft_multiplotER(cfg, TS_P300_Pre, TS_P300_Post);
cfg.linecolor = colours;
%ft_multiplotER(cfg, TS_P300_Pre, TS_P300_Post, ET_P300_Pre, ET_P300_Post, TS_P300_Diff, ET_P300_Diff);
ft_multiplotER(cfg, G0_P300_Pre, G1_P300_Pre);




