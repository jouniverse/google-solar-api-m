function url = create_data_layers_url(api_key, latitude, longitude, radius_meters, required_quality)
% Generate URL for Google Solar API Data Layers endpoint
%
% Parameters:
%   api_key (string): Google Maps API key
%   latitude (double): Latitude of the location
%   longitude (double): Longitude of the location
%   radius_meters (integer): Radius in meters (zoom level)
%
% Returns:
%   url (string): Complete URL for the API request

url = sprintf(['https://solar.googleapis.com/v1/dataLayers:get?', ...
    'location.latitude=%.4f&location.longitude=%.4f&', ...
    'radiusMeters=%d&view=FULL_LAYERS&requiredQuality=%s&', ...
    'exactQualityRequired=true&pixelSizeMeters=0.5&key=%s'], ...
    latitude, longitude, radius_meters, required_quality, api_key);
end