function PrintTable()
number = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
building_name = {'Post', 'Miller', 'Liliu', 'Dean', 'Gateway', 'JohnA', 'JohnB', 'Canc', 'Art', 'Cmore', 'Hig', 'Music', 'Parking'};

T = table(number',building_name', 'VariableNames', {'Number', 'Building Name'});

disp('UH Manoa Buildings and its Corresponding Number:');
disp(T);