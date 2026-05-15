%% plot_scope_voltage_current_power_rms_revised.m
% Reads Tektronix-style CSV files containing TIME, CH1, and CH4 data.
%
% Assumptions:
%   TIME = time relative to oscilloscope trigger, in seconds
%   CH1  = voltage, in volts
%   CH4  = current, in amps
%
% Requested figures:
%   1. Time vs. Voltage, Separated by Test
%   2. Time vs. Smoothed Voltage, Separated by Test
%   3. Time vs. Current, Separated by Test
%   4. Time vs. Smoothed Current, Separated by Test
%   5. Time vs. Power, Separated by Test
%   6. Time vs. Smoothed Power, Separated by Test
%   7. Time vs. RMS Voltage
%   8. Time vs. RMS Current

clear; clc; close all;

%% -------------------- User settings --------------------
dataFolder = pwd;
filePattern = "5-1-26 Test_*_ALL.csv";

timeScale = 1e3;
timeUnits = "ms";

% Moving-average smoothing settings.
smoothingFraction = 0.01;
minSmoothWindowSamples = 5;

% Moving RMS window.
rmsWindowSec = 50e-6;

% IMPORTANT:
% Use no plotting downsampling for raw voltage so Figure 1 cannot look
% artificially smoothed.
maxPlotPointsRawVoltage = [];

% Use optional plotting downsampling for the denser processed figures.
% This affects display only, not calculations.
maxPlotPointsProcessed = 10000;

% Use automatic y-limits for raw voltage so spikes/details are not hidden.
visualYPercentilesRawVoltage = [];

% Use percentile limits for other separated plots to reduce spike domination.
visualYPercentilesDefault = [1, 99];

% Okabe-Ito color-blind friendly palette.
colors = [
    0,   0,   0;     % black
    230, 159, 0;     % orange
    86,  180, 233;   % sky blue
    0,   158, 115;   % bluish green
    240, 228, 66;    % yellow
    0,   114, 178;   % blue
    213, 94,  0;     % vermillion
    204, 121, 167    % reddish purple
] / 255;

%% -------------------- Find and load files --------------------
files = dir(fullfile(dataFolder, filePattern));

if isempty(files)
    error("No CSV files found in '%s' matching pattern '%s'.", dataFolder, filePattern);
end

[~, sortIdx] = sort({files.name});
files = files(sortIdx);

data = struct( ...
    'Label', {}, ...
    'Time', {}, ...
    'TimePlot', {}, ...
    'Voltage', {}, ...
    'SmoothedVoltage', {}, ...
    'Current', {}, ...
    'SmoothedCurrent', {}, ...
    'Power', {}, ...
    'SmoothedPower', {}, ...
    'RMSVoltage', {}, ...
    'RMSCurrent', {} ...
);

for k = 1:numel(files)
    filePath = fullfile(files(k).folder, files(k).name);
    T = readScopeCsv(filePath);

    t = T.Time_s;
    v = T.Voltage_V;
    i = T.Current_A;

    valid = isfinite(t) & isfinite(v) & isfinite(i);
    t = t(valid);
    v = v(valid);
    i = i(valid);

    if numel(t) < 2
        warning("Skipping '%s' because it has fewer than two valid data points.", files(k).name);
        continue;
    end

    p = v .* i;

    dt = median(diff(t), 'omitnan');
    if ~isfinite(dt) || dt <= 0
        warning("Skipping '%s' because its time column is not strictly usable.", files(k).name);
        continue;
    end

    % Moving-average smoothing.
    smoothWindowSamples = round(smoothingFraction * numel(t));
    smoothWindowSamples = max(minSmoothWindowSamples, smoothWindowSamples);
    smoothWindowSamples = min(smoothWindowSamples, numel(t));

    vSmooth = movmean(v, smoothWindowSamples, 'Endpoints', 'shrink');
    iSmooth = movmean(i, smoothWindowSamples, 'Endpoints', 'shrink');
    pSmooth = movmean(p, smoothWindowSamples, 'Endpoints', 'shrink');

    % Moving RMS.
    rmsWindowSamples = round(rmsWindowSec / dt);
    rmsWindowSamples = max(1, rmsWindowSamples);
    rmsWindowSamples = min(rmsWindowSamples, numel(t));

    vRMS = sqrt(movmean(v.^2, rmsWindowSamples, 'Endpoints', 'shrink'));
    iRMS = sqrt(movmean(i.^2, rmsWindowSamples, 'Endpoints', 'shrink'));

    [~, baseName, ~] = fileparts(files(k).name);
    baseName = erase(baseName, "_ALL");

    data(end + 1).Label = baseName; %#ok<SAGROW>
    data(end).Time = t;
    data(end).TimePlot = t * timeScale;

    % Store raw and smoothed signals as completely separate fields.
    data(end).Voltage = v;
    data(end).SmoothedVoltage = vSmooth;

    data(end).Current = i;
    data(end).SmoothedCurrent = iSmooth;

    data(end).Power = p;
    data(end).SmoothedPower = pSmooth;

    data(end).RMSVoltage = vRMS;
    data(end).RMSCurrent = iRMS;
