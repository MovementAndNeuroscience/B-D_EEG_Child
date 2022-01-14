%% Configuration Script for all analyses
%January 2022

%path to fieldtrip
restoredefaultpath;
addpath C:\Users\dqz718\Documents\fieldtrip-20210525
ft_defaults;

%subjects for analysis
projectdir = ('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\EEG_Data');
outputdir = ('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results');
cd(projectdir)

subjects = readtable ('adult_subjects.xlsx');
subjects = table2struct(subjects);

%layout file
layout_file = 'biosemi64.lay';
layout = importdata(layout_file);

%neighbours file
neighbours_file = 'neighbours.mat';
neighbours = importdata(neighbours_file);

%3D electrode structure 
elec_file = 'standard_1020.elc';
elec = ft_read_sens(elec_file);  

cd(outputdir);
%Structure with bad channels
adult_allBadchannels = importdata('adult_allBadchannels.mat');

%Structure with removed trials
adult_allRemovedTrials = importdata('adult_allRemovedTrials.mat');

%Structure with removed ICA components
adult_allRejectedComponents = importdata('adult_allRejectedComponents.mat');
   
 