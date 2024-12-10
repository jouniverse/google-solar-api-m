function masked_data = apply_roof_mask(response, api_key, data, data_type)
% Apply roof mask to other data layers
%
% Parameters:
%   response: API response containing URLs
%   api_key: Google API key
%   data: Original data to mask
%   data_type: Type of data ('monthly_flux' or 'hourly_shade')

% Download roof mask
mask_filename = 'temp_mask.tif';
mask_url = sprintf('%s&key=%s', response.maskUrl, api_key);
websave(mask_filename, mask_url);
[mask_data, R] = readgeoraster(mask_filename);

% Create binary mask (1 for roof, 0 for non-roof)
binary_mask = mask_data > 0;

% Get target dimensions from the first layer of input data
target_size = size(data(:,:,1));

% Resize mask to match data dimensions using imresize
binary_mask = imresize(binary_mask, target_size, 'nearest');

% Initialize masked data with same size as input
masked_data = data;

% Apply mask based on data type
switch data_type
    case 'annual_flux'
        % For annual flux (1 band)
        masked_data = data;  % Initialize with original data
        masked_data(~binary_mask) = NaN;  % Set non-roof areas to NaN
        
    case 'monthly_flux'
        % For monthly flux (12 bands)
        masked_data = data;  % Initialize with original data
        for i = 1:size(data, 3)
            current_layer = data(:,:,i);
            % Set non-roof areas to NaN to ensure they're properly excluded
            current_layer(~binary_mask) = NaN;
            masked_data(:,:,i) = current_layer;
        end
        
    case 'hourly_shade'
        % For hourly shade (24 bands)
        for i = 1:size(data, 3)
            current_layer = data(:,:,i);
            % Only mask valid data points
            mask_indices = ~binary_mask & current_layer ~= -9999;
            current_layer(mask_indices) = -9999;  % Use invalid marker
            masked_data(:,:,i) = current_layer;
        end
end

% Clean up
delete(mask_filename);
end