function visualize_panel_locations(response)
% Visualize solar panel locations and roof segments for the max array configuration
%
% Parameters:
%   response: Building Insights response

% Input validation
if ~isfield(response, 'solarPotential') || ~isfield(response.solarPotential, 'solarPanels')
    error('Invalid response: missing solarPotential.solarPanels field');
end

% Get panel data
panels = response.solarPotential.solarPanels;
n_panels = length(panels);

if n_panels == 0
    error('No panel data found in the response');
end

% Extract panel locations and energy data
latitudes = zeros(1, n_panels);
longitudes = zeros(1, n_panels);
energies = zeros(1, n_panels);
segments = zeros(1, n_panels);
panel_number = zeros(1, n_panels);
orientation = strings(1, n_panels);
pitch = zeros(1,n_panels);
azimuth = zeros(1,n_panels);

for i = 1:n_panels
    latitudes(i) = panels(i).center.latitude;
    longitudes(i) = panels(i).center.longitude;
    energies(i) = panels(i).yearlyEnergyDcKwh;
    segments(i) = panels(i).segmentIndex + 1;
    panel_number(i) = i;
    orientation(i) = panels(i).orientation;
    pitch(i) = response.solarPotential.roofSegmentStats(segments(i)).pitchDegrees;
    azimuth(i) = response.solarPotential.roofSegmentStats(segments(i)).azimuthDegrees;
end


% Energy visualization
figure('Name', 'Solar Panel Locations', 'Position', [100, 100, 800, 600]);
geoaxes;
geobasemap('satellite');  % Use 'streets' instead of 'satellite' if you want to see the panels better
geoplot(latitudes, longitudes, 'o', 'MarkerFaceColor', 'r', 'MarkerSize', 6);
% Add colormap based on energies using scatter
hold on;
geoscatter(latitudes, longitudes, 50, energies, 'filled');
hold off;
c = colorbar;
c.Label.String = 'Energy (kWh/year)';
colormap('jet');
title('Solar Panel Locations and Energy Production');

% Add custom datatip
dcm = datacursormode(gcf);
set(dcm, 'UpdateFcn', @(obj,event_obj) customDataTip(obj, event_obj, panel_number, energies, segments, pitch, azimuth));

% Segment visualization
figure('Name', 'Roof segment locations', 'Position', [100, 100, 800, 600]);
geoaxes;
geobasemap('satellite');  % Use 'streets' instead of 'satellite' if you want to see the segments better
geoscatter(latitudes, longitudes, 50, segments, 'filled');

% Customize plot with discrete colorbar
c = colorbar;
unique_segments = unique(segments);
n_segments = length(unique_segments);
colormap(gca, jet(n_segments));

% Remove tick marks but keep labels
% c.Ticks = [];
% c.TickLabels = unique_segments;

% sparse tick labels
c.Ticks = unique_segments;
sparse_ticks = unique_segments(1:2:end);
c.Ticks = sparse_ticks;
c.TickLabels = string(sparse_ticks);

c.Label.String = 'Segment index';

% Adjust color limits to align with discrete segments
clim([min(segments)-0.5, max(segments)+0.5]);

title('Roof segment locations');

% Add custom datatip
dcm = datacursormode(gcf);
set(dcm, 'UpdateFcn', @(obj,event_obj) customDataTip(obj, event_obj, panel_number, energies, segments, pitch, azimuth));


timestamp = datetime('now','Format','yyyy-MM-dd_HH-mm-ss');
saveas(gcf, sprintf('solar_panel_locations_%s.png', timestamp));
end


% Modified custom datatip function
function txt = customDataTip(~, event_obj, panel_numbers, energies, segments, pitch, azimuth)
pos = event_obj.Position;  % Get position of click
idx = event_obj.DataIndex;  % Get index of clicked point

txt = {sprintf('Latitude: %.6f', pos(1)), ...
    sprintf('Longitude: %.6f', pos(2)), ...
    sprintf('Panel #: %d', panel_numbers(idx)), ...
    sprintf('Energy: %.2f kWh/year', energies(idx)), ...
    sprintf('Segment: %d', segments(idx)), ...
    sprintf('Pitch: %.1f°', pitch(idx)), ...
    sprintf('Azimuth: %.1f°', azimuth(idx))};
end
