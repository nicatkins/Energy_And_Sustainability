% Read building information from CSV file
Directory = readtable('Directory.csv');

% Extract relevant information
buildingFiles = Directory.FileName;
buildings = Directory.BuildingName;
pvSize = Directory.PVSize;
startDate = Directory.StartDate;
endDate = Directory.EndDate;

while true
    % Initialize table to store building information and export status
    buildingInfo = table('Size', [length(buildingFiles), 3], 'VariableTypes', {'double', 'string', 'logical'}, 'VariableNames', {'Number', 'Name', 'Export'});

    % Iterate through each building file
    for fileIdx = 1:length(buildingFiles)
        % Read PV data (assuming this doesn't change for each building)
        pv = readtimetable("pv_lower_campus_parking_structure_phaseII_15min.csv");
        pv = sortrows(pv);
        pv = unique(pv);
        newpv = timetable(pv.datetime, pv.kw_average, pv.building_complex_name);
        newpv = renamevars(newpv, ["Var1" "Var2"], ["kwaverage", "buildingname"]);
        dailymaxpv = groupfilter(newpv, "Time", "day", @(x) x == max(x), "kwaverage");

        % Read building load data
        buildingLoadFile = buildingFiles{fileIdx};
        load = readtimetable(buildingLoadFile);
        load = sortrows(load);
        load = unique(load);
        newload = timetable(load.datetime, load.kw_average, load.building_complex_name);
        newload = renamevars(newload, ["Var1" "Var2"], ["kwaverage", "buildingname"]);
        dailymaxload = groupfilter(newload, "Time", "day", @(x) x == max(x), "kwaverage");

        % Get building information
        buildingNumber = fileIdx;
        buildingName = buildings{mod(fileIdx - 1, numel(buildings)) + 1};
        pvSizeBuilding = pvSize(fileIdx);

        % Convert cell contents to strings
        startDateString = startDate(fileIdx);
        endDateString = endDate(fileIdx);

        % Create datetime objects
        startDateValue = datetime(startDateString, 'InputFormat', 'yyyy-MM-dd');
        endDateValue = datetime(endDateString, 'InputFormat', 'yyyy-MM-dd');

        % Create time range based on provided start and end dates
        userTimeRange = timerange(startDateValue, endDateValue);

        % Filter PV data and building load based on the time range
        pvdata = newpv(userTimeRange, :);
        load_filtered = load(userTimeRange, :);

        % Scale the 'kw_average' column based on user input
        loadscale = pvSizeBuilding; % Use provided PV size as scale
        pvdata.kwaveragescaled = normalize(pvdata.kwaverage, 'range', [0, loadscale]);

        % Combine load and scaled PV data
        combined = synchronize(load, pvdata);

        % Calculate excess PV power
        combined.deltakw = max(combined.kwaveragescaled - combined.kw_average, 0);

        % Calculate excess energy in kWh
        combined.excesskwh = combined.deltakw / 4; % Assuming a 15-min interval

        % Sum up the total excess energy
        total_excess_energy_kwh = sum(combined.excesskwh, 'omitnan');

        % Check if the building will export and store the status
        exportStatus = total_excess_energy_kwh > 0;

        % Store building information and export status
        buildingInfo(fileIdx, :) = table(buildingNumber, {buildingName}, exportStatus);

        % Display results for each building
        disp([newline, 'Total excess energy produced by Building ', num2str(buildingNumber), ' (', buildingName, '): ', num2str(total_excess_energy_kwh), ' kWh']);
    end

    % Get input from the user for the building of interest
    buildingInterest = input('Enter the name of the building you are interested in: ', 's');

    % Find building information for the user's building of interest
    interestIdx = find(strcmp(buildingInfo.Name, buildingInterest), 1);

    % Check export status for the user's building of interest and report back
    if ~isempty(interestIdx)
        if buildingInfo.Export(interestIdx)
            disp(['Building ', buildingInfo.Name{interestIdx}, ' (Number ', num2str(buildingInfo.Number(interestIdx)), ') will export energy.']);
        else
            disp(['Building ', buildingInfo.Name{interestIdx}, ' (Number ', num2str(buildingInfo.Number(interestIdx)), ') will not export energy.']);
        end
    else
        disp(['Building ', buildingInterest, ' not found.']);
    end

    % Ask the user if they want to check another building
    response = input('Do you want to check another building? (yes/no): ', 's');
    if ~strcmpi(response, 'yes')
        break; % Exit the loop if the user does not want to check another building
    end
end
