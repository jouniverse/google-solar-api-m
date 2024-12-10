high = readgeotable("SolarAPIHighArea.shp");
medium = readgeotable("SolarAPIMediumArea.shp");
HIGH = geotable2table(high,["Lat","Lon"]); 
MEDIUM = geotable2table(medium, ["Lat","Lon"]);
% disp(class(HIGH))
% disp(HIGH)
% disp(class(HIGH.Lat))
% disp(HIGH.Lon)
% Create a scatter plot
% Convert cell arrays to numeric arrays
HIGH.Lon = cell2mat(HIGH.Lon);
HIGH.Lat = cell2mat(HIGH.Lat);
MEDIUM.Lon = cell2mat(MEDIUM.Lon);
MEDIUM.Lat = cell2mat(MEDIUM.Lat);

% Now plot
% figure;
% hold on;
% scatter(HIGH.Lon, HIGH.Lat, 'r.', 'DisplayName', 'High Area');
% scatter(MEDIUM.Lon, MEDIUM.Lat, 'b.', 'DisplayName', 'Medium Area');
% 
% % Customize the plot
% title('Solar API Areas');
% xlabel('Longitude');
% ylabel('Latitude');
% legend;
% grid off;
% hold off;
% saveas(gcf, 'solar_areas_plot.png')

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