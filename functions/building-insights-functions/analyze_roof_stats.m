function stats = analyze_roof_stats(response)
% Analyze roof statistics from Building Insights response
%
% Returns struct with roof statistics and creates visualizations

stats = struct();

% Extract whole roof stats
stats.area = response.solarPotential.wholeRoofStats.areaMeters2;
stats.quantiles = response.solarPotential.wholeRoofStats.sunshineQuantiles;

% Extract segment stats
n_segments = length(response.solarPotential.roofSegmentStats);
stats.segments.pitch = zeros(1, n_segments);
stats.segments.azimuth = zeros(1, n_segments);
stats.segments.area = zeros(1, n_segments);
% Bounding boxes
% Center
stats.segments.latitude = zeros(1, n_segments);
stats.segments.longitude = zeros(1, n_segments);
% SW corner
stats.segments.sw.latitude = zeros(1, n_segments);
stats.segments.sw.longitude = zeros(1, n_segments);
% NE corner
stats.segments.ne.latitude = zeros(1, n_segments);
stats.segments.ne.longitude = zeros(1, n_segments);

for i = 1:n_segments
    segment = response.solarPotential.roofSegmentStats(i);
    stats.segments.pitch(i) = segment.pitchDegrees;
    stats.segments.azimuth(i) = segment.azimuthDegrees;
    stats.segments.area(i) = segment.stats.areaMeters2;
    % Bounding boxes
    stats.segments.latitude(i) = segment.center.latitude;
    stats.segments.longitude(i) = segment.center.longitude;
    stats.segments.sw.latitude(i) = segment.boundingBox.sw.latitude;
    stats.segments.sw.longitude(i) = segment.boundingBox.sw.longitude;
    stats.segments.ne.latitude(i) = segment.boundingBox.ne.latitude;
    stats.segments.ne.longitude(i) = segment.boundingBox.ne.longitude;
end

% Plot 1: Sunshine quantiles
figure('Name', 'Roof Sunshine Distribution');
bar(0:10, stats.quantiles);
title('Roof Sunshine Distribution');
xlabel('Quantile');
ylabel('Sunshine (kWh/kW/year)');
% grid on;
hold on; % Hold the current plot to add another line
average_sunshine = mean(stats.quantiles); % Calculate the average sunshine
plot([min(0:10), max(0:10)], [average_sunshine, average_sunshine], 'r--', 'LineWidth', 2); % Plot the average line
hold off; % Release the plot

% Plot 2: Segment pitch and azimuth
figure('Name', 'Roof Segment Orientation');
yyaxis left
plot(1:n_segments, stats.segments.pitch, '-', 'LineWidth', 2);
ylabel('Pitch (degrees)');
yyaxis right
plot(1:n_segments, stats.segments.azimuth, '-', 'LineWidth', 2);
ylabel('Azimuth (degrees)');
title('Roof Segment Orientation');
xlabel('Segment Number');
legend('Pitch', 'Azimuth');
% grid on;

% Plot 3: Segment areas
figure('Name', 'Roof Segment Areas [m^2]');
bar(stats.segments.area);
hold on; % Hold the current plot to add another line
average_area = mean(stats.segments.area); % Calculate the average area
plot([min(1:n_segments), max(1:n_segments)], [average_area, average_area], 'r--', 'LineWidth', 2); % Plot the average line
hold off; % Release the plot
title('Roof Segment Areas');
xlabel('Segment Number');
ylabel('Area (m²)');
% grid on;

% Plot 4: Roof segment bounding boxes
% Draw bounding boxes as rectangles
figure('Name', 'Roof Segment Bounding Boxes');
geoaxes;
geobasemap('satellite');

% Plot centers
geoplot(stats.segments.latitude, stats.segments.longitude, 'o', 'MarkerFaceColor', 'r', 'MarkerSize', 6);
hold on;

% Plot bounding boxes for each segment
for i = 1:n_segments
    % Create polygon coordinates (5 points to close the rectangle)
    lats = [stats.segments.sw.latitude(i), stats.segments.sw.latitude(i), ...
        stats.segments.ne.latitude(i), stats.segments.ne.latitude(i), ...
        stats.segments.sw.latitude(i)];
    lons = [stats.segments.sw.longitude(i), stats.segments.ne.longitude(i), ...
        stats.segments.ne.longitude(i), stats.segments.sw.longitude(i), ...
        stats.segments.sw.longitude(i)];
    
    % Plot the bounding box with semi-transparent red color [R G B Alpha]
    geoplot(lats, lons, 'Color', [1 0 0 0.5], 'LineWidth', 1.5);
    
    % Optional: Add segment number labels
    text(stats.segments.latitude(i), stats.segments.longitude(i), ...
        sprintf('%d', i), 'Color', 'white', 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
end
hold off;

title('Roof Segment Bounding Boxes');

end
