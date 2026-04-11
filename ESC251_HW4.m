m1 = 1000;   % kg
m2 = 100;    % kg
b  = 4000;   % kg/s
k1 = 20000;  % N/m
k2_values = [5000 10000];  % N/m
t = 0:0.01:16;

% Triangle bump: 0 -> 1 cm -> -1 cm -> 0 over first 4 s
u1 = 0:0.01:1;
u2 = 0.99:-0.01:-1;
u3 = -0.99:0.01:0;
u4 = zeros(size(4.01:0.01:16));
u_cm = [u1 u2 u3 u4];   % bump in cm
u = 0.01 * u_cm;        % convert to meters

% Output both displacements: y = [x1; x2]
C = [1 0 0 0];
D = [0];

y_store = cell(length(k2_values),1); 

for i = 1:length(k2_values)
    k2 = k2_values(i);

    A = [0       0           1       0;
         0       0           0       1;
        -k1/m1   k1/m1      -b/m1    b/m1;
         k1/m2  -(k1+k2)/m2  b/m2   -b/m2];

    B = [0;
         0;
         0;
         k2/m2];

    sys = ss(A,B,C,D);
    y = lsim(sys,u,t);

    y_store{i} = y;
end

% Plot x1 (driver/body displacement)
figure;
plot(t, y_store{1}(:,1), 'LineWidth', 1.5); hold on;
plot(t, y_store{2}(:,1), 'LineWidth', 1.5);
plot(t, u, '--k', 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('Displacement (m)');
title('Driver/Body Displacement x_1(t)');
legend('x_1, (k_2 = 5000 N/m)', 'x_1, (k_2 = 10000 N/m)', 'Road input u(t)');
