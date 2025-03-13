PPP = 'C:\Users\6S3P5X3\Desktop\International Trade\Replication\productivity_dataset.xlsx';
T = readtable(PPP, 'PreserveVariableNames', true, 'ReadVariableNames', true);

allowed_countries = ["GBR", "ESP", "FRA", "LUX", "IRL", "HUN", "FIN", "BEL", "NLD", ...
                     "PRT", "KOR", "CZE", "DEU", "DNK", "AUS", "SWE", "ITA", "POL", ...
                     "GRC", "JPN", "USA", "SVK"];
allowed_sectors = ["min", "man", "agr"];
T = T(ismember(T.countrycode, allowed_countries) & ismember(T.sector, allowed_sectors), :);
disp(T(1:10, :));
writetable(T, 'productivity_filtered.xlsx');

T.PPP_y_inverse = 1 ./ T.PPP_y;
disp(T(1:10, :));
writetable(T, 'prdctivity_with_inverse.csv');

% Normalization
us_rows = strcmp(T.countrycode, 'USA'); 
if any(us_rows)
    ref_value_us = mean(T.PPP_y_inverse(us_rows)); 
    if ref_value_us ~= 0
        T.PPP_y_inverse(us_rows) = T.PPP_y_inverse(us_rows) / ref_value_us;
    end
end

unique_countries = unique(T.countrycode); 
for i = 1:length(unique_countries)
    country_rows = strcmp(T.countrycode, unique_countries{i}); 
    agr_row = country_rows & strcmp(T.sector, 'agr'); 
    
    if any(agr_row)
        ref_value_agr = T.PPP_y_inverse(agr_row);
        if ref_value_agr ~= 0
            T.PPP_y_inverse(country_rows) = T.PPP_y_inverse(country_rows) / ref_value_agr;
        end
    end
end

T.PPP_y_inverse = round(T.PPP_y_inverse, 2);
disp(T(1:10, :));
writetable(T, 'normalized_prdctivity.csv');

