%% Configuration Script for all analyses
%August 2021

%path to fieldtrip
restoredefaultpath;
addpath C:\Users\dqz718\Documents\fieldtrip-20210525
ft_defaults;

%Path for analysis subjects
projectdir = ('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo');
outputdir = ('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\B-D_EEG_Repo\Results');
cd(projectdir)

%File with subkect information
subjects = readtable ('subjects.xlsx');
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

%Files with preprocessing notes - interpolated channels, rejected trials and rejected components 
cd(outputdir);
%Structure with bad channels
allBadchannels = importdata('allBadchannels.mat');

%% These files were overwritten and are lost
%Structure with removed trials
%allRemovedTrials = importdata('allRemovedTrials.mat');

%Structure with removed ICA components
%allRejectedComponents = importdata('allRejectedComponents.mat');
   
 