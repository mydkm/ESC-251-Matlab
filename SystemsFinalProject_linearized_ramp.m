clc;
clear;
close all;

% ------------------------------------------------------------
% Linearized Compound-Pendulum Golf Club Model
% with Unit Ramp Torque Input: tau(t) = t - 0.5
% ------------------------------------------------------------

% Parameters
b = 0.5;      % damping coefficient (N*m*s/rad)
m = 0.40;     % club mass (kg)
g = 9.81;     % gravity (m/s^2)
d = 1.0;      % distance from pivot/top to COM (m)

% Club geometry
L = 1.1;      % club length / distance from pivot to clubhead (m)

% Moment of inertia about pivot/top
% For a uniform rod pivoted at one end, J = (1/3)mL^2.
% If d is the COM distance and L is total club length, this approximation
% assumes a rod-like club.
J = (1/3) * m * L^2;

% ------------------------------------------------------------
% Operating point for linearization
% ------------------------------------------------------------
% Nonlinear model:
%   J*theta_ddot + b*theta_dot + m*g*d*sin(theta) = tau
%
% Linearized perturbation model about theta_bar:
%   J*delta_theta_ddot + b*delta_theta_dot
%       + m*g*d*cos(theta_bar)*delta_theta = delta_tau
%
% Equilibrium condition:
%   tau_bar = m*g*d*sin(theta_bar)

tau_bar = 0;  % nominal operating torque (N*m)

% Check that the requested operating torque is physically valid
if abs(tau_bar) > m*g*d
    error('Invalid operating point: |tau_bar| must be <= m*g*d.');
end

theta_bar = asin(tau_bar/(m*g*d));       % operating angle (rad)
k_eff = m*g*d*cos(theta_bar);            % effective linearized stiffness

fprintf('Operating angle theta_bar: %.4f rad\n', theta_bar);
fprintf('Effective stiffness k_eff: %.4f N*m/rad\n', k_eff);

% ------------------------------------------------------------
% Transfer Function: Angular Velocity / Perturbation Torque
% ------------------------------------------------------------
% From:
%   J*delta_theta_ddot + b*delta_theta_dot + k_eff*delta_theta = delta_tau
%
% Then:
%   DeltaTheta(s)/DeltaTau(s) = 1/(J*s^2 + b*s + k_eff)
%
% Since:
%   DeltaOmega(s) = s*DeltaTheta(s)
%
% Therefore:
%   DeltaOmega(s)/DeltaTau(s) = s/(J*s^2 + b*s + k_eff)

num_omega = [1 0];
den = [J b k_eff];

sys_omega = tf(num_omega, den);

% Optional: angular position transfer function
num_theta = 1;
sys_theta = tf(num_theta, den);

% ------------------------------------------------------------
% Time vector
% ------------------------------------------------------------
t = linspace(0, 2, 1000);

% ------------------------------------------------------------
% Unit ramp torque input
% ------------------------------------------------------------
% User-requested input:
%   tau(t) = t - 0.5
%
% For this linearized model, this is interpreted as the perturbation input:
%   delta_tau(t) = t - 0.5

delta_tau = 40*t - 0.5;

% If you want the total physical torque, it is:
tau_total = tau_bar + delta_tau;

% ------------------------------------------------------------
% System response
% ------------------------------------------------------------
% Perturbation angular velocity
delta_omega = lsim(sys_omega, delta_tau, t);

% Perturbation angular position
delta_theta = lsim(sys_theta, delta_tau, t);

% Total angle approximation
theta_total = theta_bar + delta_theta;

% Clubhead speed
club_speed = L * delta_omega;

% Ball speed using simple smash-factor model
smashfactor = 1.45;
ball_speed = smashfactor * club_speed;

% Carry distance using projectile approximation
launchang = 12 * pi / 180;
distance = (ball_speed.^2 .* sin(2*launchang)) / g;

% ------------------------------------------------------------
% Values at final time
% ------------------------------------------------------------
final_index = length(t);

club_speed_final = club_speed(final_index);
ball_speed_final = ball_speed(final_index);
distance_final = distance(final_index);

fprintf('Final Torque Input: %.2f N*m\n', tau_total(final_index));
fprintf('Final Angular Velocity Perturbation: %.2f rad/s\n', delta_omega(final_index));
fprintf('Final Club Speed: %.2f m/s\n', club_speed_final);
fprintf('Final Ball Speed: %.2f m/s\n', ball_speed_final);
fprintf('Final Carry Distance Estimate: %.2f m\n', distance_final);

% ------------------------------------------------------------
% Plots
% ------------------------------------------------------------

% Torque input
figure;
plot(t, delta_tau, 'LineWidth', 1.5);
grid on;
title('Unit Ramp Perturbation Torque Input');
xlabel('Time (s)');
ylabel('\delta\tau(t) [N*m]');

% Angular position perturbation
figure;
plot(t, delta_theta, 'LineWidth', 1.5);
grid on;
title('Angular Position Perturbation');
xlabel('Time (s)');
ylabel('\delta\theta(t) [rad]');

% Total angle approximation
figure;
plot(t, theta_total, 'LineWidth', 1.5);
grid on;
title('Total Angle Approximation');
xlabel('Time (s)');
ylabel('\theta(t) [rad]');

% Angular velocity perturbation
figure;
plot(t, delta_omega, 'LineWidth', 1.5);
grid on;
title('Angular Velocity Perturbation During Golf Swing');
xlabel('Time (s)');
ylabel('\delta\omega(t) [rad/s]');

% Clubhead speed
figure;
plot(t, club_speed, 'LineWidth', 1.5);
grid on;
title('Clubhead Speed from Linearized Model');
xlabel('Time (s)');
ylabel('Speed (m/s)');

% Carry distance
figure;
plot(t, distance, 'LineWidth', 1.5);
grid on;
title('Predicted Carry Distance');
xlabel('Time (s)');
ylabel('Distance (m)');
