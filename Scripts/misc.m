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



%% Reduce the structures by participants who were excluded
    
badchans1 = allBadchannels(1:11) 
badchans1(12) =  allBadchannels(21)
badchans1(13:21) = allBadchannels(12:20)

allBadchannels = badchans1


%% BIDS

cd('I:\SCIENCE-NEXS-neurolab\PROJECTS\PLAYMORE\EEG_project1\Analyses\BIDS_data');

sub = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21'};
ses = {'before', 'int', 'after'};

    
for subindx=13:numel(sub)
    
    
    %Data files    
    FileNames = {[num2str(subjects(subindx).name), '_pre.bdf']; [num2str(subjects(subindx).name), '_int.bdf']; [num2str(subjects(subindx).name), '_post.bdf']} ;
    
    
  for sesindx=1:numel(ses)    

      cfg = [];
      cfg.method    = 'convert';
      cfg.datatype  = 'EEG';

      % specify the input file name
      cfg.dataset   = FileNames{sesindx};

      % specify the output directory
      cfg.bidsroot  = 'bids';
      cfg.sub       = sub{subindx};
      cfg.ses       = ses{sesindx};

      data2bids(cfg);

  end % for ses
end % for sub

% https://bids-standard.github.io/bids-validator/
%had to delete a source file for each participant as it was giving an error
% had to fix eeg into EEG in .tsv files and correct the last line with
% channel type n/a for trigger
% had to add extra information to the json files