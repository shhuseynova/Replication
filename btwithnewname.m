filename_B = 'C:\Users\6S3P5X3\Desktop\International Trade\Replication\Btrade.csv';
filename_C = 'C:\Users\6S3P5X3\Desktop\International Trade\Replication\normalized_prdctivity.csv';
filename_N = 'C:\Users\6S3P5X3\Desktop\International Trade\Replication\NEINI_WSBTRCTDIPR.xlsx';

B = readtable(filename_B, 'PreserveVariableNames', true, 'ReadVariableNames', true);
C = readtable(filename_C);
N = readtable(filename_N);
B.Industry = strrep(B.Industry, 'Agriculture, forestry and fishing [A]', 'agr');
B.Industry = strrep(B.Industry, 'Mining and quarrying [B]', 'min');
B.Industry = strrep(B.Industry,'Manufacturing [C]', 'man');

disp(B(1:10, :));
writetable(B,  'btwnewn.xlsx');
B = B(strcmp(B.FLW, 'EXPO'), :);

disp(B(1:10, :));
writetable(B, 'btrade_export.xlsx');


B.productivity = NaN(height(B), 1); 


for i = 1:height(B)
    
    matching_row = strcmpi(C.countrycode, B.COU{i}) & strcmpi(C.sector, B.Industry{i});
    
    
    if sum(matching_row) == 1
        B.productivity(i) = C.PPP_y_inverse(matching_row);
    elseif sum(matching_row) > 1
        warning('Multiple matches found for COU: %s and Industry: %s. Only the first match will be used.', B.COU{i}, B.Industry{i});
       
        B.productivity(i) = C.PPP_y_inverse(find(matching_row, 1, 'first'));
    elseif sum(matching_row) == 0
        warning('No match found for COU: %s and Industry: %s. The productivity value remains NaN.', B.COU{i}, B.Industry{i});
    end
end




disp(B(1:10, :)); 
writetable(B, 'btrade_productivity.xlsx');

countries_to_remove = {'SWE', 'NLD', 'LUX', 'GBR', 'USA'};
rows_to_remove = ismember(B.COU, countries_to_remove) | ismember(B.PAR, countries_to_remove);
B(rows_to_remove, :) = [];
disp(B(1:10, :));
writetable(B, 'btrade_productivity_del.xlsx');


B = innerjoin(B, N, 'Keys', {'COU', 'Industry'}, 'RightVariables', 'IPR_subtracted');
B.sub_IPR = B.IPR_subtracted;
B.IPR_subtracted = [];
disp(B(1:10, :));

B.COR_EXP = B.OBS_VALUE ./ B.sub_IPR;
disp(B(1:10, :));
writetable(B, 'btrade_productivity_del_corex.xlsx');



negative_or_zero_values = (B.productivity <= 0) | (B.COR_EXP <= 0) | (B.OBS_VALUE <= 0);
B = B(~negative_or_zero_values, :);
disp(B(1:10, :)); 


% OLS1
B.log_OBS_VALUE = log(B.OBS_VALUE);
B.log_productivity = log(B.productivity);
B.exporter_importer_effect = categorical(strcat(B.COU, '_', B.PAR));
B.industry_importer_effect = categorical(strcat(B.Industry, '_', B.PAR));
lm = fitlm(B, 'log_OBS_VALUE ~ log_productivity + exporter_importer_effect + industry_importer_effect');
disp(lm);
% OLS2
B.log_COR_EXP = log(B.COR_EXP);
B.log_productivity = log(B.productivity);
B.exporter_importer_effect = categorical(strcat(B.COU, '_', B.PAR));
B.industry_importer_effect = categorical(strcat(B.Industry, '_', B.PAR));
cor_lm = fitlm(B, 'log_COR_EXP ~ log_productivity + exporter_importer_effect + industry_importer_effect');
disp(cor_lm);




