% Imported data and store into data_matrix
data_matrix = diabetescleaneddata;

% Delete row with missing values
rows_with_missing_values = any(strcmp(data_matrix, '?'), 2);
data_matrix = data_matrix(~rows_with_missing_values, :);


% Convert age range into a single value 
third_column = data_matrix(:,3);
patterns = {'\[0-10\)', '\[10-20\)','\[20-30\)','\[30-40\)','\[40-50\)','\[50-60\)','\[60-70\)','\[70-80\)','\[80-90\)','\[90-100\)'};
integer_values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};


% Loop through patterns and replace them with corresponding integer values
for i = 1:numel(patterns)
    pattern = patterns{i};
    value = integer_values{i};
    third_column = regexprep(third_column, pattern, num2str(value));
end

% Replace the third column in the original matrix
data_matrix(:, 3) = third_column;

% Modify other features
num_rows = size(data_matrix, 1);
for i = 1:num_rows

    % Modify race: Caucasian = 0, Asian = 1, AfricanAmerican = 2, Hispanic = 3, Other = 4
    race = data_matrix(i, 1);
    switch race
        case 'Caucasian'
            data_matrix(i, 1) = 0;
        case 'Asian'
            data_matrix(i, 1) = 1;
        case "AfricanAmerican"
            data_matrix(i, 1) = 2;
        case "Hispanic"
            data_matrix(i, 1) = 3;
        case "Other"
            data_matrix(i, 1) = 4;
    end

    % Modify gender: Male = 0, Female = 1, Unknown/Invalid = 2
    gender = data_matrix(i, 2);
    switch gender
        case 'Male'
            data_matrix(i, 2) = 0;
        case 'Female'
            data_matrix(i, 2) = 1;
        case 'Unknown/Invalid'
            data_matrix(i, 2) = 2;
    end

    % Modify max_glu_serum: None = 0, Norm = 1, >200 = 2, >300 = 3
    max_glu_serum = data_matrix(i, 15);
    switch max_glu_serum
        case 'None'
            data_matrix(i, 15) = 0;
        case 'Norm'
            data_matrix(i, 15) = 1;
        case '>200'
            data_matrix(i, 15) = 2;
        case '>300'
            data_matrix(i, 15) = 3;
    end

    % Modify A1Cresult: None = 0, Norm = 1, >7 = 2, >8 = 3
    A1Cresult = data_matrix(i, 16);
    switch A1Cresult
    %cases for None and Norm
        case 'None'
            data_matrix(i, 16) = 0;
        case 'Norm'
            data_matrix(i, 16) = 1;   
        case '>7'
            data_matrix(i, 16) = 2;
        case '>8'
            data_matrix(i, 16) = 3;
    end

    % Modify metformin/repaglinide/nateglinide/chlorpropamide/glimepiride.../metformin-pioglitazone:
    % No = 0, Steady = 1, Down = 2, Up = 3
    for index = 17:39
        drug = data_matrix(i, index);
        switch drug
            case 'No'
                data_matrix(i, index) = 0;
            case 'Steady'
                data_matrix(i, index) = 1;
            case 'Down'
                data_matrix(i, index) = 2;
            case 'Up'
                data_matrix(i, index) = 3;
        end
    end

    % TODO: Modify change: No = 0, Ch = 1
    change = data_matrix(i, 40);
    switch change
        case 'No'
            data_matrix(i, 40) = 0;
        case 'Ch'
            data_matrix(i, 40) = 1;
    end
   % diabetesMed: No = 0, Yes = 1
    diabetesMed = data_matrix(i, 41);
    switch diabetesMed
        case 'No'
            data_matrix(i, 41) = 0;
        case 'Yes'
            data_matrix(i ,41) = 1;
    end

    %readmitted: NO = 0, <30 = 1, >30 = 2
    readmitted = data_matrix(i, 42);
    switch readmitted
        case 'NO'
            data_matrix(i, 42) = 0;
        case '<30'
            data_matrix(i, 42) = 1;
        case '>30'
            data_matrix(i, 42) = 2;
    end
end

% Convert data_matrix into numerical values
data = str2double(data_matrix);
% Normalize data
% data: the value matrix 

% Separate into feature and label matrices
feature_matrix = data(:, 1:end-1);
label_matrix = data(:, end);

% Calculate mean and standard deviation for each column
means = mean(feature_matrix);
std_devs = std(feature_matrix);

% Remove columns where mean and standard deviation are both 0
remove_columns = find(std_devs == 0);
feature_matrix(:, remove_columns) = [];
means(:, remove_columns) = [];
std_devs(:, remove_columns) = [];

%% Standardize each column
standardized_feature_matrix = (feature_matrix - means) ./ std_devs;
corCoef = corrcoef(standardized_feature_matrix);

%% Run k-means. Calculate the error
num_of_centers = [2, 3, 4, 5, 6, 7, 8, 9, 10];
silhouette_scores = zeros(1, length(num_of_centers));
error_array = zeros(1, length(num_of_centers));
for index = 1:length(num_of_centers)
    distance = zeros(1, num_of_centers(index));
    % Run kmeans on training_sets
    [idk, C, sumd] = kmeans(standardized_feature_matrix, num_of_centers(index));
    
    % Calculate error
    error_array(index) = mean(sumd);
    % Calculate Silhouette score
    silhouette_scores(index) = mean(silhouette(standardized_feature_matrix, idk));
    
    
    disp(["Completed run with ", num_of_centers(index), " centers"]);
end
%% Plot the error and silhouette scores
plot(num_of_centers, silhouette_scores, 'b');
%plot(num_of_centers, error_array, 'r')

%% Run SVD
[U, S, V] = svd(standardized_feature_matrix, "econ");
svd_features = standardized_feature_matrix*V;


%% Find highly correlated features
threshold = 0.5; % You can adjust this threshold as needed
[n, m] = size(corCoef);
highly_correlated_features= [];
for i = 1:n
    for j = i+1:m
        if abs(corCoef(i,j)) > threshold
            highly_correlated_features = [highly_correlated_features; [i, j, corCoef(i,j)]];
        end
    end
end
% Display highly correlated features
if isempty(highly_correlated_features)
    disp('No highly correlated features found.');
else
    disp('Highly correlated features (i, j, correlation coefficient):');
    disp(highly_correlated_features);
end





