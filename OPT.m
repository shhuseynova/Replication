filename_O = 'C:\Users\6S3P5X3\Desktop\International Trade\Replication\Output.csv';
O = readtable(filename_O, 'PreserveVariableNames', true, 'ReadVariableNames', true);
O.("Economic activity") = string(O.("Economic activity"));
O.("Economic activity") = strrep(O.("Economic activity"), 'Agriculture, forestry and fishing', 'agr');
O.("Economic activity") = strrep(O.("Economic activity"), 'Mining and quarrying', 'min');
O.("Economic activity") = strrep(O.("Economic activity"), 'Manufacturing', 'man');
disp(O(1:10, :));
writetable(O, 'O_withnewname.xlsx');

countries_to_remove = {'SWE', 'NLD', 'LUX', 'GBR', 'USA'};
rows_to_remove = ismember(O.REF_AREA, countries_to_remove);
O(rows_to_remove, :) = [];
disp(O(1:10, :));
writetable(O, 'output_nname_del.xlsx');