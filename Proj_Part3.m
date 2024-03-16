
% Extract features and target
X = standardized_feature_matrix;  % Features
y = label_matrix;   % Target

% Initialize KFold cross-validator
cv = cvpartition(size(X, 1), 'KFold', 10);

% Initialize cell arrays to store parameters and RMS errors for each fold
parameters = cell(cv.NumTestSets, 1);
rms_errors = zeros(cv.NumTestSets, 1);

% Loop through each fold
for fold = 1:cv.NumTestSets
    % Split the data into training and testing sets
    trainIdx = cv.training(fold);
    testIdx = cv.test(fold);
    X_train = X(trainIdx, :);
    y_train = y(trainIdx);
    X_test = X(testIdx, :);
    y_test = y(testIdx);
    
    % Fit the least squares model
    mdl = lsqr(X_train, y_train);

    % Store parameters of the model
    parameters{fold} = mdl;
    
    % Predict on the test set
    y_pred = X_test*mdl;
    for i = 1:length(y_pred)
        element = y_pred(i);
        if (element<0.5)
            y_pred(i)=0;
        elseif(element>=0.5 && element<1.5)
            y_pred(i)=1;
        else
            y_pred(i)=2;
  
        end
    end
    
    % Calculate RMS error
    rms_errors(fold) = sqrt(mean((y_pred - y_test).^2));
end
%%

% Display parameters
for fold = 1:cv.NumTestSets
    fprintf('Fold %d - RMS Error: %.4f\n', fold, rms_errors(fold));
    fprintf('\nParameters for Fold %d:\n', fold);
    
    disp(parameters{fold});
end



%%

standardized_combined = horzcat(standardized_feature_matrix, label_matrix);


% Loop through each fold
for fold = 1:cv.NumTestSets
    % Split the data into training and testing sets
    trainIdx = cv.training(fold);
    testIdx = cv.test(fold);

    train = standardized_combined(trainIdx,:);

    test = standardized_combined(testIdx,:);
    
    train_female_idx = (train(:, 2) >0);
    train_male_idx = (train(:, 2) <0);
    test_female_idx = (test(:, 2) >0);
    test_male_idx = (test(:, 2) <0);

    train_female = train(train_female_idx,:);
    train_male = train(train_male_idx,:);
    test_female = test(test_female_idx,:);
    test_male = test(test_female_idx,:);

    X_train_female = train_female(:, 1:end-1);
    X_train_male = train_male(:,1:end-1);
    y_train_female = train_female(:,end);
    y_train_male = train_male(:,end);

   X_test_female = test_female(:,1:end-1);
   X_test_male = test_male(:,1:end-1);
   y_test_female = test_female(:,end);
   y_test_male = test_male(:,end);

    % Fit the least squares model
    mdl_female = lsqr(X_train_female, y_train_female);
    mdl_male = lsqr(X_train_male, y_train_male);

    % Store parameters of the model
    parameters_female{fold} = mdl_female;
    parameters_male{fold} = mdl_male;
    
    % Predict on the test set
    y_pred_female = X_test_female*mdl_female;
    y_pred_male = X_test_male*mdl_male;
    for i = 1:length(y_pred_female)
        element = y_pred_female(i);
        if (element<0.3)
            y_pred_female(i)=0;
        elseif(element>=0.3 && element<1.3)
            y_pred_female(i)=1;
        else
            y_pred_female(i)=2;
  
        end
    end

    for i = 1:length(y_pred_male)
        element = y_pred_male(i);
        if (element<0.3)
            y_pred_male(i)=0;
        elseif(element>=0.3 && element<1.3)
            y_pred_male(i)=1;
        else
            y_pred_male(i)=2;
  
        end
    end
    
    % Calculate RMS error
    error = vertcat(y_pred_female - y_test_female, y_pred_male- y_test_male);

    rms_errors_gender(fold) = sqrt(mean((error).^2));
    %C_matrix = confusionmat(y_pred_female, y_test_female)
    %C_matrix = confusionmat(y_pred_male, y_test_male)
end

%%
%{
% Display parameters
for fold = 1:cv.NumTestSets
    fprintf('Fold %d - RMS Error: %.4f\n', fold, rms_errors_gender(fold));
    fprintf('\nParameters of female for Fold %d:\n', fold);
    
    disp(parameters_female{fold});

    fprintf('\nParameters of male for Fold %d:\n', fold);
    
    disp(parameters_male{fold});
end
%}

%%

% Loop through each fold
for fold = 1:cv.NumTestSets
   % Split the data into training and testing sets
   trainIdx = cv.training(fold);
   testIdx = cv.test(fold);
   train = standardized_combined(trainIdx,:);
   test = standardized_combined(testIdx,:);
  
   train_young_idx = (train(:, 3) <-0.8);
   train_old_idx = (train(:, 3) >=-0.8);
   test_young_idx = (test(:, 3) <-0.8);
   test_old_idx = (test(:, 3) >=-0.8);
   train_young = train(train_young_idx,:);
   train_old = train(train_old_idx,:);
   test_young = test(test_young_idx,:);
   test_old = test(test_young_idx,:);
   X_train_young = train_young(:, 1:end-1);
   X_train_old = train_old(:,1:end-1);
   y_train_young = train_young(:,end);
   y_train_old = train_old(:,end);
  X_test_young = test_young(:,1:end-1);
  X_test_old = test_old(:,1:end-1);
  y_test_young = test_young(:,end);
  y_test_old = test_old(:,end);
   % Fit the least squares model
   mdl_young = lsqr(X_train_young, y_train_young);
   mdl_old = lsqr(X_train_old, y_train_old);
   % Store parameters of the model
   parameters_young{fold} = mdl_young;
   parameters_old{fold} = mdl_old;
  
   % Predict on the test set
   y_pred_young = X_test_young*mdl_young;
   y_pred_old = X_test_old*mdl_old;
   for i = 1:length(y_pred_young)
       element = y_pred_young(i);
       if (element<0.3)
           y_pred_young(i)=0;
       elseif(element>=0.3 && element<1.3)
           y_pred_young(i)=1;
       else
           y_pred_young(i)=2;
        end
   end
   for i = 1:length(y_pred_old)
       element = y_pred_old(i);
       if (element<0.3)
           y_pred_old(i)=0;
       elseif(element>=0.3 && element<1.3)
           y_pred_old(i)=1;
       else
           y_pred_old(i)=2;
        end
   end
  
   % Calculate RMS error
   error = vertcat(y_pred_young - y_test_young, y_pred_old- y_test_old);
   rms_errors_age(fold) = sqrt(mean((error).^2));
   C_matrix = confusionmat(y_pred_young, y_test_young)
   C_matrix = confusionmat(y_pred_old, y_test_old)
end

  
%%
for fold = 1:cv.NumTestSets
    fprintf('Fold %d - RMS Error: %.4f\n', fold, rms_errors_age(fold));
    fprintf('\nParameters of younger for Fold %d:\n', fold);
    
    disp(parameters_young{fold});

    fprintf('\nParameters of older for Fold %d:\n', fold);
    
    disp(parameters_old{fold});
end

