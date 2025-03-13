filename_R = 'C:\Users\6S3P5X3\Desktop\International Trade\Replication\RD.csv';
filename_B = 'C:\Users\6S3P5X3\Desktop\International Trade\Replication\btrade_productivity_del_corex.xlsx';
R = readtable(filename_R, 'PreserveVariableNames', true, 'ReadVariableNames', true);
B = readtable(filename_B, 'PreserveVariableNames', true, 'ReadVariableNames', true);

R.("Economic activity") = string(R.("Economic activity"));
R.("Economic activity") = strrep(R.("Economic activity"), 'Agriculture, forestry and fishing', 'agr');
R.("Economic activity") = strrep(R.("Economic activity"), 'Mining and quarrying', 'min');
R.("Economic activity") = strrep(R.("Economic activity"), 'Manufacturing', 'man');
disp(R(1:10, :));
writetable(R, 'R_withnewname.xlsx');

R = R(~isnan(R.OBS_VALUE), :);

disp(R(1:10, :));
writetable(R, 'R_withnewname_del.xlsx');

countries_to_remove = {'SWE', 'NLD', 'LUX', 'GBR', 'USA'};
rows_to_remove = ismember(B.COU, countries_to_remove) | ismember(B.PAR, countries_to_remove);
B(rows_to_remove, :) = [];
disp(B(1:10, :)); 
writetable(B, 'btrade_productivity_del.xlsx');

B.RD_Exp = NaN(height(B), 1);

for i = 1:height(B)
    matching_row = strcmpi(R.REF_AREA, B.COU{i}) & strcmpi(R.("Economic activity"), B.Industry{i});
    if sum(matching_row) == 1
        B.RD_Exp(i) = R.OBS_VALUE(matching_row);
    elseif sum(matching_row) > 1
        B.RD_Exp(i) = R.OBS_VALUE(find(matching_row, 1, 'first'));
    end
end


disp(B(1:10, :)); 
writetable(B, 'btrade_productivity_del_RD.xlsx');


negative_or_zero_values = (B.productivity <= 0) | (B.RD_Exp <= 0) | (B.OBS_VALUE <= 0) | (B.COR_EXP <= 0);
B = B(~negative_or_zero_values, :);

disp(B(1:10, :)); 
writetable(B, 'B_outzero.xlsx');


%IV1
B.log_OBS_VALUE = log(B.OBS_VALUE);
B.log_productivity = log(B.productivity);
B.log_RD_Exp = log(B.RD_Exp);
first_stage_x1 = fitlm(B, 'log_productivity ~ log_RD_Exp');
B.x1_hat = first_stage_x1.Fitted;
B.exporter_importer_effect = categorical(strcat(B.COU, '_', B.PAR));
B.industry_importer_effect = categorical(strcat(B.Industry, '_', B.PAR));
second_stage = fitlm(B, 'log_OBS_VALUE ~ x1_hat + exporter_importer_effect + industry_importer_effect');
disp(second_stage);

%IV2
B.log_COR_EXP = log(B.COR_EXP);
B.log_productivity = log(B.productivity);
B.log_RD_Exp = log(B.RD_Exp);
first_stage_x1 = fitlm(B, 'log_productivity ~ log_RD_Exp');
B.x1_hat = first_stage_x1.Fitted;
B.exporter_importer_effect = categorical(strcat(B.COU, '_', B.PAR));
B.industry_importer_effect = categorical(strcat(B.Industry, '_', B.PAR));
cor_second_stage = fitlm(B, 'log_COR_EXP ~ x1_hat + exporter_importer_effect + industry_importer_effect');
disp(cor_second_stage);



