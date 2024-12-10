function sun_shade_distribution(response, api_key, month, day, apply_mask)
% Plot sun/shade distribution over 24 hours
%
% Parameters:
%   response: API response containing hourly shade URLs
%   api_key: Google API key
%   month: Month (1-12)
%   day: Day (1-31, depending on month)
%   apply_mask: (optional) boolean to apply roof mask (default: false)

if nargin < 5
    apply_mask = false;
end

% Download data
shade_filename = 'temp_hourly_shade.tif';
shade_url = sprintf('%s&key=%s', response.hourlyShadeUrls{month}, api_key);
websave(shade_filename, shade_url);
[shade_data, R] = readgeoraster(shade_filename);

% Apply roof mask if requested
if apply_mask
    shade_data = apply_roof_mask(response, api_key, shade_data, 'hourly_shade');
end

% Initialize arrays for storing results
hours = 0:23;
sun_visibility = zeros(1, 24);
shade_percent = zeros(1, 24);

% Calculate sun visibility for each hour
for hour = 1:24
    hourly_data = shade_data(:,:,hour);
    day_mask = bitget(hourly_data, day);
    valid_data = hourly_data ~= -9999;
    
    % Calculate percentages
    total_valid = sum(valid_data(:));
    sun_visibility(hour) = 100 * sum(day_mask(:) == 1 & valid_data(:)) / total_valid;
    shade_percent(hour) = 100 * sum(day_mask(:) == 0 & valid_data(:)) / total_valid;
end

% Month names for display
month_names = {'January', 'February', 'March', 'April', 'May', 'June', ...
    'July', 'August', 'September', 'October', 'November', 'December'};

% Create visualization
figure('Name', sprintf('Sun/Shade Distribution - %s %d', month_names{month}, day));

% Plot distribution
plot(hours, sun_visibility, '-', 'LineWidth', 2);
hold on;
plot(hours, shade_percent, '-', 'LineWidth', 2);

% Customize plot
xlabel('Hour of Day');
ylabel('Percentage (%)');
title(sprintf('Sun/Shade Distribution - %s %d', month_names{month}, day));
legend('Sun Visible', 'Shade');
% grid on;
xlim([-0.5 23.5]);
ylim([0 100]);

delete(shade_filename);
end