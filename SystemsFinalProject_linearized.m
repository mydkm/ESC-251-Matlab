clc;
clear;
close all;
 
% -------------------------------------------------------------------------
% Linearized Golf Club Compound-Pendulum Model
%
% Nonlinear model:
%   J*theta_ddot + b*theta_dot + m*g*d*sin(theta) = tau
%
% Linearized about theta_bar:
%   J*delta_theta_ddot + b*delta_theta_dot
%       + m*g*d*cos(theta_bar)*delta_theta = delta_tau
%
% Transfer functions:
%   DeltaTheta(s)/DeltaTau(s) = 1/(J*s^2 + b*s + k_eff)
%   DeltaOmega(s)/DeltaTau(s) = s/(J*s^2 + b*s + k_eff)
%
% Ramp torque input:
%   tau(t) = ramp_rate * t
% -------------------------------------------------------------------------
 
% Parameters
b = 0.5;      % damping coefficient (N*m*s/rad)
m = 0.40;     % golf club mass (kg)
g = 9.81;     % gravity (m/s^2)
d = 0.6;      % distance from grip/top pivot to center of mass (m)
 
J = (1/3) * m * d^2;   % moment of inertia about pivot (rod approximation)
r = 1.1;               % distance from pivot to clubhead (m)
 
% -------------------------------------------------------------------------
% Linearization operating point
% -------------------------------------------------------------------------
% Choose a reasonable equilibrium torque for linearization
 
tau_bar = 0.0;   % N*m equilibrium torque
 
% Check physical feasibility
if abs(tau_bar) > m*g*d
    error(['No static equilibrium exists because ', ...
           '|tau_bar| must be <= %.3f N*m.'], m*g*d);
end
 
theta_bar = asin(tau_bar/(m*g*d));
k_eff = m*g*d*cos(theta_bar);
 
fprintf('Linearization angle theta_bar: %.4f rad (%.2f deg)\n', ...
    theta_bar, rad2deg(theta_bar));
 
fprintf('Effective stiffness k_eff: %.4f N*m/rad\n', k_eff);
 
% -------------------------------------------------------------------------
% Transfer Functions
% -------------------------------------------------------------------------
 
% DeltaTheta(s)/DeltaTau(s)
num_theta = 1;
den = [J b k_eff];
sys_theta = tf(num_theta, den);
 
% DeltaOmega(s)/DeltaTau(s)
num_omega = [1 0];
sys_omega = tf(num_omega, den);
 
% -------------------------------------------------------------------------
% Time Vector
% -------------------------------------------------------------------------
 
t = linspace(0, 2, 1000);
 
% Impact time
t_impact = 0.4;
 
% -------------------------------------------------------------------------
% Ramp Torque Input
% -------------------------------------------------------------------------
% delta_tau(t) = ramp_rate * t
 
ramp_rate = 40;   % N*m/s
 
delta_tau = ramp_rate * t;
 
% -------------------------------------------------------------------------
% Simulate Linearized Response
% -------------------------------------------------------------------------
 
delta_theta = lsim(sys_theta, delta_tau, t);
omega = lsim(sys_omega, delta_tau, t);
 
% Convert perturbation angle back to actual angle
theta = theta_bar + delta_theta;
 
% -------------------------------------------------------------------------
% Clubhead Speed
% -------------------------------------------------------------------------
 
club_speed = r * omega;
club_speed_mag = abs(club_speed);
 
% -------------------------------------------------------------------------
% Ball Speed
% -------------------------------------------------------------------------
 
smashfactor = 1.45;
ball_speed = smashfactor * club_speed_mag;
 
% -------------------------------------------------------------------------
% Carry Distance Estimate
% -------------------------------------------------------------------------
 
launchang = 12 * pi / 180;
 
distance = (ball_speed.^2 .* sin(2*launchang)) / g;
 
% -------------------------------------------------------------------------
% Impact Values
% -------------------------------------------------------------------------
 
impact_index = find(t >= t_impact, 1);
 
club_speed_impact = club_speed_mag(impact_index);
ball_speed_impact = ball_speed(impact_index);
distance_impact = distance(impact_index);
 
% -------------------------------------------------------------------------
% Display Results
% -------------------------------------------------------------------------
 
fprintf('\n--- Impact Estimates at t = %.2f s ---\n', t_impact);
 
fprintf('Club Speed at Impact: %.2f m/s\n', ...
    club_speed_impact);
 
fprintf('Ball Speed at Impact: %.2f m/s\n', ...
    ball_speed_impact);
 
fprintf('Carry Distance Estimate: %.2f m\n', ...
    distance_impact);
 
% -------------------------------------------------------------------------
% Plots
% -------------------------------------------------------------------------
 
% Torque input
figure;
plot(t, delta_tau, 'LineWidth', 1.5);
grid on;
title('Ramp Torque Input');
xlabel('Time (s)');
ylabel('\tau(t) [N*m]');
 
% Angular position
figure;
plot(t, theta, 'LineWidth', 1.5);
hold on;
plot(t, theta_bar * ones(size(t)), '--', 'LineWidth', 1.2);
grid on;
 
title('Angular Position Response');
xlabel('Time (s)');
ylabel('\theta(t) [rad]');
 
legend('\theta(t)', '\theta_{bar}', 'Location', 'best');
 
% Angular velocity
figure;
plot(t, omega, 'LineWidth', 1.5);
grid on;
 
title('Angular Velocity During Golf Swing');
xlabel('Time (s)');
ylabel('\omega(t) [rad/s]');
 
% Clubhead speed
figure;
plot(t, club_speed_mag, 'LineWidth', 1.5);
grid on;
 
title('Clubhead Speed Magnitude');
xlabel('Time (s)');
ylabel('Speed (m/s)');
 
% Carry distance
figure;
plot(t, distance, 'LineWidth', 1.5);
grid on;
 
title('Predicted Carry Distance');
xlabel('Time (s)');
ylabel('Distance (m)');