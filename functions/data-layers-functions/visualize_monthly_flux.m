function visualize_monthly_flux(response, api_key, selected_month, apply_mask)
% selected_month should be 1-12 (January-December)
if ~isfield(response, 'monthlyFluxUrl')
    error('Monthly Flux URL not found in response');
end

% Validate month input
if ~isnumeric(selected_month) || selected_month < 1 || selected_month > 12
    error('Selected month must be a number between 1 and 12');
end

% Month names for display
month_names = {'January', 'February', 'March', 'April', 'May', 'June', ...
    'July', 'August', 'September', 'October', 'November', 'December'};

% Download and read the GeoTIFF
flux_filename = 'temp_monthly_flux.tif';
flux_url = sprintf('%s&key=%s', response.monthlyFluxUrl, api_key);
websave(flux_filename, flux_url);
[flux_data, ~] = readgeoraster(flux_filename);

% Extract the selected month's data (band)
monthly_data = flux_data(:,:,selected_month);

% Apply roof mask if requested
if apply_mask
    monthly_data = apply_roof_mask(response, api_key, monthly_data, 'monthly_flux');
end

% Create visualization
figure('Name', sprintf('Monthly Solar Flux (kWh/kW/year) - %s', month_names{selected_month}));

% Plot 1: Basic visualization
subplot(2,2,1)
imagesc(monthly_data, 'AlphaData', ~isnan(monthly_data));
colorbar;
title(sprintf('Solar Flux - %s', month_names{selected_month}));
axis equal tight;
colormap(gca, 'jet');

% Plot 2: Surface plot
subplot(2,2,2)
surf(monthly_data, 'EdgeColor', 'none');
colorbar;
title('3D Surface Plot');

% Plot 3: Contour plot
subplot(2,2,3)
contourf(monthly_data);
colorbar;
title('Contour Plot');
axis equal tight;
axis ij;  % Match the orientation of other plots

% Plot 4: Histogram with mean line
subplot(2,2,4)
histogram(monthly_data(:));
hold on;  % Hold the current plot to add more elements
mean_value = mean(monthly_data(:));
xline(mean_value, 'r--');  % Add a vertical red dashed line at the mean value
title('Data Distribution');
xlabel('kWh/kW/year');
ylabel('Frequency');
hold off;  % Release the plot for other plots

% Display statistics
disp(['Monthly Flux Statistics for ' month_names{selected_month} ':']);
disp(['Min value: ' num2str(min(monthly_data(:))) ' kWh/kW/year']);
disp(['Max value: ' num2str(max(monthly_data(:))) ' kWh/kW/year']);
disp(['Mean value: ' num2str(mean(monthly_data(:))) ' kWh/kW/year']);

% Clean up
delete(flux_filename);
end