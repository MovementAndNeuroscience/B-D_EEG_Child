%% Calculate interpolated channels
allBadchannels = allBadchannels([subjects.name] ~= 1001 & [subjects.name] ~= 1017 & [subjects.name] ~= 1026 & [subjects.name] ~= 1023 & [subjects.name] ~= 1010);
for k = 1:length(subjects)
allBadchannels(k).group = subjects(k).group;
allBadchannels(k).int_count = length(allBadchannels(k).int_channels);
end

mean([allBadchannels([allBadchannels.group] == 1).int_count]) %TS
mean([allBadchannels([allBadchannels.group] == 2).int_count]) %ET


x <- c(0.652, 0.0195, 0.496, 0.0391, 0.0078, 0.0078)
x <- x/2
p.adjust(x, method = 'BH')