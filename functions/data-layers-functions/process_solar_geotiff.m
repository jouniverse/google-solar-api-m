% Function to process and visualize GeoTIFF files from Google Solar API
function process_solar_geotiff(response, api_key, layer_type)
% layer_type can be 'dsm', 'mask', 'annualFlux', or 'hourlyShade'
try
    % Select URL based on layer type
    switch lower(layer_type)
        case 'dsm'
            if ~isfield(response, 'dsmUrl')
                error('DSM URL not found in response');
            end
            url = response.dsmUrl;
        case 'mask'
            if ~isfield(response, 'maskUrl')
                error('Mask URL not found in response');
            end
            url = response.maskUrl;
        case 'annualflux'
            if ~isfield(response, 'annualFluxUrl')
                error('Annual Flux URL not found in response');
            end
            url = response.annualFluxUrl;
        otherwise
            error('Invalid layer type. Must be dsm, mask, annualFlux, or hourlyShade');
    end
    
    % Add API key to URL
    geotiff_url = sprintf('%s&key=%s', url, api_key);
    
    % Download the GeoTIFF file
    filename = 'temp_geotiff.tif';
    websave(filename, geotiff_url);
    
    % Read the GeoTIFF file
    [A, ~] = readgeoraster(filename);
    
    % Create figure with multiple subplots for different visualizations
    figure('Name', ['Solar API GeoTIFF Visualization - ' upper(layer_type)]);
    
    % Plot 1: Basic visualization
    subplot(2,2,1)
    imagesc(A);
    colorbar;
    title('Raw Data Visualization');
    axis equal tight;
    
    % Plot 2: Surface plot
    subplot(2,2,2)
    surf(A, 'EdgeColor', 'none');
    colorbar;
    title('3D Surface Plot');
    
    % Plot 3: Contour plot
    subplot(2,2,3)
    contourf(A);
    colorbar;
    title('Contour Plot');
    axis equal tight;
    axis ij;
    
    % Plot 4: Histogram of values with mean line
    subplot(2,2,4)
    histogram(A(:));
    hold on;
    if strcmpi(layer_type, 'dsm') || strcmpi(layer_type, 'annualflux')
        mean_value = mean(A(:));
        xline(mean_value, 'r--');
    end
    title('Data Distribution');
    xlabel('Value');
    ylabel('Frequency');
    hold off;
    
    % Display basic statistics
    disp(['GeoTIFF Statistics for ' upper(layer_type) ':']);
    disp(['Min value: ' num2str(min(A(:)))]);
    disp(['Max value: ' num2str(max(A(:)))]);
    disp(['Mean value: ' num2str(mean(A(:)))]);
    
    % Clean up temporary file
    delete(filename);
    
catch ME
    error('Error processing GeoTIFF: %s', ME.message);
end
end