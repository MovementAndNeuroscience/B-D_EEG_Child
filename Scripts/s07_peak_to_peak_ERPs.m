%% Stats for pre-post ERPs
% December 2021
% The script will calculate peak-to-peak P300 ERPs, intervention and
% post-intervention peaks will be corrected by extracting amplitudes from
% pre-intervention

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration

% Load the pre- and post-intervention data
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Pre_post');
ET_P300_Pre = importdata('ET_P300_Pre.mat');
ET_P300_Post = importdata('ET_P300_Post.mat');
TS_P300_Pre = importdata('TS_P300_Pre.mat');
TS_P300_Post = importdata('TS_P300_Post.mat');
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Intervention');
ET_ERP_Int = importdata('ET_ERP_Int.mat');
TS_ERP_Int = importdata('TS_ERP_Int.mat');

%% Extract peak-to-peak amplitudes for each participant
%% PRE INTERVENTION PEAK
%select the P300 window at 100-400ms Fz channel only

for k=1:length(ET_P300_Pre)

cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.1 0.4];
selected = ft_selectdata(cfg, ET_P300_Pre{9}); 

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, selected);


max(selected.avg)
min(selected.avg)

peaks(k).group = 'ET';
peaks(k).pre_max = max(selected.avg); 
peaks(k).pre_min = min(selected.avg);
peaks(k).pre = max(selected.avg) - min(selected.avg);

end



for k=1:length(TS_P300_Pre)

cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.1 0.4];
selected = ft_selectdata(cfg, TS_P300_Pre{9}); 

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, selected);


max(selected.avg)
min(selected.avg)

peaks(k+9).group = 'TS';
peaks(k+9).pre_max = max(selected.avg); 
peaks(k+9).pre_min = min(selected.avg);
peaks(k+9).pre = max(selected.avg) - min(selected.avg);

end


cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.1 0.27];
selected = ft_selectdata(cfg, TS_P300_Pre{9}); 



%% INTERVENTION PEAK
%select the P300 window at 100-400ms Fz channel only

%here the window might need to be shortened for the minimum because there
%are two negative peaks in some participants

for k=1:length(ET_ERP_Int_noage)

cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.1 0.4];
selected = ft_selectdata(cfg, ET_ERP_Int_noage{k}); 

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, selected);


max(selected.avg)
min(selected.avg)
                                                                                                                                                             
peaks(k).int_max = max(selected.avg); 
peaks(k).int_min = min(selected.avg);
peaks(k).int = max(selected.avg) - min(selected.avg);

end



for k=1:length(TS_ERP_Int_noage)

cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.1 0.35];
selected = ft_selectdata(cfg, TS_ERP_Int_noage{k}); 

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, selected);


max(selected.avg)
min(selected.avg)

peaks(k+9).int_max = max(selected.avg); 
peaks(k+9).int_min = min(selected.avg);
peaks(k+9).int = max(selected.avg) - min(selected.avg);

end

%after checking the min values, re-calculate the peak to peak

for j = 1:length(peaks)
    peaks(j).int = peaks(j).int_max - peaks(j).int_min;
end 

%save the table
writetable(struct2table(peaks), 'peaks.csv')
%save the structure
save(fullfile(outputpath, 'peaks.mat'), 'peaks');

% run stats on the peak-to-peak
x = [peaks(1:9).int];
y = [peaks(10:18).int];

mean(x)
mean(y)

[h,p,ci,stats] = ttest2(x,y)


% run stats on the max peak only
x = [peaks(1:9).int_max];
y = [peaks(10:18).int_max];

mean(x)
mean(y)

[h,p,ci,stats] = ttest2(x,y)

%non significant



%% Mean amplitude for the period of time used in the permutation tests P300


for k=1:length(ET_ERP_Int_noage)

cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.15 0.3];
cfg.avgoverchan = 'yes';
selected = ft_selectdata(cfg, ET_ERP_Int_noage{k}); 

%cfg = [];
%cfg.layout = layout_file;
%cfg.showlabels = 'yes';
%ft_multiplotER(cfg, selected);


max(selected.avg)
min(selected.avg)
                                                                                                                                                             
peaks(k).mean = mean(selected.avg); 

end



for k=1:length(TS_ERP_Int_noage)

cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.15 0.3];
cfg.avgoverchan = 'yes';
selected = ft_selectdata(cfg, TS_ERP_Int_noage{k}); 

%cfg = [];
%cfg.layout = layout_file;
%cfg.showlabels = 'yes';
%ft_multiplotER(cfg, selected);


max(selected.avg)
min(selected.avg)

peaks(k+9).mean = mean(selected.avg); 

end


% run stats on the max peak only
x = [peaks(1:9).mean];
y = [peaks(10:18).mean];

mean(x)
mean(y)

[h,p,ci,stats] = ttest2(x,y)

[p,h,stats] = ranksum(x,y)

[h,p,ci,stats] = ttest(x)
 
[p,h,stats] = signrank(y)


%% Mean amplitude for the period of time used in the permutation tests N200


for k=1:length(ET_ERP_Int_noage)

cfg = [];
cfg.channel = 'Pz';
cfg.latency = [0.2 0.25];
cfg.avgoverchan = 'yes';
selected = ft_selectdata(cfg, ET_ERP_Int_noage{k}); 

%cfg = [];
%cfg.layout = layout_file;
%cfg.showlabels = 'yes';
%ft_multiplotER(cfg, selected);


max(selected.avg)
min(selected.avg)
                                                                                                                                                             
peaks(k).mean_N2 = mean(selected.avg); 

end



for k=1:length(TS_ERP_Int_noage)

cfg = [];
cfg.channel = 'Pz';
cfg.latency = [0.2 0.25];
cfg.avgoverchan = 'yes';
selected = ft_selectdata(cfg, TS_ERP_Int_noage{k}); 

%cfg = [];
%cfg.layout = layout_file;
%cfg.showlabels = 'yes';
%ft_multiplotER(cfg, selected);


max(selected.avg)
min(selected.avg)

peaks(k+9).mean_N2 = mean(selected.avg); 

end


% run stats on the max peak only
x = [peaks(1:9).mean_N2];
y = [peaks(10:18).mean_N2];

mean(x)
mean(y)

[h,p,ci,stats] = ttest2(x,y)

[p,h,stats] = ranksum(x,y)

[h,p,ci,stats] = ttest(y)
 
[p,h,stats] = signrank(y)