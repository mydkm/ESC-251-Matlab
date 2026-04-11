%% Params. for Paschen Curve

pd = logspace(-1,3,2000);   % 0.1 to 1000 on a log-spaced grid
gamma = 0.01; %dimensionless; assuming electrodes are made out of stainless steel

% Air
A_Air = 11; %m*bar^(-1)*cm^(-1)
B_Air = 274; %V*bar^(-1)*cm^(-1)
% Calculate the Paschen curve for Air
V_Air = B_Air .* pd ./ (log(pd) + log(A_Air) - log(log((1 / gamma) + 1)));
V_Air((log(pd) + log(A_Air) - log(log((1 / gamma) + 1))) <= 0) = NaN;

% Ar
A_Ar = 9; %m*bar^(-1)*cm^(-1)
B_Ar = 135; %V*bar^(-1)*cm^(-1)
V_Ar = B_Ar .* pd ./ (log(pd) + log(A_Ar) - log(log((1 / gamma) + 1)));
V_Ar((log(pd) + log(A_Ar) - log(log((1 / gamma) + 1))) <= 0) = NaN;

% CO2
A_CO2 = 15 %m*bar^(-1)*cm^(-1)
B_CO2 = 350 %V*bar^(-1)*cm^(-1)
V_CO2 = B_CO2 .* pd ./ (log(pd) + log(A_CO2) - log(log((1 / gamma) + 1)));
V_CO2((log(pd) + log(A_CO2) - log(log((1 / gamma) + 1))) <= 0) = NaN;

% Plot the Paschen curves for Air, Argon, and CO2
figure;
loglog(pd, V_Air, 'b', 'DisplayName', 'Air');
hold on;
loglog(pd, V_Ar, 'r', 'DisplayName', 'Argon');
loglog(pd, V_CO2, 'g', 'DisplayName', 'CO2');
hold off;
grid on;
xlabel('pd (mbar \cdot cm)');
ylabel('Voltage (V)');
title('Paschen Curves for Different Gases');
legend('show');

