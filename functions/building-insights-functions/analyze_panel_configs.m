function configs = analyze_panel_configs(response)
% Analyze panel configurations from Building Insights response
%
% Parameters:
%   response: Building Insights response
%   selected_config: (optional) Index of configuration to highlight
%
% Returns struct with configuration data and creates visualizations

% if nargin < 2
%     selected_config = [];
% end

configs = struct();

% Extract panel specs
configs.capacity = response.solarPotential.panelCapacityWatts;
configs.lifetime = response.solarPotential.panelLifetimeYears;

% Extract configuration data
n_configs = length(response.solarPotential.solarPanelConfigs);
configs.panels = zeros(1, n_configs);
configs.energy = zeros(1, n_configs);

for i = 1:n_configs
    config = response.solarPotential.solarPanelConfigs(i);
    configs.panels(i) = config.panelsCount;
    configs.energy(i) = config.yearlyEnergyDcKwh;
end



% Create visualization with 2x2 subplots
figure('Name', 'Solar Panel Configurations', 'Position', [100, 100, 1200, 800]);

% Plot 1: Total energy vs panel count (existing plot)
% subplot(2,2,1);
plot(configs.panels, configs.energy, '-', 'LineWidth', 2);
hold on; % Hold the current plot to add another line
average_energy = mean(configs.energy); % Calculate the average energy
% plot([min(configs.panels), max(configs.panels)], [average_energy, average_energy], 'r--', 'LineWidth', 2); % Plot the average line
hold off; % Release the plot
title('Total Yearly Energy Production by Configuration');
xlabel('Number of Panels');
ylabel('Total Energy (kWh DC/year)');
% grid on;

% Define statistics text box
statsTextSel = sprintf('Avg Energy Production: %.2f kWh/year\n', ...
    average_energy);

% Add the text box to the bottom-left corner of the plot
xLimitsSel = xlim;
yLimitsSel = ylim;

xPosSel = xLimitsSel(1) + 0.05 * (xLimitsSel(2) - xLimitsSel(1)); % Slightly offset from the left edge
yPosSel = yLimitsSel(2) - 0.10* (yLimitsSel(2) - yLimitsSel(1)); % Slightly offset from the top edge

text(xPosSel, yPosSel, statsTextSel, ...
    'FontSize', 9, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 5);


end