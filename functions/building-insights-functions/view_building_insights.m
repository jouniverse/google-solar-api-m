% Define parameters
api_key = "";
latitude = 51.51270304480631;
longitude = -0.09094876178626689;
% required_quality = 'MEDIUM';
required_quality = 'HIGH';

% Create URL and get response
url = create_building_insights_url(api_key, latitude, longitude, required_quality);
response = webread(url);

% Get building information
info = get_building_info(response);
fprintf('Building Information:\n');
fprintf('Location: %.4f, %.4f\n', info.latitude, info.longitude);
fprintf('Image Date: %s\n', info.date);
if isfield(info, 'postal_code')
    fprintf('Postal Code: %s\n', info.postal_code);
end
fprintf('\n');

% Analyze solar potential
potential = analyze_solar_potential(response);

% % Analyze roof statistics
stats = analyze_roof_stats(response);

% % Analyze panel configurations
configs = analyze_panel_configs(response);

% Analyze individual panels
analyze_individual_panels(response);

% Visualize panel locations
visualize_panel_locations(response);

