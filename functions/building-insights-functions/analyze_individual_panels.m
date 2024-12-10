function analyze_individual_panels(response)

panels = response.solarPotential.solarPanels;
n_panels = length(panels);

if n_panels == 0
    error('No panel data found in the response');
end

% Extract panel locations and energy data
latitudesPanels = zeros(1, n_panels);
longitudesPanels = zeros(1, n_panels);
energiesPanels = zeros(1, n_panels);
segmentsPanels = zeros(1, n_panels);
panelNumberPanels = zeros(1, n_panels);
orientationPanels = strings(1, n_panels);
pitchPanels = zeros(1,n_panels);
azimuthPanels = zeros(1,n_panels);

% panelCapacityRatio = selectedPanelCapacity/defaultPanelCapacity;
panelCapacityRatio = 1;

for i = 1:n_panels
    latitudesPanels(i) = panels(i).center.latitude;
    longitudesPanels(i) = panels(i).center.longitude;
    % Assume linear scaling of energy production by panel
    % capacity
    energiesPanels(i) = panelCapacityRatio*panels(i).yearlyEnergyDcKwh;
    segmentsPanels(i) = panels(i).segmentIndex;
    % Get pitch and azimuth from roof segment data, 0-based indexing
    pitchPanels(i) = response.solarPotential.roofSegmentStats(segmentsPanels(i)+1).pitchDegrees;
    azimuthPanels(i) = response.solarPotential.roofSegmentStats(segmentsPanels(i)+1).azimuthDegrees;
    panelNumberPanels(i) = i;
    orientationPanels(i) = panels(i).orientation;
end

% Energy production per panel
figure('Name', 'Energy Production per Panel', 'Position', [100, 100, 1200, 800]);
scatter(panelNumberPanels, energiesPanels);
hold on;
mean_energy = mean(energiesPanels);
plot([min(panelNumberPanels), max(panelNumberPanels)], [mean_energy, mean_energy], 'r--', 'LineWidth', 2);
title('Energy Production per Panel');
xlabel('Panel Number');
ylabel('Energy (kWh DC/year)');
% grid on;

% Calculate max,min, range, mean, median, std
max_energy = max(energiesPanels);
min_energy = min(energiesPanels);
range_energy = range(energiesPanels);
mean_energy = mean(energiesPanels);
median_energy = median(energiesPanels);
std_energy = std(energiesPanels);

% add a text box with max, min, range, mean, median, std; add the box to the bottom left corner
annotation('textbox', [0.15, 0.07, 0.2, 0.2], 'String', sprintf('Max: %.2f kWh/year\nMin: %.2f kWh/year\nRange: %.2f kWh/year\nMean: %.2f kWh/year\nMedian: %.2f kWh/year\nStd: %.2f kWh/year', max_energy, min_energy, range_energy, mean_energy, median_energy, std_energy), 'EdgeColor', 'none');

% Histogram of panel energy production
figure('Name', 'Panel Energy Production', 'Position', [100, 100, 1200, 800]);
histogram(energiesPanels);
hold on;
mean_energy = mean(energiesPanels);
plot([mean_energy, mean_energy], [0, max(histcounts(energiesPanels))], 'r--', 'LineWidth', 2);
title('Panel Energy Production');
xlabel('Energy (kWh DC/year)');
ylabel('Number of Panels');
% grid on;

% Histogram of panel distribution by segment
figure('Name', 'Panel Distribution by Roof Segment', 'Position', [100, 100, 1200, 800]);
histogram(segmentsPanels, 'BinMethod', 'integers');
title('Panel Distribution by Roof Segment');
xlabel('Segment Index');
ylabel('Number of Panels');
max_segments = max(segmentsPanels);
if max_segments <= 10
    xticks(1:max_segments);
else
    step = ceil(max_segments / 10);
    xticks(1:step:max_segments);
end
% grid on;

% % Plot panel locations
% figure('Name', 'Panel Locations', 'Position', [100, 100, 1200, 800]);
% scatter(longitudesPanels, latitudesPanels, 50, energiesPanels, 'filled');
% title('Panel Locations');
% xlabel('Longitude');
% ylabel('Latitude');
% colorbar;
% % grid on;

% Histogram of panel pitch
figure('Name', 'Panel Pitch (Max Array)', 'Position', [100, 100, 1200, 800]);
histogram(pitchPanels);
title('Panel Pitch (Max Array)');
xlabel('Pitch (degrees)');
ylabel('Number of Panels');
% grid on;

% Histogram of panel azimuth
figure('Name', 'Panel Azimuth (Max Array)', 'Position', [100, 100, 1200, 800]);
histogram(azimuthPanels);
title('Panel Azimuth (Max Array)');
xlabel('Azimuth (degrees)');
ylabel('Number of Panels');
% grid on;



