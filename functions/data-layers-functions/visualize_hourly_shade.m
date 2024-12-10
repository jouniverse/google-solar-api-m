function visualize_hourly_shade(response, api_key, month, day, hour, apply_mask)
% month should be 1-12 (January-December)
% day should be 1-31 (depending on month)
% hour should be 1-24
% apply_mask: (optional) boolean to apply roof mask (default: false)

if nargin < 6
    apply_mask = false;
end

if ~isfield(response, 'hourlyShadeUrls') || isempty(response.hourlyShadeUrls)
    error('Hourly Shade URLs not found in response');
end

% Validate inputs
if ~isnumeric(month) || month < 1 || month > 12
    error('Month must be a number between 1 and 12');
end

% Month names for display
month_names = {'January', 'February', 'March', 'April', 'May', 'June', ...
    'July', 'August', 'September', 'October', 'November', 'December'};

% Get number of days in the selected month
days_in_month = eomday(2024, month); % Using 2024 as it's a leap year
if ~isnumeric(day) || day < 1 || day > days_in_month
    error('Day must be a number between 1 and %d for %s', days_in_month, month_names{month});
end

if ~isnumeric(hour) || hour < 1 || hour > 24
    error('Hour must be a number between 1 and 24');
end

% Month names for display
month_names = {'January', 'February', 'March', 'April', 'May', 'June', ...
    'July', 'August', 'September', 'October', 'November', 'December'};

% Download and read the GeoTIFF for the selected month
shade_filename = 'temp_hourly_shade.tif';
shade_url = sprintf('%s&key=%s', response.hourlyShadeUrls{month}, api_key);
websave(shade_filename, shade_url);
[shade_data, R] = readgeoraster(shade_filename);

% Extract the selected hour's data and get the specific day's bit
if apply_mask
    % Apply mask to all hourly data
    shade_data = apply_roof_mask(response, api_key, shade_data, 'hourly_shade');
end

hourly_data = shade_data(:,:,hour);
day_mask = bitget(hourly_data, day); % Get the bit for the selected day
day_mask(hourly_data == -9999) = -9999; % Preserve invalid locations

% Create visualization
figure('Name', sprintf('Hourly Shade - %s %d, Hour %d%s', ...
    month_names{month}, day, hour, ...
    ternary(apply_mask, ' (Roof Area)', '')));


subplot(2,2,1)
if apply_mask
    % Create visualization data
    vis_data = zeros(size(day_mask));
    
    % Check if it's nighttime (all valid pixels are shaded)
    is_night = all(day_mask(hourly_data ~= -9999) == 0);
    
    if is_night
        % During night, everything is shaded except non-roof areas
        vis_data(hourly_data == -9999) = 0.5;  % Non-roof areas
        vis_data(hourly_data ~= -9999) = 0;    % All roof areas are shaded
        imagesc(vis_data);
        %  colormap(cga, [61/256 38/256 168/256; 0.7 0.7 0.7]);
        colormap(gca, [61/256 38/256 168/256; 0.7 0.7 0.7]);
        colorbar(gca, 'Ticks',[0.1 0.35], 'TickLabels',  {'Shade', 'Non-roof'});
        % cbar = colorbar;
        % cbar.Ticks = [0.28 0.72];
        % cbar.TickLabels = {'Shade', 'Non-roof'};
    else
        % Normal daytime visualization
        vis_data(hourly_data == -9999) = 0.5;  % Non-roof areas
        vis_data(hourly_data ~= -9999 & day_mask == 0) = 0;  % Shaded roof areas
        vis_data(hourly_data ~= -9999 & day_mask == 1) = 1;  % Sunny roof areas
        imagesc(vis_data);
        colormap(gca, [61/256 38/256 168/256; 0.7 0.7 0.7; 249/256 251/256 20/256]);
        cbar = colorbar;
        cbar.Ticks = [0.17 0.5 0.83];
        cbar.TickLabels = {'Shade', 'Non-roof', 'Sun'};
    end
else
    % For non-masked data, handle nighttime similarly
    vis_data = day_mask;
    is_night = all(day_mask(hourly_data ~= -9999) == 0);
    
    if is_night
        vis_data(hourly_data ~= -9999) = 0;  % All
        % valid areas are shaded
        % vis_data(hourly_data == -9999) = 0.5;  % Invalid
        imagesc(vis_data);
        colormap(gca, [61/256 38/256 168/256]);
        colorbar(gca, 'Ticks', 0.0, 'TickLabels', {'Shade'});
        % cbar = colorbar;
        % cbar.Ticks = 0.5;
        % cbar.TickLabels = {'Shade'};
    else
        vis_data(hourly_data == -9999) = 0.5;  % Invalid
        imagesc(vis_data);
        colormap(gca, [61/256 38/256 168/256; 249/256 251/256 20/256]);
        cbar = colorbar(gca);
        cbar.Ticks = [0.28 0.72];
        cbar.TickLabels = {'Shade', 'Sun'};
    end
    
    
