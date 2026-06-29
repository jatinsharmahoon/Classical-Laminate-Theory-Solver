% JATIN SHARMA
% 23BME050

clc; clear; close all;
fprintf('LAMINATE ANALYSIS\n');

%% INPUT

n = input('Enter number of plies: ');

El = zeros(1,n); Et = zeros(1,n); Glt = zeros(1,n);
vlt = zeros(1,n); theta = zeros(1,n); t = zeros(1,n);

fprintf('\n--- Enter properties for each ply ---\n');

for i = 1:n
    fprintf('\nPly %d:\n', i);
    El(i) = input('El (Pa): ');
    Et(i) = input('Et (Pa): ');
    Glt(i) = input('Glt (Pa): ');
    vlt(i) = input('vlt: ');
    theta(i) = input('Theta (deg): ');
    t(i) = input('Thickness (m): ');
end

%% LOAD INPUT 

fprintf('\n--- Load Input Type ---\n');
fprintf('1 → Only Forces\n2 → Only Moments\n3 → Both\n');

choice = input('Enter choice: ');

switch choice
    case 1
        Nx = input('Nx (N/m): ');
        Ny = input('Ny (N/m): ');
        Nxy = input('Nxy (N/m): ');
        Mx = 0; My = 0; Mxy = 0;
        
    case 2
        Mx = input('Mx: ');
        My = input('My: ');
        Mxy = input('Mxy: ');
        Nx = 0; Ny = 0; Nxy = 0;
        
    case 3
        Nx = input('Nx (N/m): ');
        Ny = input('Ny (N/m): ');
        Nxy = input('Nxy (N/m): ');
        Mx = input('Mx: ');
        My = input('My: ');
        Mxy = input('Mxy: ');
        
    otherwise
        error('Invalid choice!');
end

NM = [Nx; Ny; Nxy; Mx; My; Mxy];

%% Z COORDINATES

h = sum(t);
z = zeros(n+1,1);
z(1) = -h/2;

for i = 2:n+1
    z(i) = z(i-1) + t(i-1);
end

%% ABD MATRICES

A = zeros(3); B = zeros(3); D = zeros(3);

Qbar_all = cell(1,n);
T1_all = cell(1,n);
T2_all = cell(1,n);

for k = 1:n
    
    % LOCAL COMPLIANCE 
    S = [1/El(k)   -vlt(k)/El(k)   0;
         -vlt(k)/El(k)   1/Et(k)   0;
         0   0   1/Glt(k)];

    Q = inv(S);
    
    % TRANSFORMATION 
    th = theta(k)*pi/180;
    m = cos(th); n_ = sin(th);
    
    T1 = [m^2 n_^2 2*m*n_;
          n_^2 m^2 -2*m*n_;
         -m*n_ m*n_ m^2-n_^2];
    
    T2 = [m^2 n_^2 m*n_;
          n_^2 m^2 -m*n_;
         -2*m*n_ 2*m*n_ m^2-n_^2];
    
    Qbar = inv(T1)*Q*T2;
    
    Qbar_all{k} = Qbar;
    T1_all{k} = T1;
    T2_all{k} = T2;
    
    zk = z(k+1); zk_1 = z(k);
    
    A = A + Qbar*(zk - zk_1);
    B = B + 0.5*Qbar*(zk^2 - zk_1^2);
    D = D + (1/3)*Qbar*(zk^3 - zk_1^3);
end

ABD = [A B; B D];

%% PRINT MATRICES

fprintf('\n===== A MATRIX =====\n'); disp(A);
fprintf('===== B MATRIX =====\n'); disp(B);
fprintf('===== D MATRIX =====\n'); disp(D);

%% STRAIN & CURVATURE 

strain_curv = ABD \ NM;
eps0 = strain_curv(1:3);
kappa = strain_curv(4:6);

fprintf('\n===== MID-PLANE STRAIN =====\n');
fprintf('%e  %e  %e\n', eps0);

fprintf('\n===== CURVATURE =====\n');
fprintf('%e  %e  %e\n', kappa);

%% TABLE FORMAT OUTPUT

pos = {'Top','Middle','Bottom'};

fprintf('\n===== GLOBAL STRAINS =====\n');
fprintf('Ply\tPos\t\tex\t\tey\t\tgxy\n');

for k = 1:n
    z_points = [z(k), (z(k)+z(k+1))/2, z(k+1)];
    for j = 1:3
        strain = eps0 + z_points(j)*kappa;
        fprintf('%d\t%s\t%e\t%e\t%e\n', k, pos{j}, strain);
    end
end

fprintf('\n===== GLOBAL STRESSES =====\n');
fprintf('Ply\tPos\t\tsx\t\tsy\t\ttxy\n');

for k = 1:n
    Qbar = Qbar_all{k};
    z_points = [z(k), (z(k)+z(k+1))/2, z(k+1)];
    for j = 1:3
        strain = eps0 + z_points(j)*kappa;
        stress = Qbar * strain;
        fprintf('%d\t%s\t%e\t%e\t%e\n', k, pos{j}, stress);
    end
end

fprintf('\n===== LOCAL STRAINS =====\n');
fprintf('Ply\tPos\t\te1\t\te2\t\tg12\n');

for k = 1:n
    T2 = T2_all{k};
    z_points = [z(k), (z(k)+z(k+1))/2, z(k+1)];
    for j = 1:3
        strain_g = eps0 + z_points(j)*kappa;
        strain_l = T2 * strain_g;
        fprintf('%d\t%s\t%e\t%e\t%e\n', k, pos{j}, strain_l);
    end
end

fprintf('\n===== LOCAL STRESSES =====\n');
fprintf('Ply\tPos\t\ts1\t\ts2\t\tt12\n');

for k = 1:n
    T1 = T1_all{k}; Qbar = Qbar_all{k};
    z_points = [z(k), (z(k)+z(k+1))/2, z(k+1)];
    for j = 1:3
        strain_g = eps0 + z_points(j)*kappa;
        stress_g = Qbar * strain_g;
        stress_l = T1 * stress_g;
        fprintf('%d\t%s\t%e\t%e\t%e\n', k, pos{j}, stress_l);
    end
end

%% LOAD SHARING 

fprintf('\n===== LOAD SHARING (Nx) =====\n');

Nx_ply = zeros(1,n);

for k = 1:n
    
    z_mid = (z(k)+z(k+1))/2;
    strain_mid = eps0 + z_mid*kappa;
    
    stress_mid = Qbar_all{k} * strain_mid;
    
    Nx_ply(k) = stress_mid(1) * t(k);
    
    fprintf('Ply %d (%.0f deg): %e N/m\n', k, theta(k), Nx_ply(k));
end

fprintf('\n===== LOAD PERCENTAGE =====\n');

for k = 1:n
    fprintf('Ply %d: %.2f %%\n', k, (Nx_ply(k)/Nx)*100);
end

%% EXTRA INFO

if norm(B) < 1e-6
    fprintf('\nLaminate is SYMMETRIC (B ≈ 0)\n');
else
    fprintf('\nLaminate is UNSYMMETRIC (B ≠ 0)\n');
end