%% Stats Mean Amplitudes
% December 2021
% The script will calculate mean amplitudes for the identified ERPs in intervention 

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration

% Load the intervention data for each group
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Intervention');
ET_ERP_Int_noage = importdata('ET_ERP_Int.mat');
TS_ERP_Int_noage = importdata('TS_ERP_Int.mat');


%% Mean amplitude for the period of the identified P300a peak

%Extract mean amplitude for each participant from each group and add to a
%data structure for mean amplitudes

for k=1:length(ET_ERP_Int_noage)

cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.15 0.3];
cfg.avgoverchan = 'yes';
selected = ft_selectdata(cfg, ET_ERP_Int_noage{k}); 

                                                                                                                                        
peaks(k).mean_p3a = mean(selected.avg); 

end



for k=1:length(TS_ERP_Int_noage)

cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.15 0.3];
cfg.avgoverchan = 'yes';
selected = ft_selectdata(cfg, TS_ERP_Int_noage{k}); 


peaks(k+9).mean_p3a = mean(selected.avg); 

end

% Statistics - One sample Wilcoxon test
x = [peaks(1:9).mean_p3a];
y = [peaks(10:18).mean_p3a];

mean(x)
mean(y)

[p,h,stats] = signrank(x)
[p,h,stats] = signrank(y)


%% Mean amplitude for the period of the identified N200 peak

for k=1:length(ET_ERP_Int_noage)

cfg = [];
cfg.channel = 'Pz';
cfg.latency = [0.2 0.25];
cfg.avgoverchan = 'yes';
selected = ft_selectdata(cfg, ET_ERP_Int_noage{k}); 

                                                                                                                                                             
peaks(k).mean_n2 = mean(selected.avg); 

end



for k=1:length(TS_ERP_Int_noage)

cfg = [];
cfg.channel = 'Pz';
cfg.latency = [0.2 0.25];
cfg.avgoverchan = 'yes';
selected = ft_selectdata(cfg, TS_ERP_Int_noage{k}); 


peaks(k+9).mean_n2 = mean(selected.avg); 

end


% Statistics - One sample Wilcoxon test
x = [peaks(1:9).mean_n2];
y = [peaks(10:18).mean_n2];

mean(x)
mean(y)

[p,h,stats] = signrank(x)
[p,h,stats] = signrank(y)


%% Mean amplitude for the period of the identified P300b peak


for k=1:length(ET_ERP_Int_noage)

cfg = [];
cfg.channel = 'Pz';
cfg.latency = [0.3 0.4];
cfg.avgoverchan = 'yes';
selected = ft_selectdata(cfg, ET_ERP_Int_noage{k}); 
                                                                                                                                                            
peaks(k).mean_p3b = mean(selected.avg); 

end



for k=1:length(TS_ERP_Int_noage)

cfg = [];
cfg.channel = 'Pz';
cfg.latency = [0.3 0.4];
cfg.avgoverchan = 'yes';
selected = ft_selectdata(cfg, TS_ERP_Int_noage{k}); 

peaks(k+9).mean_p3b = mean(selected.avg); 

end



% Statistics - One sample Wilcoxon test
x = [peaks(1:9).mean_p3b];
y = [peaks(10:18).mean_p3b];

mean(x)
mean(y)

[p,h,stats] = signrank(x)
[p,h,stats] = signrank(y)


%% SAVE
%Save as a csv table
writetable(struct2table(peaks), 'peaks.csv')

%Save as a matlab file 
save(fullfile(outputpath, 'peaks.mat'), 'peaks');