end

if isempty(data)
    error("No valid data was loaded.");
end

%% -------------------- Make requested plots --------------------
xLabel = "Time (" + timeUnits + ")";

% 1. Time vs. Voltage, Separated by Test
% This uses raw Voltage, no smoothing, no plotting downsampling.
makeTiledSignalPlot(data, 'Voltage', ...
    "Time vs. Voltage, Separated by Test", ...
    xLabel, "Voltage (V)", colors, ...
    maxPlotPointsRawVoltage, visualYPercentilesRawVoltage);

% 2. Time vs. Smoothed Voltage, Separated by Test
makeTiledSignalPlot(data, 'SmoothedVoltage', ...
    "Time vs. Smoothed Voltage, Separated by Test", ...
    xLabel, "Voltage (V)", colors, ...
    maxPlotPointsProcessed, visualYPercentilesDefault);

% 3. Time vs. Current, Separated by Test
makeTiledSignalPlot(data, 'Current', ...
    "Time vs. Current, Separated by Test", ...
    xLabel, "Current (A)", colors, ...
    maxPlotPointsProcessed, visualYPercentilesDefault);

% 4. Time vs. Smoothed Current, Separated by Test
makeTiledSignalPlot(data, 'SmoothedCurrent', ...
    "Time vs. Smoothed Current, Separated by Test", ...
    xLabel, "Current (A)", colors, ...
    maxPlotPointsProcessed, visualYPercentilesDefault);

% 5. Time vs. Power, Separated by Test
makeTiledSignalPlot(data, 'Power', ...
    "Time vs. Power, Separated by Test", ...
    xLabel, "Power (W)", colors, ...
    maxPlotPointsProcessed, visualYPercentilesDefault);

% 6. Time vs. Smoothed Power, Separated by Test
makeTiledSignalPlot(data, 'SmoothedPower', ...
    "Time vs. Smoothed Power, Separated by Test", ...
    xLabel, "Power (W)", colors, ...
    maxPlotPointsProcessed, visualYPercentilesDefault);

% 7. Time vs. RMS Voltage
makeOverlaySignalPlot(data, 'RMSVoltage', ...
    "Time vs. RMS Voltage", ...
    xLabel, "RMS Voltage (V)", colors, maxPlotPointsProcessed);

% 8. Time vs. RMS Current
makeOverlaySignalPlot(data, 'RMSCurrent', ...
    "Time vs. RMS Current", ...
    xLabel, "RMS Current (A)", colors, maxPlotPointsProcessed);

