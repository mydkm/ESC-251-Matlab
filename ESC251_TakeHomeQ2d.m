clear;
close all;
clc;

% Parameters
m = 3000.0;          % kg
b = 40.0e3;          % kg/s
k = 80.8e5;          % N/m

% Part (d) conditions
x0 = 0.01;           % initial displacement (m)
v0 = 0.0;            % initial velocity (m/s)
u1 = 0.0;            % no input force for t >= 0

% Simulink model name
mdl = "ESC251_MATLABTakeHome_Q2BD";

% Run model
out = sim(mdl);

% Extract timeseries data
t_pos = out.pos.Time;
y_pos = out.pos.Data;

t_vel = out.vel.Time;
y_vel = out.vel.Data;

% Plot displacement and velocity
figure;

subplot(2,1,1);
plot(t_pos, y_pos, 'LineWidth', 1.5);
grid on;
axis tight;
xlabel('Time (s)');
ylabel('Displacement (m)');
title('Displacement vs. Time');
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);

subplot(2,1,2);
plot(t_vel, y_vel, 'LineWidth', 1.5);
grid on;
axis tight;
xlabel('Time (s)');
ylabel('Velocity (m/s)');
title('Velocity vs. Time');
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);