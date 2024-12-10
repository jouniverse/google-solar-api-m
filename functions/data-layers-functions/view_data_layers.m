% Define parameters
% Google Maps API key
api_key = "";
% Location
latitude = 51.51270304480631;
longitude = -0.09094876178626689;

radius_meters = 75;
required_quality = 'HIGH';

% Get URL
geoTiffURL = create_data_layers_url(api_key, latitude, longitude, radius_meters, required_quality);

% Get response
response = webread(geoTiffURL);

% Visualize all layers
visualize_solar_layers(response, api_key);

% Process specific layer (example with DSM)
process_solar_geotiff(response, api_key, 'annualflux');
process_solar_geotiff(response, api_key, 'dsm');
process_solar_geotiff(response, api_key, 'mask');

% Visualize annual flux without roof mask
visualize_annual_flux(response, api_key, false);
% Visualize annual flux with roof mask
visualize_annual_flux(response, api_key, true);
% Visualize annual flux with roof mask and separate plots
visualize_annual_flux(response, api_key, true, true);

% Visualize monthly flux for June, no roof mask
visualize_monthly_flux(response, api_key, 1, false);
% Visualize monthly flux for June, with roof mask
visualize_monthly_flux(response, api_key, 1, true);

% Visualize hourly shade for specific date and time
% Without roof mask
visualize_hourly_shade(response, api_key, 6, 15, 9, false);  % June 15th at noon
% % % % With roof mask
visualize_hourly_shade(response, api_key, 6, 15, 9, true);  % June 15th at noon, roof area only

% Animate hourly shade
% Without mask
animate_hourly_shade(response, api_key, 7, 15, false);  % June 15th
% With mask
animate_hourly_shade(response, api_key, 7, 15, true);  % June 15th with roof mask

% Plot sun/shade distribution
% For entire area
sun_shade_distribution(response, api_key, 6, 15, false);  % June 15th
% For roof area only
sun_shade_distribution(response, api_key, 12, 9, true);   % June 15th

% Visualize monthly flux with roof mask
visualize_monthly_flux(response, api_key, 6, true);  % June with roof mask
visualize_monthly_flux(response, api_key, 6, false);  % June without roof mask

