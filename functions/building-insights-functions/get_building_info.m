function info = get_building_info(response)
% Extract basic building information from Building Insights response
%
% Returns struct with fields:
%   latitude: Building center latitude
%   longitude: Building center longitude
%   date: Image capture date
%   postal_code: Building postal code
%   quality: Imagery quality

info = struct();

% Location and date
info.latitude = response.center.latitude;
info.longitude = response.center.longitude;
info.date = sprintf('%d-%02d-%02d', ...
    response.imageryDate.year, ...
    response.imageryDate.month, ...
    response.imageryDate.day);

% Additional info if available
if isfield(response, 'postalCode')
    info.postal_code = response.postalCode;
end
if isfield(response, 'imageryQuality')
    info.quality = response.imageryQuality;
end
end