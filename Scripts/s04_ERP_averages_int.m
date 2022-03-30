%% Intervention Averages
% September 2021
% The script will average the ERPs for each person and collect these files
% in a data strcture for further analyses

% Call the configuration script 
cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Scripts');
configuration

outputpath = 'I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results\Intervention';


 
%% Set up a loop

for k=1:length(subjects)
    
    if subjects(k).included == 0
       continue
    end
    
    %Data & output paths
    datapath = subjects(k).folder_int;
    cd(datapath);
    
    %Progress Message
    fprintf('Working on %s\n', subjects(k).sub)
    
    %Files 
    currentFolder = dir;
    
    %Data Intervention
    mydata_int_clean_file = dir('*_clean*.mat');
    mydata_int_clean = importdata(mydata_int_clean_file.name);
    
   
 %%                                          ERP
 
   %Average 
   cfg = [];
   cfg.baseline = [-0.1 0];
   cfg.latency = [-0.1 1];
   Int_ERP = ft_timelockanalysis(cfg, mydata_int_clean);
    
   %Correct the baseline on the average
   cfg = [];
   cfg.baseline = [-0.1, 0];
   Int_ERP_baseline = ft_timelockbaseline(cfg, Int_ERP);
    
 %SAVE
  
  %Add the avergaed file to a structure and add to a list of participants who were included  
  all_ERP_int{k} = Int_ERP_baseline; %structure with all averages
  all_ERP_subjects(k) = convertCharsToStrings(subjects(k).sub); %structure with participants who were processed
  
  %Save the files
  save(fullfile(outputpath, 'all_ERP_int.mat'), 'all_ERP_int');
  save(fullfile(outputpath, 'all_ERP_subjects.mat'), 'all_ERP_subjects');
 
end 

%% SELECT PARTICIPANTS - remove those that have not passed the quality check
%adjust the subjects structure to remove already excluded subjects
subjects = subjects([subjects.included] ~= 0); 

%Remove participant sub-12 who did not pass the data quality check after
%the ICA from the ERP and the subjecy structures

all_ERP_int = all_ERP_int([subjects.name] ~= 1017); 


subjects = subjects([subjects.name] ~= 1017); 


 %%                                                GRAND AVERAGES 
 
 %%                                         Grand averages 

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
    trials(k,:,:) = all_ERP_int{k}.avg;
end

%Arrange the structure that will be compatibale with the function
all_averaged_ERPs.time = all_ERP_int{1}.time;
all_averaged_ERPs.label = all_ERP_int{1}.label;
all_averaged_ERPs.elec = all_ERP_int{1}.elec;
all_averaged_ERPs.dimord = 'rpt_chan_time';
all_averaged_ERPs.trial = trials;

%Remove the confound
cfg = [];
cfg.confound = age;
all_averaged_ERPs_con = ft_regressconfound(cfg, all_averaged_ERPs);

%Now these corrected values must be extracted and inserted back into the
%original data structure with all avergaed ERPs for each participant
all_ERP_int_noage = all_ERP_int; %Copy the old structure
trials_noage = all_averaged_ERPs_con.trial; %Copy all of the corrected averages

for k = 1:length(subjects)
    all_ERP_int_noage{k}.avg = squeeze(trials_noage(k,:,:)); %select the corrected average and insert back to the original data structure
end

save(fullfile(outputpath, 'all_ERP_int_noage.mat'), 'all_ERP_int_noage');

%% --------------Grand Average
%Pooled for all participants
cfg = [];
ERP_Int_all_av_noage = ft_timelockgrandaverage(cfg, all_ERP_int_noage{:});

%plot 
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
ft_multiplotER(cfg, ERP_Int_all_av_noage);

%Grand averages for groups
%Divide the overall data structure to two separate groups - motor
%intervention and control

ET_ERP_Int_noage = all_ERP_int_noage([subjects.group] == 2);
TS_ERP_Int_noage = all_ERP_int_noage([subjects.group] == 1);

%Save the group specific structure files
save(fullfile(outputpath, 'ET_ERP_Int.mat'), 'ET_ERP_Int_noage');
save(fullfile(outputpath, 'TS_ERP_Int.mat'), 'TS_ERP_Int_noage');

% Group Grand Averages
%ET
cfg = [];
ET_ERP_Int_noage = ft_timelockgrandaverage(cfg, ET_ERP_Int_noage{:});

%TS
cfg = [];
TS_ERP_Int_noage = ft_timelockgrandaverage(cfg, TS_ERP_Int_noage{:});



%% ----------------------------PLOTS-----------------------


%Plot both groups

cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.xlim = [-0.1 0.8]; 
cfg.linewidth = 1;
ft_multiplotER(cfg, ET_ERP_Int_noage, TS_ERP_Int_noage);

%Standardised topoplot P300a
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.xlim = [0.15 0.3]; %time
cfg.zlim = [-5 3]; %amplitude
ft_topoplotER (cfg, ET_ERP_Int_noage, TS_ERP_Int_noage);

%Standardised topoplot N200
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.xlim = [0.2 0.25]; %time
cfg.zlim = [-5 4]; %amplitude
ft_topoplotER (cfg, ET_ERP_Int_noage, TS_ERP_Int_noage);

%Standardised topoplot P300b
cfg = [];
cfg.layout = layout_file;
cfg.showlabels = 'yes';
cfg.xlim = [0.3 0.4]; %time
cfg.zlim = [-8 10]; %amplitude
ft_topoplotER (cfg, ET_ERP_Int_noage, TS_ERP_Int_noage);



%% ------------------PEAK LATENCTY----------------------------

cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.15 0.3];
p300a_ET = ft_selectdata(cfg, ET_ERP_Int_noage);

x = max(p300a_ET.avg);
p300a_ET_peak = p300a_ET.time([p300a_ET.avg] == x)

cfg = [];
cfg.channel = 'Fz';
cfg.latency = [0.15 0.3];
p300a_TS = ft_selectdata(cfg, TS_ERP_Int_noage);

x = max(p300a_TS.avg);
p300a_TS_peak = p300a_TS.time([p300a_TS.avg] == x)




cfg = [];
cfg.channel = 'Pz';
cfg.latency = [0.2 0.25];
n200_ET = ft_selectdata(cfg, ET_ERP_Int_noage);

x = min(n200_ET.avg);
n200_ET_peak = n200_ET.time([n200_ET.avg] == x)

cfg = [];
cfg.channel = 'Pz';
cfg.latency = [0.2 0.25];
n200_TS = ft_selectdata(cfg, TS_ERP_Int_noage);

x = min(n200_TS.avg);
n200_TS_peak = n200_TS.time([n200_TS.avg] == x)



cfg = [];
cfg.channel = 'Pz';
cfg.latency = [0.3 0.4];
p300b_ET = ft_selectdata(cfg, ET_ERP_Int_noage);

x = max(p300b_ET.avg);
p300b_ET_peak = p300b_ET.time([p300b_ET.avg] == x)

cfg = [];
cfg.channel = 'Pz';
cfg.latency = [0.3 0.4];
p300b_TS = ft_selectdata(cfg, TS_ERP_Int_noage);

x = max(p300b_TS.avg);
p300b_TS_peak = p300b_TS.time([p300b_TS.avg] == x)

