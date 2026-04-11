% Params.

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
Es = 10/s %V

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
syms s t

% setup for part (a)
F = (N*Km) / (L*Jeq*s^2 + (B*L + R*Jeq)*s + (R*B + Kg*Km*N^2))
Omega_step = Es*F;
omega_t = ilaplace(Omega_step, s, t)

% setup for part (f)
Fb = (N*Kmb) / (L*Jeqb*s^2 + (B*L + Rb*Jeqb)*s + (Rb*B + Kgb*Kmb*N^2))
Omega_stepb = Es*Fb
omega_tb = ilaplace(Omega_stepb, s, t)

% plot the time response for part (a)
figure(1)
tt = 0:0.01:1; % time vector
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

% plot the time response for part (f)
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

% steady-state
steadyStateA = limit(omega_t, t, inf);
steadyStateA_RPM = (steadyStateA * 60) / (2*pi);
steadyStateF = limit(omega_tb, t, inf);
steadyStateF_RPM = (steadyStateF * 60) / (2*pi);
fprintf('Steady-state Angular Velocity (Part A): %s\n', double(steadyStateA));
fprintf('Steady-state Angular Velocity (Part A; RPM): %s\n', double(steadyStateA_RPM));
fprintf('Steady-state Angular Velocity (Part F): %s\n', double(steadyStateF));
fprintf('Steady-state Angular Velocity (Part F; RPM): %s\n', double(steadyStateF_RPM));

% using lsim to find part (g) behavior
x0 = [0, 100] % assume motor is starting from rest
u2 = 0; % input signal
% sysA = tf([N*Kmb], [L*Jeq, (B*L + R*Jeq), (R*B + Kg*Km*N^2)]); % transfer function for part (a)
% sysF = tf([N*Kmb], [L*Jeqb, (B*L + Rb*Jeqb), (Rb*B + Kgb*Kmb*N^2)]); % transfer function for part (f)
lsim(Fb, u2, t, x0)

% plot for part (g)
figure(3)
responseG = lsim(Fb, u2, tt, x0);
plot(tt, responseG);
xlabel('Time (s)');
ylabel('Angular Velocity (rad/s)');
title('Response of the System (Part G)');
grid on;
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);
