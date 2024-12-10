function url = create_building_insights_url(api_key, latitude, longitude, required_quality)
% Generate URL for Google Solar API Building Insights endpoint
%
% Parameters:
%   api_key (string): Google Maps API key
%   latitude (double): Latitude of the location
%   longitude (double): Longitude of the location
%
% Returns:
%   url (string): Complete URL for the API request
url = sprintf(['https://solar.googleapis.com/v1/buildingInsights:findClosest?', ...
    'location.latitude=%.4f&location.longitude=%.4f&', ...
    'requiredQuality=%s&key=%s'], latitude, longitude, required_quality, api_key);
end