end
title(sprintf('Shade Data - %s %d, Hour %d', month_names{month}, day, hour));
axis equal tight;

% Plot 2: Binary visualization (sun visibility)
subplot(2,2,2)
if apply_mask
    % Create binary visualization data
    binary_data = zeros(size(day_mask));
    
    % Check if it's nighttime
    is_night = all(day_mask(hourly_data ~= -9999) == 0);
    
    if is_night
        binary_data(hourly_data == -9999) = 0.5;  % Non-roof areas
        binary_data(hourly_data ~= -9999) = 0;    % All roof areas are shaded
        imagesc(binary_data);
        colormap(gca, [1 0 0; 0.7 0.7 0.7]);
        colorbar(gca, 'Ticks', [0.1 0.35], 'TickLabels', {'Shade', 'Invalid'});
        title('Sun Visibility Map');
        axis equal tight;
    else
        binary_data(hourly_data == -9999) = 0.5;  % Non-roof areas
        binary_data(hourly_data ~= -9999 & day_mask == 0) = 0;  % Shaded roof areas
        binary_data(hourly_data ~= -9999 & day_mask == 1) = 1;  % Sunny roof areas
        imagesc(binary_data);
        colormap(gca, [1 0 0; 0.7 0.7 0.7; 0 1 0]);
        colorbar(gca, 'Ticks', [0.17, 0.5, 0.83], 'TickLabels', {'Shade', 'Invalid', 'Sun'});
        title('Sun Visibility Map');
        axis equal tight;
    end
else
    % For non-masked data, handle nighttime similarly
    binary_data = day_mask == 1;
    is_night = all(day_mask(hourly_data ~= -9999) == 0);
    
    if is_night
        binary_data(hourly_data ~= -9999) = 0;  % All valid areas are shaded
        binary_data(hourly_data == -9999) = 0.5;
        imagesc(binary_data);
        colormap(gca, [1 0 0]);
        colorbar(gca, 'Ticks', 0.5, 'TickLabels', {'Shade'});
        title('Sun Visibility Map');
        axis equal tight;
    else
        binary_data(hourly_data == -9999) = 0.5;
        imagesc(binary_data);
        colormap(gca, [1 0 0; 0.7 0.7 0.7; 0 1 0]);
        colorbar('Ticks', [0.17, 0.5, 0.83], 'TickLabels', {'Shade', 'Invalid', 'Sun'});
        title('Sun Visibility Map');
        axis equal tight;
    end
    
end


% Plot 3: Invalid locations
subplot(2,2,3)
invalid_data = hourly_data == -9999;
imagesc(invalid_data);
colormap(gca, [0 1 0; 1 0 0]); % Green for valid, red for invalid
colorbar('Ticks', [0.25, 0.75], 'TickLabels', {'Valid', 'Invalid'});
title('Data Validity Map');
axis equal tight;

% Plot 4: Statistics - Pie chart
subplot(2,2,4)
valid_data = day_mask(hourly_data ~= -9999);
h = pie([sum(valid_data == 1), sum(valid_data == 0)]);

% Get the colormap from the first subplot
ax1 = subplot(2,2,1);
cmap = colormap(ax1);

% Switch back to the pie chart subplot
ax4 = subplot(2,2,4);

is_night = all(day_mask(hourly_data ~= -9999) == 0);

% Apply legend and title to the correct subplot
if is_night
    % Use colors from the colormap for the pie chart
    h(3).FaceColor = cmap(1,:);   % Use last color from colormap for shade
    legend(ax4, {'Shade'});
else
    % Use colors from the colormap for the pie chart
    h(1).FaceColor = cmap(end,:);   % Use last color from colormap for sun
    h(3).FaceColor = cmap(1,:);     % Use first color from colormap for shade
    legend(ax4, {'Sun visible', 'Shade'});
end
title(ax4, 'Sun/Shade Distribution');

% Display mask information in text box if applied
if apply_mask
    text_info = sprintf('Date: %s %d\nHour: %02d:00\nRoof Area Only', ...
        month_names{month}, day, hour-1);
else
    text_info = sprintf('Date: %s %d\nHour: %02d:00', ...
        month_names{month}, day, hour-1);
end
annotation('textbox', [0.02, 0.02, 0.2, 0.05], 'String', text_info, 'EdgeColor', 'none');

% Clean up
delete(shade_filename);
end

% Helper function for ternary operator
function result = ternary(condition, if_true, if_false)
if condition
    result = if_true;
else
    result = if_false;
end
end