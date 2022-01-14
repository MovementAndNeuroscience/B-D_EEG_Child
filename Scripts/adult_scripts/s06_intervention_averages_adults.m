%% Intervention Averages
% September 2021
% The script will average the ERPs and TFRs from the intervention file to
% see what the activity looks like

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts\adult_scripts');
configuration

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Intervention\adults');


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
    outputpath = ('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Intervention\adults');
    cd(datapath);
    
    %Current file info
    fprintf('Working on %s\n', num2str(subjects(k).name))
    
    %Files 
    currentFolder = dir;
    
    %Data Intervention
    mydata_ET_clean_file = dir('*ET_clean*.mat');
    mydata_ET_clean = importdata(mydata_ET_clean_file.name);
    
    mydata_TS_clean_file = dir('*TS_clean*.mat');
    mydata_TS_clean = importdata(mydata_TS_clean_file.name);
    
   
 %%                                          ERP ET

    cfg = [];
    cfg.baseline = [-0.1 0];
    cfg.latency = [-0.1 1];
    ET_ERP = ft_timelockanalysis(cfg, mydata_ET_clean);
    
    %Correct the baseline
    cfg = [];
    cfg.baseline = [-0.1, 0];
    ET_ERP_baseline = ft_timelockbaseline(cfg, ET_ERP);
    
 %SAVE
  
  FileName = [num2str(subjects(k).name), '_ET_ERP.mat'];
  save(fullfile(datapath, FileName), 'ET_ERP_baseline');
  
 
  %save in a structure
  all_ET_ERP{k} = ET_ERP_baseline;
  all_ET_ERP_subjects(k) = subjects(k).name;
  
  %Save the structure file
  save(fullfile(outputpath, 'all_ERP_ET.mat'), 'all_ET_ERP');
  save(fullfile(outputpath, 'all_ET_ERP_subjects.mat'), 'all_ET_ERP_subjects');
  
  
   %%                                          ERP TS

    cfg = [];
    cfg.baseline = [-0.1 0];
    cfg.latency = [-0.1 1];
    TS_ERP = ft_timelockanalysis(cfg, mydata_TS_clean);
    
    %Correct the baseline
    cfg = [];
    cfg.baseline = [-0.1, 0];
    TS_ERP_baseline = ft_timelockbaseline(cfg, TS_ERP);
    
 %SAVE
  
  FileName = [num2str(subjects(k).name), '_TS_ERP.mat'];
  save(fullfile(datapath, FileName), 'TS_ERP_baseline');
  
 
  %save in a structure
  all_TS_ERP{k} = TS_ERP_baseline;
  all_TS_ERP_subjects(k) = subjects(k).name;
  
  %Save the structure file
  save(fullfile(outputpath, 'all_ERP_TS.mat'), 'all_TS_ERP');
  save(fullfile(outputpath, 'all_TS_ERP_subjects.mat'), 'all_TS_ERP_subjects');
  
 
 
 
end 


 %%                                                GRAND AVERAGES 
 
 %%                                         Grand averages 

%--------------Grand Average
cfg = [];
ERP_ET_av = ft_timelockgrandaverage(cfg, all_ET_ERP{:});


cfg = [];
ERP_TS_av = ft_timelockgrandaverage(cfg, all_TS_ERP{:});


%plot 
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, ERP_ET_av, ERP_TS_av);

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, all_TS_ERP{1}, all_ET_ERP{1});



 
 