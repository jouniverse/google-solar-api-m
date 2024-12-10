function potential = analyze_solar_potential(response)
% Analyze solar potential data from Building Insights response
%
% Returns struct with solar potential metrics and creates visualization

potential = struct();

% Extract metrics
potential.max_panels = response.solarPotential.maxArrayPanelsCount;
potential.max_area = response.solarPotential.maxArrayAreaMeters2;
potential.max_sunshine = response.solarPotential.maxSunshineHoursPerYear;
potential.carbon_offset = response.solarPotential.carbonOffsetFactorKgPerMwh;

% Display text summary
fprintf('Maximum Configuration:\n');
fprintf('• Number of Panels: %d\n', potential.max_panels);
fprintf('• Array Area: %.1f m²\n', potential.max_area);
fprintf('• Annual Sunshine: %.1f hours\n', potential.max_sunshine);
fprintf('• Carbon Offset: %.1f kg/MWh\n', potential.carbon_offset);

end