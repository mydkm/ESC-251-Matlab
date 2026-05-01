%% Params. for Paschen Curve
pd = logspace(-1,3,2000); % 0.1 to 1000 on a log-spaced grid
gamma = 0.01; %dimensionless; assuming electrodes are made out of stainless steel
mbartotorr = 0.750062;
psitotorr = 51.7149;
Patm = 1013.25*mbartotorr %torr
x = [Patm*0.2, (Patm+(4*psitotorr))*0.2] %torr*cm
labels = {"(760.00 mbar * 2 mm)", "(966.86 mbar * 2 mm)"};

% Air
A_Air = 15; %m*bar^(-1)*cm^(-1)
B_Air = 365; %V*bar^(-1)*cm^(-1)
V_Air = B_Air .* pd ./ (log(pd) + log(A_Air) - log(log((1 / gamma) + 1)));
V_Air((log(pd) + log(A_Air) - log(log((1 / gamma) + 1))) <= 0) = NaN;

% Ar
A_Ar = 12; %m*bar^(-1)*cm^(-1)
B_Ar = 180; %V*bar^(-1)*cm^(-1)
V_Ar = B_Ar .* pd ./ (log(pd) + log(A_Ar) - log(log((1 / gamma) + 1)));
V_Ar((log(pd) + log(A_Ar) - log(log((1 / gamma) + 1))) <= 0) = NaN;

% CO2
A_CO2 = 20 %m*bar^(-1)*cm^(-1)
B_CO2 = 466 %V*bar^(-1)*cm^(-1)
V_CO2 = B_CO2 .* pd ./ (log(pd) + log(A_CO2) - log(log((1 / gamma) + 1)));
V_CO2((log(pd) + log(A_CO2) - log(log((1 / gamma) + 1))) <= 0) = NaN;

% Plot the Paschen curves for Air, Argon, and CO2
figure;
loglog(pd, V_Air, 'b', 'DisplayName', 'Air');
hold on;
loglog(pd, V_Ar, 'r', 'DisplayName', 'Argon');
loglog(pd, V_CO2, 'g', 'DisplayName', 'CO2');
y_air_pts = interp1(pd, V_Air, x, 'makima');
scatter(x, y_air_pts, 'filled', 'DisplayName', 'Selected Paschen Curve Points');
text(x, y_air_pts, labels, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left')
hold off;
grid on;
xlabel('pd (torr \cdot cm)');
ylabel('Voltage (V)');
title('Paschen Curves for Different Gases');
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);
legend('show');

% Plot Paschen curves for Air only, varying gamma

gamma_vals = 10.^(-5:-1);  % [10^-5, 10^-4, 10^-3, 10^-2, 10^-1]

figure;

for i = 1:length(gamma_vals)
    gamma_i = gamma_vals(i);

    denom = log(pd) + log(A_Air) - log(log((1 / gamma_i) + 1));

    V_Air_gamma = B_Air .* pd ./ denom;
    V_Air_gamma(denom <= 0) = NaN;

    loglog(pd, V_Air_gamma, ...
        'LineWidth', 1.5, ...
        'DisplayName', sprintf('\\gamma = 10^{%d}', log10(gamma_i)));
    
    hold on;
end

hold off;
grid on;

xlabel('pd (torr \cdot cm)');
ylabel('Voltage (V)');
title('Paschen Curve for Air at Different Secondary Emission Coefficients');

text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);

legend('show', 'Location', 'northeast');