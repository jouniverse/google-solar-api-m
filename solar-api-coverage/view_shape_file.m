high = readgeotable("SolarAPIHighArea.shp");
medium = readgeotable("SolarAPIMediumArea.shp");
HIGH = geotable2table(high,["Lat","Lon"]);
MEDIUM = geotable2table(medium, ["Lat","Lon"]);

% Create a scatter plot
% Convert cell arrays to numeric arrays
HIGH.Lon = cell2mat(HIGH.Lon);
HIGH.Lat = cell2mat(HIGH.Lat);
MEDIUM.Lon = cell2mat(MEDIUM.Lon);
MEDIUM.Lat = cell2mat(MEDIUM.Lat);

% Create figure with correct aspect ratio
figure('Position', [100, 100, 1200, 800]);

% Plot world map
worldmap([-60 80], [-200 200]);
hold on;

% Scatter plot of points
scatterm(HIGH.Lat, HIGH.Lon, 10, 'r.', 'DisplayName', 'High Area');
scatterm(MEDIUM.Lat, MEDIUM.Lon, 10, 'b.', 'DisplayName', 'Medium Area');

% Customize plot
title('Solar API Coverage');
% legend;
legend('High Area', 'Medium Area');
gridm;
hold off;