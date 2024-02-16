
clear;clc
%file:///Users/nicolasatkins/Desktop/ENERGY%20ANALYSIS/Sustainability%20Fall%202023/datafiles/
%Bring in all data files
directory = readtable("Directory.csv");
d = directory.filename;
post = readtimetable(d{1});
miller = readtimetable(d{2});
liliu = readtimetable(d{3});
dean = readtimetable(d{4});
gateway = readtimetable(d{5});
johnA = readtimetable(d{5});
johnB = readtimetable(d{6});
canc = readtimetable(d{7});
art = readtimetable(d{8});
cmore = readtimetable(d{9});
hig = readtimetable(d{10});
music = readtimetable(d{11});
parking = readtimetable(d{12});
%Sort rows for each building
buildingnames = ["post" "miller" "liliu" "dean" "gateway" "johnA" "johnB" "canc" "art" "cmore" "hig" "music" "parking"];
bd = {post miller liliu dean gateway johnA johnB canc art cmore hig music parking};
for i = 1:1:(length(bd))
    bd{i} = sortrows(bd{i});
end
%CONDENSE TABLES INTO 3 COLUMNS AND RENAME
for i = 1:1:(length(bd))
    bd{i} = timetable(bd{i}.datetime, bd{i}.kw_average, bd{i}.building_complex_name);
    if i ~= length(bd)
        bd{i} = renamevars(bd{i}, ["Var1" "Var2"], ["loadkw", "buildingname"]); %datetime column is now called "Time"
    else
        bd{i} = renamevars(bd{i}, ["Var1" "Var2"], ["pvkw", "parking"]); %datetime column is now called "Time"
    end
end
%SYNCHRONIZE PV DATA AND LOAD DATA
for i = 1:1:(length(bd)-1)
    bd{i} = synchronize(bd{i}, bd{end});
    bd{i} = timetable(bd{i}.Time, bd{i}.loadkw, bd{i}.pvkw); %datetime column is now called "Time"
    bd{i} = renamevars(bd{i}, ["Var1" "Var2"], ["loadkw", "pvkw"]);
    bd{i} = rmmissing(bd{i});
    pvrating = directory{i, "pvrating"};
    colmax = max(bd{i}.pvkw);
    bd{i}.pvkw = rescale(bd{i}.pvkw, 0, pvrating, "InputMin", 0);
end
%FILTER TABLES FOR IDEAL INTERVAL
for i = 1:(length(bd)-2) % -2 excludes "parking" and "music"
    s = datetime(directory{i, "start"});
    e = datetime(directory{i, "ending"});
    r = timerange(s,e);
    bd{i} = bd{i}(r,:);
end

% %BUILDING EXCESS OVERVIEW TABLE
% for i = 1:1:length(bd)-1
%     bd{i}.bpower = bd{i}.pvkw - bd{i}.loadkw;
%     bd{i}.bpower = (bd{i}.bpower + abs(bd{i}.bpower))/2;
%     benergy(i,1) = sum(bd{i}.bpower);
% end
% buildingnames = ["post" "miller" "liliu" "dean" "gateway" "johnA" "johnB" "canc" "art" "cmore" "hig" "music"];
% bldgexport = table(buildingnames', benergy, benergy/365);
% for i = 1:1:length(bd)-1
%     bldgexport.avgload(i) = mean(bd{i}.loadkw); %building load ballpark
% end
% bldgexport.exportstatus = (bldgexport.benergy > 0); %export or not
% bldgexport = renamevars(bldgexport, ...
%     ["Var1" "benergy" "Var3" "avgload" "exportstatus" ], ...
%     ["Building Name" "Total Energy" "Average Daily Energy" "Average Building Load" ...
%     "Export?"]);

%SYNCHRONIZE DAY_TYPE FILE
% day_type = sortrows(readtimetable("timestamp_15min_daytype.csv"));
% 
% for i = 1:1:(length(bd)-1)
%     bd{i} = synchronize(bd{i}, day_type);
%     bd{i} = rmmissing(bd{i});
%     bd{i}.day_type = string(bd{i}.day_type);
% end

post = bd{1};
miller = bd{2};
liliu = bd{3};
dean = bd{4};
gateway = bd{5};
johnA = bd{6};
johnB = bd{7};
canc = bd{8};
art = bd{9};
cmore = bd{10};
hig = bd{11};
music = bd{12};


%daytype = bd{4}.day_type;
%scatter(bd{4}, 'datetime', 'loadkw', 50, daytype, 'filled')

%bar(bldgexport.Var1, bldgexport.benergy);
%bldgsmallexport = bldgexport([2 6 8 11])
%_________________________________________________________________________
% TABLES: [post miller liliu dean gateway johnA johnB canc art cmore hig
% music]

buildingpeaks = input("Enter building for peak loads: ");
graphbldg = buildingpeaks;
peakload = groupfilter(graphbldg, "Time", "day", @(x) x == max(x), "loadkw");
%avgpeak = groupfilter(peakload, )
scatter(peakload.day_datetime, peakload.loadkw, 10, "red", "filled");



