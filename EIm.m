filename_EI = 'C:\Users\6S3P5X3\Desktop\International Trade\Replication\Btrade.csv';
EI = readtable(filename_EI, 'PreserveVariableNames', true, 'ReadVariableNames', true);

filename_OT = 'C:\Users\6S3P5X3\Desktop\International Trade\Replication\output_nname_del.xlsx';
OT = readtable(filename_OT, 'PreserveVariableNames', true, 'ReadVariableNames', true);

countries_to_remove = {'SWE', 'NLD', 'LUX', 'GBR', 'USA'};
rows_to_remove = ismember(EI.COU, countries_to_remove) | ismember(EI.PAR, countries_to_remove);
EI(rows_to_remove, :) = [];
disp(EI(1:10, :));
writetable(EI, 'btrade_EI_del.xlsx');

EI.Industry = strrep(EI.Industry, 'Agriculture, forestry and fishing [A]', 'agr');
EI.Industry = strrep(EI.Industry, 'Mining and quarrying [B]', 'min');
EI.Industry = strrep(EI.Industry,'Manufacturing [C]', 'man');
disp(EI(1:10, :));
writetable(EI,  'bt_EI_nname.xlsx');


EI_EXPO = EI(strcmp(EI.FLW, 'EXPO'), :);
groupedData_EXPO = varfun(@sum, EI_EXPO, 'InputVariables', 'OBS_VALUE', ...
    'GroupingVariables', {'COU', 'Industry'});
groupedData_EXPO.Properties.VariableNames{'sum_OBS_VALUE'} = 'EX_C_I';
EI_IMPO = EI(strcmp(EI.FLW, 'IMPO'), :);
groupedData_IMPO = varfun(@sum, EI_IMPO, 'InputVariables', 'OBS_VALUE', ...
    'GroupingVariables', {'COU', 'Industry'});
groupedData_IMPO.Properties.VariableNames{'sum_OBS_VALUE'} = 'IM_C_I';
mergedData = outerjoin(groupedData_EXPO, groupedData_IMPO, ...
    'Keys', {'COU', 'Industry'}, 'MergeKeys', true);
NEINI = mergedData(:, {'COU', 'Industry', 'EX_C_I', 'IM_C_I'});
disp(NEINI);


NEINI.NET_IMPORT = NEINI.IM_C_I - NEINI.EX_C_I;
disp(NEINI);
writetable(NEINI,  'NEINI.xlsx');



NEINI.O_C_I = NaN(height(NEINI), 1);


for i = 1:height(NEINI)
    
    matching_row = strcmpi(OT.REF_AREA, NEINI.COU{i}) & strcmpi(OT.("Economic activity"), NEINI.Industry{i});
    
    if sum(matching_row) == 1
        NEINI.O_C_I(i) = OT.OBS_VALUE(matching_row);
    elseif sum(matching_row) > 1
        NEINI.O_C_I(i) = OT.OBS_VALUE(find(matching_row, 1, 'first'));
    end
end


disp(NEINI(1:10, :)); 

NEINI.COMBINED_O_NI = NEINI.NET_IMPORT + NEINI.O_C_I;
disp(NEINI);


zero_rows = NEINI.COMBINED_O_NI == 0;

NEINI.IPR = NEINI.IM_C_I ./ NEINI.COMBINED_O_NI;
disp(NEINI);


countries = unique(NEINI.COU);

for i = 1:length(countries)
    country = countries{i};
    
    country_rows = strcmp(NEINI.COU, country);
    
    ipr_values = NEINI.IPR(country_rows);
    
    valid_ipr = ipr_values(ipr_values < 1); 
    
    if ~isempty(valid_ipr)  
        max_valid_ipr = max(valid_ipr);
        
        replace_rows = country_rows & (NEINI.IPR > 1);
        NEINI.IPR(replace_rows) = max_valid_ipr;
    end
end


disp(NEINI);

NEINI(NEINI.IPR > 1, :) = [];
disp(NEINI);
NEINI.IPR_subtracted = 1 - NEINI.IPR;
disp(NEINI(1:10, :));
writetable(NEINI, 'NEINI_WSBTRCTDIPR.xlsx');









