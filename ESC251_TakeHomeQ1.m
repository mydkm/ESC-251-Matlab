% Params.
% Define symbols for symbolic math
syms s t

%% motor from part (a)
R = 3.3 %ohm
L = 0.1 %H
J1 = 9.64 * 10^-6 %kg*m^2
m = 0.033 %kg
r = 0.0242 %m
B = 0.01 %N*m*s
Km = 0.0280 %N*m*(A^-1)
Kg = 0.0280 %V*s*(rad^-1)
J2 = 0.5 * m * (r^2) %kg*m^2
N = 2
Jeq = (N^2)*J1 + J2 %kg*m^2

%% motor from part (f)
%%% note that if the figure is not changed, refer to part (a) values.
J1b = 4.65 * 10^-6 %kg*m^2
mb = 0.053 %kg
rb  =0.0248 %m
Rb = 8.4 %ohm
Kmb = 0.042 %N*m/A
Kgb = Kmb %V*s/rad
J2b = 0.5 * mb * (rb^2) %kg*m^2
Jeqb = (N^2)*J1b + J2b %kg*m^2
Es = 10/s %V


%% simulink
Kp = 100;
%% main code
% setup for part (a)
F = (N*Km) / (L*Jeq*s^2 + (B*L + R*Jeq)*s + (R*B + Kg*Km*N^2))
Omega_step = Es*F;
omega_t = ilaplace(Omega_step, s, t)

% setup for part (f)
Fb = (N*Kmb) / (L*Jeqb*s^2 + (B*L + Rb*Jeqb)*s + (Rb*B + Kgb*Kmb*N^2))
Omega_stepb = Es*Fb
omega_tb = ilaplace(Omega_stepb, s, t)

% plot for part (a)
figure(1)
tt = 0:0.001:0.500; % time vector
response = double(subs(omega_t, t, tt)); % evaluate the inverse Laplace transform
plot(tt, response);
xlabel('Time (s)');
ylabel('Angular Velocity (rad/s)');
title('Time Response of the System (Part A)');
grid on;
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);

% plot for part (e)
% Choose states x = [omega; i]
Ae = [-B/Jeq,   Km*N/Jeq;
      -Kg*N/L,      -R/L];
Be = [0; 1/L];
Ce = [1 0];
De = 0;

sysFss = ss(Ae,Be,Ce,De);
u = 10*ones(size(tt));
x0 = [0; 0];

figure(3)
responseG = lsim(sysFss, u, tt, x0);
plot(tt, responseG)
xlabel('Time (s)')
ylabel('Angular Velocity (rad/s)')
title('Time Response of the System (Part E)')
grid on
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);

% plot for part (f)
figure(2)
responseb = double(subs(omega_tb, t, tt)); % evaluate the inverse Laplace transform
plot(tt, responseb);
xlabel('Time (s)');
ylabel('Angular Velocity (rad/s)');
title('Time Response of the System (Part F)');
grid on;
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);

% plot for part (g)
Ae = [-B/Jeqb,   Kmb*N/Jeqb;
      -Kgb*N/L,      -Rb/L];
Be = [0; 1/L];
Ce = [1 0];
De = 0;

sysFss = ss(Ae,Be,Ce,De);
u = 10*ones(size(tt));
x0_g = [100; 0];

figure(4)
responseG = lsim(sysFss, u, tt, x0_g);
plot(tt, responseG)
xlabel('Time (s)')
ylabel('Angular Velocity (rad/s)')
title('Time Response of the System (Part G)')
grid on
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);

% steady-state/other calcs
steadyStateA = limit(omega_t, t, inf);
steadyStateA_RPM = (steadyStateA * 60) / (2*pi);
steadyStateF = limit(omega_tb, t, inf);
steadyStateF_RPM = (steadyStateF * 60) / (2*pi);
omega0 = x0_g(1);
target = 0.368 * omega0;

fprintf('Steady-state Angular Velocity (Part A): %.6f rad/s\n', double(steadyStateA));
fprintf('Steady-state Angular Velocity (Part A): %.6f RPM\n', double(steadyStateA_RPM));
fprintf('Steady-state Angular Velocity (Part F): %.6f rad/s\n', double(steadyStateF));
fprintf('Steady-state Angular Velocity (Part F): %.6f RPM\n', double(steadyStateF_RPM));

% Find time where omega is closest to 0.368*omega0
[~, idx] = min(abs(responseG - target));
t_target = tt(idx);
omega_target = responseG(idx);

fprintf('Target value: %.6f rad/s\n', target);
fprintf('Closest angular velocity: %.6f rad/s\n', omega_target);
fprintf('Occurs at t = %.6f s\n', t_target);

% Simulink Data
t_response = out.response.Time;
y_response = out.response.Data;

t_error = out.error.Time;
y_error = out.error.Data;

figure(5);
plot(t_response, y_response);
grid on;
xlabel('Time (s)');
ylabel('Response');
title('Closed-Loop Response');
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);

figure(6);
plot(t_error, y_error);
grid on;
xlabel('Time (s)');
ylabel('Error');
title('Tracking Error');
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);