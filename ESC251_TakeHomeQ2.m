clear;
close all;
clc;

% Parameters
m = 3000.0;          % kg
k = 80.8e5;          % N/m
u1 = 20000;          % N

% Damping values
b_vals = [40e2, 40e3, 40e4, 40e5];   % kg/s

% Simulink model name
mdl = "ESC251_MATLABTakeHome_Q2BD";

% Main comparison figure
figure(1);
hold on;
grid on;

for i = 1:length(b_vals)
    b = b_vals(i);  
    out = sim(mdl);

    % Extract timeseries data
    t_accel = out.accel.Time;
    y_accel = out.accel.Data;

    t_vel = out.vel.Time;
    y_vel = out.vel.Data;

    t_force = out.force.Time;
    y_force = out.force.Data;

    t_pos = out.pos.Time;
    y_pos = out.pos.Data;

    % Plot the accel/vel/force figure only for the first b value
    if i == 1
        figure(2);

        subplot(3,1,1);
        plot(t_accel, y_accel, 'LineWidth', 1.5);
        grid on;
        xlabel('Time (s)');
        ylabel('Acceleration (m/s^2)');
        title('Acceleration vs. Time');

        subplot(3,1,2);
        plot(t_vel, y_vel, 'LineWidth', 1.5);
        grid on;
        xlabel('Time (s)');
        ylabel('Velocity (m/s)');
        title('Velocity vs. Time');

        subplot(3,1,3);
        plot(t_force, y_force, 'LineWidth', 1.5);
        grid on;
        xlabel('Time (s)');
        ylabel('Force (N)');
        title('Input Force vs. Time');
    end

    % Main comparison plot goes in figure 1 for every b
    figure(1);
    plot(t_pos, y_pos, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('b = %.1e kg/s', b));
end

figure(1);
xlabel('Time (s)');
ylabel('Displacement (m)');
title('Displacement Response for Different Damping Coefficients');
legend('Location','best');
hold off;