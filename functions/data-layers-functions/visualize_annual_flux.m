function visualize_annual_flux(response, api_key, apply_mask, separate_plots)

if nargin < 4
    separate_plots = false;
end

try
    url = response.annualFluxUrl;
    % Add API key to URL
    geotiff_url = sprintf('%s&key=%s', url, api_key);
    
    % Download the GeoTIFF file
    filename = 'temp_geotiff.tif';
    websave(filename, geotiff_url);
    
    % Read the GeoTIFF file
    [A, ~] = readgeoraster(filename);
    
    % Apply roof mask if requested
    if apply_mask
        A = apply_roof_mask(response, api_key, A, 'annual_flux');
    end
    
    if separate_plots
        % Plot 1: Basic visualization
        figure('Name', 'Basic Visualization');
        imagesc(A, 'AlphaData', ~isnan(A));
        colorbar;
        title('Raw Data Visualization (kWh/kW/year)');
        axis equal tight;
        
        % Plot 2: Surface plot
        figure('Name', '3D Surface Plot');
        surf(A, 'EdgeColor', 'none');
        colorbar;
        title('3D Surface Plot (kWh/kW/year)');
        
        % Plot 3: Contour plot
        figure('Name', 'Contour Plot');
        contourf(A);
        colorbar;
        title('Contour Plot (kWh/kW/year)');
        axis equal tight;
        axis ij;
        
        % Plot 4: Histogram of values with mean line
        figure('Name', 'Histogram');
        histogram(A(:));
        hold on
        mean_value = mean(A(:));
        xline(mean_value, 'r--');
        title('Data Distribution (kWh/kW/year)');
        xlabel('Energy (kWh/kW/year)');
        ylabel('Frequency');
        hold off;
    else
        figure('Name', 'Annual Flux Visualization');
        
        % Plot 1: Basic visualization
        subplot(2,2,1)
        imagesc(A, 'AlphaData', ~isnan(A));
        colorbar;
        title('Raw Data Visualization (kWh/kW/year)');
        axis equal tight;
        
        % Plot 2: Surface plot
        subplot(2,2,2)
        surf(A, 'EdgeColor', 'none');
        colorbar;
        title('3D Surface Plot (kWh/kW/year)');
        
        % Plot 3: Contour plot
        subplot(2,2,3)
        contourf(A);
        colorbar;
        title('Contour Plot (kWh/kW/year)');
        axis equal tight;
        axis ij;
        
        % Plot 4: Histogram of values with mean line
        subplot(2,2,4)
        histogram(A(:));
        hold on
        mean_value = mean(A(:));
        xline(mean_value, 'r--');
        title('Data Distribution (kWh/kW/year)');
        xlabel('Energy (kWh/kW/year)');
        ylabel('Frequency');
        hold off;
    end
    
    % Display basic statistics
    disp('GeoTIFF Statistics for Annual Flux:');
    disp(['Min value: ' num2str(min(A(:))) ' (kWh/kW/year)']);
    disp(['Max value: ' num2str(max(A(:))) ' (kWh/kW/year)']);
    if isnan(mean(A(:)))
        disp(['Mean value: - (kWh/kW/year)']);
    else
        disp(['Mean value: ' num2str(mean(A(:))) ' (kWh/kW/year)']);
    end
    
    % Clean up temporary file
    delete(filename);
catch
    disp('Error visualizing annual flux');
end


end