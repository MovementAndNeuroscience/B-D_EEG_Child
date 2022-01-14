fit <- lm(Train_acc ~ Age, data = df_inc)
summary(fit)

#----------------FIELD_TRIP CODE----------------------
# http://web.mit.edu/kolya/.f/root/net.mit.edu/athena.mit.edu/software/spm/spm_v12/distrib/spm12/external/fieldtrip/ft_regressconfound.m
#GLM MODEL
#   Y = X * B + err, where Y is data, X is the model, and B are beta's
# which means
#   Best = X\Y ('matrix division', which is similar to B = inv(X)*Y)
# or when presented differently
#   Yest = X * Best
#   Yest = X * X\Y
#   Yclean = Y - Yest (the true 'clean' data is the recorded data 'Y' -
#   the data containing confounds 'Yest')
#   Yclean = Y - X * X\Y (my own comment - data minus model times model devided by data)


#beta = regr\dat;       

#model = regr(:, cfg.reject) * beta(cfg.reject, :);                        % model = confounds * weights = X * X\Y
#Yc = dat - model;                                                         % Yclean = Y - X * X\Y


#-------------MY ATTEMPT --------------------------
regr = df_inc$Age #this is specified as the confound in the FieldTrip code
dat = df_inc$Train_acc #this is the data that should be corrected

# B = X\Y (beta estimate)
beta = regr / dat 

# Model = X*X\Y
model = regr * beta

# Y clean
Yclean = dat - model