%% -------------------- Local functions --------------------
function T = readScopeCsv(filePath)
    fid = fopen(filePath, 'r');

    if fid == -1
        error("Could not open file: %s", filePath);
    end

    cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

    headerLine = [];
    lineNumber = 0;

    while ~feof(fid)
        lineNumber = lineNumber + 1;
        currentLine = fgetl(fid);

        if ischar(currentLine) && startsWith(strtrim(currentLine), 'TIME')
            headerLine = lineNumber;
            break;
        end
    end

    if isempty(headerLine)
        error("Could not find a TIME header row in file: %s", filePath);
    end

    opts = delimitedTextImportOptions("NumVariables", 3);
    opts.Delimiter = ",";
    opts.DataLines = [headerLine + 1, Inf];
    opts.VariableNames = ["Time_s", "Voltage_V", "Current_A"];
    opts.VariableTypes = ["double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    T = readtable(filePath, opts);
end

function makeTiledSignalPlot(data, yField, superTitleText, xLabelText, yLabelText, ...
    colors, maxPlotPoints, visualYPercentiles)

    figure('Color', 'w');

    tiledlayout(numel(data), 1, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');

    yLimits = getVisualYLimits(data, yField, visualYPercentiles);

    for k = 1:numel(data)
        nexttile;
        hold on;
        grid on;
        box on;

        x = data(k).TimePlot;
        y = data(k).(yField);

        [xPlot, yPlot] = downsampleForPlot(x, y, maxPlotPoints);

        colorIdx = mod(k - 1, size(colors, 1)) + 1;

        plot(xPlot, yPlot, ...
            'Color', colors(colorIdx, :), ...
            'LineWidth', 0.8);

        if ~isempty(yLimits)
            ylim(yLimits);
        end

        ylabel(yLabelText);

        text(0.01, 0.85, data(k).Label, ...
            'Units', 'normalized', ...
            'Interpreter', 'none', ...
            'FontWeight', 'bold', ...
            'BackgroundColor', 'w', ...
            'Margin', 2);

        if k < numel(data)
            set(gca, 'XTickLabel', []);
        else
            xlabel(xLabelText);
        end

        hold off;
    end

    sgtitle(superTitleText);
    drawnow;
end

function makeOverlaySignalPlot(data, yField, superTitleText, xLabelText, yLabelText, ...
    colors, maxPlotPoints)

    figure('Color', 'w');

    tiledlayout(1, 1, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');

    nexttile;
    hold on;
    grid on;
    box on;

    for k = 1:numel(data)
        x = data(k).TimePlot;
        y = data(k).(yField);

        [xPlot, yPlot] = downsampleForPlot(x, y, maxPlotPoints);

        colorIdx = mod(k - 1, size(colors, 1)) + 1;

        plot(xPlot, yPlot, ...
            'Color', colors(colorIdx, :), ...
            'LineWidth', 1.25, ...
            'DisplayName', data(k).Label);
    end

    xlabel(xLabelText);
    ylabel(yLabelText);
    legend('Location', 'best', 'Interpreter', 'none');

    sgtitle(superTitleText);

    hold off;
    drawnow;
end

function [xPlot, yPlot] = downsampleForPlot(x, y, maxPlotPoints)
    % No downsampling if maxPlotPoints is empty, infinite, or nonpositive.
    if isempty(maxPlotPoints) || isinf(maxPlotPoints) || maxPlotPoints <= 0 || numel(x) <= maxPlotPoints
        xPlot = x;
        yPlot = y;
        return;
    end

    idx = unique(round(linspace(1, numel(x), maxPlotPoints)));
    xPlot = x(idx);
    yPlot = y(idx);
end

function yLimits = getVisualYLimits(data, yField, visualYPercentiles)
    if isempty(visualYPercentiles)
        yLimits = [];
        return;
    end

    allY = [];

    for k = 1:numel(data)
        y = data(k).(yField);
        allY = [allY; y(:)]; %#ok<AGROW>
    end

    allY = allY(isfinite(allY));

    if isempty(allY)
        yLimits = [];
        return;
    end

    yLow = localPercentile(allY, visualYPercentiles(1));
    yHigh = localPercentile(allY, visualYPercentiles(2));

    if ~isfinite(yLow) || ~isfinite(yHigh) || yHigh <= yLow
        yLimits = [];
        return;
    end

    pad = 0.05 * (yHigh - yLow);
    yLimits = [yLow - pad, yHigh + pad];

    if min(allY) >= 0
        yLimits(1) = max(0, yLimits(1));
    end
end

function p = localPercentile(x, pct)
    x = sort(x(:));
    n = numel(x);

    if n == 0
        p = NaN;
        return;
    end

    pct = min(max(pct, 0), 100);

    if n == 1
        p = x(1);
        return;
    end

    pos = 1 + (pct / 100) * (n - 1);
    lo = floor(pos);
    hi = ceil(pos);

    if lo == hi
        p = x(lo);
    else
        frac = pos - lo;
        p = (1 - frac) * x(lo) + frac * x(hi);
    end
end