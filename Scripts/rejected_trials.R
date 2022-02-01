#December 2021, Marta Topor
#Calculate whether there are differences between participants in terms of removed trials and interpolated channels


library(tidyr)
setwd('I:/SCIENCE-NEXS-neurolab/PROJECTS/PLAYMORE/EEG_project1/Analyses/B-D_EEG_Repo/Results')

# Load the data for channels and trials and subjects
df_channels <- read.csv('allBadchannels.csv', col.names = c('subjects', 'int_n', 'chan_1', 'chan_2', 'chan_3', 'chan_4', 'chan_5', 'chan_6', 'chan_7'))
df_trials <- read.csv('allRemovedTrials.csv')

setwd('I:/SCIENCE-NEXS-neurolab/PROJECTS/PLAYMORE/EEG_project1/Analyses/B-D_EEG_Repo')
library("readxl")
df_subjects <- read_excel("subjects.xlsx")

# Mark intervention groups in the channel and trials datasets 
df_channels$cond <- df_subjects$int
df_trials$cond <- df_subjects$int

#Remove participants who were not included in analyses
df_channels <- df_channels %>% dplyr::filter(subjects != 'sub-07', subjects != 'sub-12', subjects != 'sub-17')
df_trials <- df_trials %>% dplyr::filter(subjects != 'sub-07', subjects != 'sub-12', subjects != 'sub-17')




# ----------------- CHANNELS PER GROUP --------------------------------
#Calculate how many channels were interpolated per person
chans_ET_mean <- mean(df_channels$int_n[df_channels$cond == 'ET'])
chans_TS_mean <- mean(df_channels$int_n[df_channels$cond == 'TS'])
chans_ET_median <- median(df_channels$int_n[df_channels$cond == 'ET'])
chans_TS_median <- median(df_channels$int_n[df_channels$cond == 'TS'])

chans_ET_sd <- sd(df_channels$int_n[df_channels$cond == 'ET'])
chans_TS_sd <- sd(df_channels$int_n[df_channels$cond == 'TS'])
chans_ET_IQR <- IQR(df_channels$int_n[df_channels$cond == 'ET'])
chans_TS_IQR <- IQR(df_channels$int_n[df_channels$cond == 'TS'])

wilcox.test(df_channels$int_n[df_channels$cond == 'ET'], df_channels$int_n[df_channels$cond == 'TS'], alternative = "two.sided")



#----------------- TRIALS PER GROUP -------------------------------
#Calculate how many trials were there in total per person and how many were removed 
#There should be 40 per person but this is a good sanity check
df_trials$total <- df_trials$int_preprocessing + df_trials$int_ica + df_trials$int_remaining
df_trials$all_removed <- df_trials$int_preprocessing + df_trials$int_ica 


trials_all_removed_ET_mean <- mean(df_trials$all_removed[df_trials$cond == 'ET'])
trials_all_removed_TS_mean <- mean(df_trials$all_removed[df_trials$cond == 'TS'])
trials_all_removed_ET_median <- median(df_trials$all_removed[df_trials$cond == 'ET'])
trials_all_removed_TS_median <- median(df_trials$all_removed[df_trials$cond == 'TS'])

trials_all_removed_ET_sd <- sd(df_trials$all_removed[df_trials$cond == 'ET'])
trials_all_removed_TS_sd <- sd(df_trials$all_removed[df_trials$cond == 'TS'])
trials_all_removed_ET_IQR <- IQR(df_trials$all_removed[df_trials$cond == 'ET'])
trials_all_removed_TS_IQR <- IQR(df_trials$all_removed[df_trials$cond == 'TS'])

wilcox.test(df_trials$all_removed[df_trials$cond == 'ET'], df_trials$all_removed[df_trials$cond == 'TS'], alternative = "two.sided")



