function animate_hourly_shade(response, api_key, month, day, apply_mask)
% Create animation of hourly shade for a specific date
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

% Month names for display
month_names = {'January', 'February', 'March', 'April', 'May', 'June', ...
    'July', 'August', 'September', 'October', 'November', 'December'};


% Create figure
fig = figure('Name', sprintf('Hourly Shade Animation'));


% Create animation
for hour = 1:24
    % Get data for current hour
    hourly_data = shade_data(:,:,hour);
    day_mask = bitget(hourly_data, day);
    
    % Create visualization data
    if apply_mask
        % Create visualization data
        vis_data = zeros(size(day_mask));
        
        % Check if it's nighttime (all valid pixels are shaded)
        is_night = all(day_mask(hourly_data ~= -9999) == 0);
        
        if is_night
            vis_data(hourly_data == -9999) = 0.5;  % Non-roof areas
            vis_data(hourly_data ~= -9999 & day_mask == 0) = 0;  % Shaded roof areas
            vis_data(hourly_data ~= -9999 & day_mask == 1) = 1;  % Sunny roof areas
            
            imagesc(vis_data);
            %  colormap(cga, [61/256 38/256 168/256; 0.7 0.7 0.7]);
            colormap(gca, [61/256 38/256 168/256; 0.7 0.7 0.7]);
            colorbar(gca, 'Ticks',[0.1 0.35], 'TickLabels',  {'Shade', 'Non-roof'});
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
        else
            vis_data(hourly_data == -9999) = 0.5;  % Invalid
            imagesc(vis_data);
            colormap(gca, [61/256 38/256 168/256; 249/256 251/256 20/256]);
            cbar = colorbar(gca);
            cbar.Ticks = [0.28 0.72];
            cbar.TickLabels = {'Shade', 'Sun'};
        end
    end
    
    title(sprintf('Shade Data'));
    axis equal tight;
    
    % Add time stamp
    text(10, size(day_mask,1)-10, sprintf('%02d:00', hour-1), ...
        'Color', 'red', 'FontSize', 14);
    
    % Pause to create animation effect
    pause(0.5);
    
    % Capture frame for video if needed
    frames(hour) = getframe(fig);
end

% disp(class(frames));

% Close figure
close(fig);

delete(shade_filename);

% Save as video with slower frame rate
% v = VideoWriter(sprintf('hourly_shade.mp4'),'MPEG-4');
v = VideoWriter(sprintf('%s_%d_hourly_shade%s.mp4', ...
    month_names{month}, day, ...
    ternary(apply_mask, '_masked', '')), 'MPEG-4');
v.FrameRate = 6;  % 6 frames per second

% You can also duplicate each frame to make it last longer
frame_duration = 3; % Number of times each frame is repeated


for i = 1:length(frames)
    for j = 1:frame_duration
        extended_frames((i-1)*frame_duration+j) = frames(i);
    end
end

% disp(class(extended_frames));

open(v);
writeVideo(v, extended_frames);
close(v);
end

% Helper function for ternary operator
function result = ternary(condition, if_true, if_false)
if condition
    result = if_true;
else
    result = if_false;
end
end