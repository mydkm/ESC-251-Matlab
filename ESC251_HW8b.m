clear; clc; close all;

s = tf('s');

% Given values
T = 0.5;
wn = 12;

% From wn^2 = K/J
K_over_J = wn^2;

% Closed-loop transfer function
sys = (K_over_J*(T*s + 1))/(s^2 + K_over_J*T*s + K_over_J);

disp('Closed-loop transfer function:')
sys

% Time vector
t = 0:0.001:2;

% Unit-step response
fig1 = figure;
theme(fig1, "light");
step(sys, t);
grid on;
title('Unit-Step Response');
xlabel('Time');
ylabel('Y(t)');
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);

% Unit-ramp response
u = t;   % unit-ramp input

[y, tout] = lsim(sys, u, t);

fig2 = figure;
theme(fig2, "light");
plot(tout, y);
grid on;
title('Unit-Ramp Response');
xlabel('Time (seconds)');
ylabel('Y(t)');
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);

% Unit-impulse response
fig3 = figure;
theme(fig3, "light");
impulse(sys, t);
grid on;
title('Unit-Impulse Response');
xlabel('Time');
ylabel('Y(t)');
text(0.98, 0.02, 'Joshua Davidov', ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);