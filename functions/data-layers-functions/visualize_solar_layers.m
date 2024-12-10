function visualize_solar_layers(response, api_key)
% Parse the response JSON if it's a string
if ischar(response)
    response = jsondecode(response);
end

% Create a figure window
figure('Name', 'Solar API Layers');

% Process RGB layer (normal image)
if isfield(response, 'rgbUrl')
    subplot(2,2,1);
    rgb_url = sprintf('%s&key=%s', response.rgbUrl, api_key);
    rgb_data = webread(rgb_url);
    imshow(rgb_data);
    title('RGB Aerial Image');
end

% Process DSM layer
if isfield(response, 'dsmUrl')
    subplot(2,2,2);
    dsm_filename = 'temp_dsm.tif';
    dsm_url = sprintf('%s&key=%s', response.dsmUrl, api_key);
    websave(dsm_filename, dsm_url);
    [dsm_data, ~] = readgeoraster(dsm_filename);
    imagesc(dsm_data);
    colorbar;
    title('Digital Surface Model (m above sea level)');
    delete(dsm_filename);
end

% Process Mask layer
if isfield(response, 'maskUrl')
    subplot(2,2,3);
    mask_filename = 'temp_mask.tif';
    mask_url = sprintf('%s&key=%s', response.maskUrl, api_key);
    websave(mask_filename, mask_url);
    [mask_data, ~] = readgeoraster(mask_filename);
    imagesc(mask_data);
    colorbar;
    title('Roof Mask');
    delete(mask_filename);
end

% Process Annual Flux layer
if isfield(response, 'annualFluxUrl')
    subplot(2,2,4);
    flux_filename = 'temp_flux.tif';
    flux_url = sprintf('%s&key=%s', response.annualFluxUrl, api_key);
    websave(flux_filename, flux_url);
    [flux_data, ~] = readgeoraster(flux_filename);
    imagesc(flux_data);
    colorbar;
    title('Annual Solar Flux (kWh/kW/year)');
    delete(flux_filename);
end

end