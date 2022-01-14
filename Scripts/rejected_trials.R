#artifactual trials
#December 2021

library(tidyr)

df <- read.csv('removed_trials.csv')

df <- df %>% dplyr::filter(subjects != 1001, subjects != 1010, subjects != 1017, subjects != 1023, subjects != 1026)

df$pre_total <- df$pre_processing + df$pre_ica + df$pre_remaining
df$post_total <- df$post_processing + df$post_ica + df$post_remaining
df$int_total <- df$int_preprocessing + df$int_ica + df$int_remaining

df$all_total <- df$pre_total + df$post_total + df$int_total

df$all_rejected <- df$pre_processing + df$pre_ica + df$post_processing + df$post_ica + df$int_preprocessing + df$int_ica

df$prcnt_rejected <- (df$all_rejected/df$all_total)*100

mean(df$prcnt_rejected[df$group == 1])
mean(df$prcnt_rejected[df$group == 2])

t.test(df$prcnt_rejected ~ df$group)

mean(df$prcnt_rejected[df$grade == 1])
mean(df$prcnt_rejected[df$grade == 0])

t.test(df$prcnt_rejected ~ df$grade)
