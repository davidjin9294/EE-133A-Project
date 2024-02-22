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












