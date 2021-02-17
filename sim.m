%% Housekeeping

clear;
close all;

%% Real-World Model Parameters

% Load Original Audio
mp3_fname = "./signals/coffee_short.mp3";
[raw_sig, fs_original] = audioread(mp3_fname);

% Echo Parameters
echo_taps = 128;
echo_loss_db = 20; % voltage dB

% Basic Testing Filter Parameters
sys_taps = 128;
sys_gain_db = 10; % voltage dB
sys_delay = 10; % 10 tap delay FIR

% Processing "Delay" Filter
proc_delay = 10;

% Adaptive Filter Taps
p = 128;

% NLMS Parameters
nlms_mu = 1e-5;
nlms_eps = 1e-15;

%% System Parameters 

% System Sampling Frequency
fs = 8e3; % system @ 8kHz

%% Pre-Processing

% Get Sampling Period
Ts = 1/fs;

% Generate Echo and Plot
[h_echo, b_echo, a_echo] = genRandomEcho(echo_taps, echo_loss_db);
freqz(b_echo, a_echo, 2000);

% Generate System Filter
h_sys = db2mag(sys_gain_db).*[zeros(sys_delay, 1); ...
    1; zeros(sys_taps - 1 - sys_delay)];

% Generate Processing "Delay" Filter
h_delay = [zeros(proc_delay, 1); 1];

% Resample Signal
sig = resample(raw_sig, fs, fs_original);

%% System Simulation Without Echo

out_noecho = filter(conv(h_sys, h_delay), 1, sig);

%% System Simulation Without Echo Cancellation

out_nocanc = zeros(numel(sig), 1);
in_nocanc = zeros(numel(sig), 1);
y_win_nocanc = zeros(p, 1);
e_win_nocanc = zeros(p, 1);

h_echo_delay = conv(h_echo, h_delay);
h_echo_delay = h_echo_delay(1:p);

for k=1:numel(sig)
    if mod(k, 10000) == 0
        fprintf("No Canc....[%d/%d]\n", k, numel(sig));
    end
    
    if k - prod_delay >= 1
        a_k = sig(k-td);
    else
        a_k = 0;
    end
    
    % x_k = sample received from microphone at start of
    % adaptive filter
    x_k = a_k + h_echo_delay.' * y_win_nocanc;
    
    % e_k = output of adaptive filter
    e_k = x_k;
    e_win_nocanc = [e_k; e_win_nocanc(1:end-1, :)];
    in_nocanc(k) = y_k;
    
    % apply system filter
    y_k = h_sys.' * e_win_nocanc;
    out_nocanc(k) = y_k;
    y_win_nocanc = [y_k; y_win_nocanc(1:end-1, :)];

end


%% System Simulation With Echo Cancellation

out_canc = zeros(numel(sig), 1);
in_canc = zeros(numel(sig), 1);
pre_canc = zeros(numel(sig), 1);

y_win_canc = zeros(p, 1);
e_win_canc = zeros(p, 1);

lms_fir = zeros(p, 1);
lms_fir_hist = zeros(p, numel(sig));

h_echo_delay = conv(h_echo, h_delay);
h_echo_delay = h_echo_delay(1:p);

for k=1:numel(sig)
    if mod(k, 10000) == 0
        fprintf("LMS....[%d/%d]\n", k, numel(sig));
    end
    
    if k - prod_delay >= 1
        a_k = sig(k-td);
    else
        a_k = 0;
    end
    
    % x_k = sample received from microphone at start of
    % adaptive filter
    x_k = a_k + h_echo_delay.' * y_win_canc;
    pre_canc(k) = x_k;
    
    % e_k = output of adaptive filter
    lms_fir_hist(:, k) = lms_fir;
    e_k = x_k - y_win_canc.' * lms_fir;
    
    % Update LMS Filter based on e_k
    lms_fir = lms_fir - nlms_mu .* conj(e_k) ...
        .*  y_win_canc / (nlms_eps + y_win'*y_win);
    lms_fir(1) = 0;
    
    e_win_nocanc = [e_k; e_win_nocanc(1:end-1, :)];
    in_nocanc(k) = y_k;
    
    % apply system filter
    y_k = h_sys.' * e_win_nocanc;
    out_nocanc(k) = y_k;
    y_win_nocanc = [y_k; y_win_nocanc(1:end-1, :)];
    
end








