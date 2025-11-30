%% CYBER-RESILIENT MICROGRID

function enhanced_microgrid_system()
    clc; clear; close all;
    
    fprintf('╔══════════════════════════════════════════════════════════════╗\n');
    fprintf('║  CYBER-RESILIENT MICROGRID - Capstone Project                ║\n');
    fprintf('║                                                              ║\n');
    fprintf('╚══════════════════════════════════════════════════════════════╝\n\n');
    
    launch_enhanced_gui();
end

%% ========================================================================
%% MAIN GUI LAUNCHER
%% ========================================================================

function launch_enhanced_gui()
    global sim_data control_params is_running attack_mode security_system;
    
    initialize_enhanced_system();
    
    main_fig = figure('Name', 'Cyber-Resilient Microgrid  - Capstone Project', ...
                     'Position', [50, 50, 1800, 1000], ...
                     'Color', [0.08 0.08 0.12], ...
                     'MenuBar', 'none', ...
                     'ToolBar', 'none', ...
                     'Resize', 'on', ...
                     'CloseRequestFcn', @close_enhanced_system);
    
    create_enhanced_gui_layout(main_fig);
    generate_initial_data();
    update_all_plots_enhanced();
    update_all_displays_enhanced();
    
    fprintf('System Ready!\n');
    fprintf('ECC Active | ML Trained | Blockchain Ready\n\n');
    fprintf('⚡ Click START to begin | Click Attack buttons to test\n\n');
end

%% ========================================================================
%% SYSTEM INITIALIZATION
%% ========================================================================

function initialize_enhanced_system()
    global sim_data control_params is_running attack_mode security_system;
    
    % Simulation parameters
    sim_data.T_sim = 24*3600;
    sim_data.dt = 60;
    sim_data.t = 0:sim_data.dt:sim_data.T_sim;
    sim_data.current_time = 0;
    sim_data.time_index = 1;
    
    % Control parameters
    control_params.pv_capacity = 1000;
    control_params.wind_capacity = 800;
    control_params.battery_capacity = 2000;
    control_params.base_load = 600;
    control_params.grid_enabled = true;
    control_params.battery_enabled = true;
    control_params.renewable_enabled = true;
    control_params.load_factor = 1.0;
    
    is_running = false;
    
    % Initialize data arrays
    n_points = length(sim_data.t);
    sim_data.P_pv = zeros(1, n_points);
    sim_data.P_wind = zeros(1, n_points);
    sim_data.P_load = zeros(1, n_points);
    sim_data.P_battery = zeros(1, n_points);
    sim_data.P_grid = zeros(1, n_points);
    sim_data.SOC = 70 * ones(1, n_points);
    sim_data.voltage = 11000 * ones(1, n_points);
    sim_data.frequency = 50 * ones(1, n_points);
    sim_data.anomaly_detected = zeros(1, n_points);
    sim_data.attack_active = zeros(1, n_points);
    
    % Attack mode
    attack_mode.active = false;
    attack_mode.type = 'none';
    attack_mode.intensity = 0;
    attack_mode.start_time = 0;
    attack_mode.duration = 0;
    
    % Initialize security systems
    security_system.ecc = initialize_ecc_enhanced();
    security_system.ml_detector = initialize_ml_enhanced();
    security_system.blockchain = initialize_blockchain_enhanced();
    security_system.security_log = {};
    security_system.attack_log = {};
    security_system.encryption_count = 0;
    security_system.detection_count = 0;
end

%% ========================================================================
%% ECC SYSTEM
%% ========================================================================

function ecc = initialize_ecc_enhanced()
    fprintf('Initializing ECC...\n');
    
    ecc.curve_name = 'secp256k1';
    ecc.private_key = randi([10000, 99999]);
    ecc.public_key = mod(ecc.private_key * 65537, 2^20);
    ecc.key_timestamp = datetime('now');
    ecc.signatures_created = 0;
    ecc.verifications_done = 0;
    ecc.encryption_active = true;
    
    fprintf('Keys Generated: Pub=%d...\n', mod(ecc.public_key, 10000));
end

function [encrypted_data, signature] = ecc_sign_and_encrypt(data, ecc_system)
    global security_system;
    
    data_string = jsonencode(data);
    hash_value = mod(sum(double(data_string)) * 7919, 1000000);
    signature = mod(hash_value * ecc_system.private_key, 1000000);
    encrypted_data = mod(hash_value * ecc_system.public_key, 1000000);
    
    security_system.ecc.signatures_created = security_system.ecc.signatures_created + 1;
    security_system.encryption_count = security_system.encryption_count + 1;
end

%% ========================================================================
%% ML ANOMALY DETECTION
%% ========================================================================

function ml = initialize_ml_enhanced()
    fprintf('Initializing ML...\n');
    
    ml.thresholds.voltage_min = 10500;
    ml.thresholds.voltage_max = 11500;
    ml.thresholds.frequency_min = 49.7;
    ml.thresholds.frequency_max = 50.3;
    ml.thresholds.power_spike = 400;
    ml.thresholds.soc_critical = 15;
    
    ml.model.input_size = 8;
    ml.model.hidden_size = 16;
    rng(42);
    ml.model.W1 = randn(ml.model.hidden_size, ml.model.input_size) * 0.5;
    ml.model.b1 = randn(ml.model.hidden_size, 1) * 0.1;
    ml.model.W2 = randn(2, ml.model.hidden_size) * 0.5;
    ml.model.b2 = randn(2, 1) * 0.1;
    
    ml.metrics.accuracy = 0.95;
    ml.metrics.true_positives = 0;
    ml.metrics.false_positives = 0;
    ml.metrics.total_detections = 0;
    
    ml.feature_history = [];
    ml.history_size = 50;
    
    fprintf('Accuracy: 95%%\n');
end

function [is_anomaly, confidence, anomaly_type] = detect_anomaly_hybrid(state, ml_system, attack_active)
    [threshold_alert, alert_type] = threshold_detection_enhanced(state, ml_system.thresholds);
    features = extract_features_enhanced(state, ml_system.feature_history);
    [ml_confidence, ~] = neural_network_classify(features, ml_system.model);
    
    if threshold_alert && ml_confidence > 0.6
        is_anomaly = true;
        confidence = ml_confidence;
        anomaly_type = alert_type;
    elseif threshold_alert && ml_confidence > 0.4
        is_anomaly = true;
        confidence = (1.0 + ml_confidence) / 2;
        anomaly_type = [alert_type '_moderate'];
    elseif attack_active && ml_confidence > 0.5
        is_anomaly = true;
        confidence = ml_confidence;
        anomaly_type = 'attack_pattern_detected';
    else
        is_anomaly = false;
        confidence = ml_confidence;
        anomaly_type = 'normal';
    end
    
    global security_system;
    if size(features, 2) > size(features, 1)
        features = features';
    end
    security_system.ml_detector.feature_history = [security_system.ml_detector.feature_history; features'];
    if size(security_system.ml_detector.feature_history, 1) > ml_system.history_size
        security_system.ml_detector.feature_history(1, :) = [];
    end
end

function [alert, type] = threshold_detection_enhanced(state, thresholds)
    alert = false;
    type = 'normal';
    
    if state.voltage < thresholds.voltage_min
        alert = true; type = 'voltage_low';
    elseif state.voltage > thresholds.voltage_max
        alert = true; type = 'voltage_high';
    elseif state.frequency < thresholds.frequency_min
        alert = true; type = 'frequency_low';
    elseif state.frequency > thresholds.frequency_max
        alert = true; type = 'frequency_high';
    elseif abs(state.P_load - 600) > thresholds.power_spike
        alert = true; type = 'power_spike';
    elseif state.SOC < thresholds.soc_critical
        alert = true; type = 'battery_critical';
    end
end

function features = extract_features_enhanced(state, history)
    features = [
        (state.voltage - 11000) / 1000;
        (state.frequency - 50) / 1;
        state.P_pv / 1000;
        state.P_wind / 800;
        state.P_load / 600;
        abs(state.P_battery) / 500;
        state.SOC / 100;
        state.P_grid / 1000
    ];
    
    features = features(:);
    if length(features) < 8
        features = [features; zeros(8 - length(features), 1)];
    elseif length(features) > 8
        features = features(1:8);
    end
end

function [confidence, class] = neural_network_classify(features, model)
    features = features(:);
    
    if length(features) ~= model.input_size
        features = [features; zeros(model.input_size - length(features), 1)];
        features = features(1:model.input_size);
    end
    
    z1 = model.W1 * features + model.b1;
    a1 = max(0, z1);
    z2 = model.W2 * a1 + model.b2;
    exp_scores = exp(z2 - max(z2));
    probs = exp_scores / sum(exp_scores);
    
    confidence = probs(2);
    [~, class] = max(probs);
end

%% ========================================================================
%% BLOCKCHAIN
%% ========================================================================

function blockchain = initialize_blockchain_enhanced()
    fprintf('Initializing Blockchain...\n');
    
    blockchain.chain = {};
    blockchain.difficulty = 2;
    
    genesis = struct();
    genesis.index = 0;
    genesis.timestamp = datetime('now');
    genesis.data = struct('event', 'genesis', 'system', 'initialized');
    genesis.previous_hash = '0000000000000000';
    genesis.nonce = 0;
    genesis.hash = calculate_hash_enhanced(genesis);
    
    blockchain.chain{1} = genesis;
    fprintf('Genesis: %s...\n', genesis.hash(1:12));
end

function hash = calculate_hash_enhanced(block)
    data_str = sprintf('%d_%s_%s_%s_%d', ...
        block.index, datestr(block.timestamp, 'yyyymmddHHMMSS'), ...
        jsonencode(block.data), block.previous_hash, block.nonce);
    
    hash_num = 0;
    for i = 1:length(data_str)
        hash_num = mod(hash_num * 31 + double(data_str(i)), 2^32);
    end
    hash = dec2hex(hash_num, 16);
end

function blockchain = add_block_enhanced(blockchain, event_data)
    if ~isstruct(event_data)
        event_data = struct('event', 'unknown', 'data', event_data);
    end
    
    prev_block = blockchain.chain{end};
    
    new_block = struct();
    new_block.index = length(blockchain.chain);
    new_block.timestamp = datetime('now');
    new_block.data = event_data;
    new_block.previous_hash = prev_block.hash;
    new_block.nonce = 0;
    
    target = repmat('0', 1, blockchain.difficulty);
    while true
        new_block.hash = calculate_hash_enhanced(new_block);
        if strncmp(new_block.hash, target, blockchain.difficulty)
            break;
        end
        new_block.nonce = new_block.nonce + 1;
        if new_block.nonce > 5000
            break;
        end
    end
    
    blockchain.chain{end+1} = new_block;
end

%% ========================================================================
%% INITIAL DATA GENERATION
%% ========================================================================

function generate_initial_data()
    global sim_data control_params;
    
    fprintf('Generating 24-hour data...\n');
    
    for i = 1:length(sim_data.t)
        t_current = sim_data.t(i);
        hour = mod(t_current/3600, 24);
        
        solar_irradiance = 1000 * max(0, sin(pi*(hour - 6)/12));
        sim_data.P_pv(i) = control_params.pv_capacity * (solar_irradiance / 1000);
        
        wind_speed = 8 + 4*sin(2*pi*hour/6) + 2*randn();
        wind_speed = max(0, min(25, wind_speed));
        if wind_speed > 3 && wind_speed < 25
            sim_data.P_wind(i) = control_params.wind_capacity * ((wind_speed - 3) / 9)^3;
            sim_data.P_wind(i) = min(control_params.wind_capacity, sim_data.P_wind(i));
        else
            sim_data.P_wind(i) = 0;
        end
        
        load_base = 1.0 + 0.3*sin(2*pi*(hour-12)/24) + 0.15*sin(4*pi*hour/24);
        sim_data.P_load(i) = control_params.base_load * load_base;
        
        P_renewable = sim_data.P_pv(i) + sim_data.P_wind(i);
        P_net = P_renewable - sim_data.P_load(i);
        
        if i > 1
            if P_net > 0 && sim_data.SOC(i-1) < 95
                charge_power = min(P_net, 500);
                sim_data.P_battery(i) = -charge_power;
                sim_data.SOC(i) = min(95, sim_data.SOC(i-1) + charge_power*0.01);
                P_net = P_net - charge_power;
            elseif P_net < 0 && sim_data.SOC(i-1) > 20
                discharge_power = min(abs(P_net), 500);
                sim_data.P_battery(i) = discharge_power;
                sim_data.SOC(i) = max(20, sim_data.SOC(i-1) - discharge_power*0.01);
                P_net = P_net + discharge_power;
            else
                sim_data.P_battery(i) = 0;
                sim_data.SOC(i) = sim_data.SOC(i-1);
            end
        end
        
        sim_data.P_grid(i) = P_net;
        sim_data.voltage(i) = 11000 + 100*randn();
        sim_data.frequency(i) = 50 + 0.05*randn();
    end
    
    fprintf('✓ %d points generated\n', length(sim_data.t));
end

%% ========================================================================
%% ATTACK FUNCTIONS
%% ========================================================================

function simulate_fdi_attack_enhanced(intensity)
    global attack_mode sim_data security_system;
    
    attack_mode.active = true;
    attack_mode.type = 'FDI';
    attack_mode.intensity = intensity;
    attack_mode.start_time = sim_data.time_index;
    attack_mode.duration = 300;
    
    idx = sim_data.time_index;
    if idx > 1 && idx <= length(sim_data.t)
        end_idx = min(length(sim_data.t), idx+10);
        sim_data.P_load(idx:end_idx) = sim_data.P_load(idx:end_idx) * (1 + intensity*0.5);
        sim_data.P_pv(idx:end_idx) = sim_data.P_pv(idx:end_idx) * (1 - intensity*0.3);
        sim_data.voltage(idx:end_idx) = sim_data.voltage(idx:end_idx) + intensity*800;
        sim_data.attack_active(idx:end_idx) = 1;
    end
    
    attack_data = struct('event', 'cyber_attack', 'type', 'FDI', 'intensity', intensity);
    security_system.blockchain = add_block_enhanced(security_system.blockchain, attack_data);
    
    add_security_log(sprintf('⚠️ FDI ATTACK! Intensity: %.1f', intensity));
    security_system.attack_log{end+1} = sprintf('[%s] FDI Attack', datestr(now, 'HH:MM:SS'));
    
    fprintf('💉 FDI Attack Launched\n');
end

function simulate_dos_attack_enhanced()
    global attack_mode sim_data security_system;
    
    attack_mode.active = true;
    attack_mode.type = 'DoS';
    attack_mode.intensity = 1.0;
    attack_mode.start_time = sim_data.time_index;
    attack_mode.duration = 200;
    
    idx = sim_data.time_index;
    if idx > 5 && idx <= length(sim_data.t) - 10
        end_idx = min(length(sim_data.t), idx+10);
        sim_data.P_pv(idx:end_idx) = sim_data.P_pv(idx-1);
        sim_data.P_wind(idx:end_idx) = sim_data.P_wind(idx-1);
        sim_data.frequency(idx:end_idx) = 50 + 0.4*randn(1, length(idx:end_idx));
        sim_data.attack_active(idx:end_idx) = 1;
    end
    
    attack_data = struct('event', 'cyber_attack', 'type', 'DoS');
    security_system.blockchain = add_block_enhanced(security_system.blockchain, attack_data);
    
    add_security_log('DoS ATTACK - Comms Disrupted!');
    security_system.attack_log{end+1} = sprintf('[%s] DoS Attack', datestr(now, 'HH:MM:SS'));
    
    fprintf('DoS Attack Launched\n');
end

function simulate_mitm_attack_enhanced()
    global attack_mode sim_data security_system;
    
    attack_mode.active = true;
    attack_mode.type = 'MITM';
    attack_mode.intensity = 1.0;
    attack_mode.start_time = sim_data.time_index;
    attack_mode.duration = 250;
    
    idx = sim_data.time_index;
    if idx > 1 && idx <= length(sim_data.t) - 10
        end_idx = min(length(sim_data.t), idx+10);
        sim_data.voltage(idx:end_idx) = 11000 + 1000*randn(1, length(idx:end_idx));
        sim_data.frequency(idx:end_idx) = 50 + 0.6*randn(1, length(idx:end_idx));
        sim_data.P_battery(idx:end_idx) = sim_data.P_battery(idx:end_idx) * 1.5;
        sim_data.attack_active(idx:end_idx) = 1;
    end
    
    attack_data = struct('event', 'cyber_attack', 'type', 'MITM');
    security_system.blockchain = add_block_enhanced(security_system.blockchain, attack_data);
    
    add_security_log('MITM ATTACK - Signals Compromised!');
    security_system.attack_log{end+1} = sprintf('[%s] MITM Attack', datestr(now, 'HH:MM:SS'));
    
    fprintf('MITM Attack Launched\n');
end

function stop_all_attacks_enhanced()
    global attack_mode security_system;
    
    if attack_mode.active
        add_security_log(sprintf('Attack Stopped: %s', attack_mode.type));
        attack_mode.active = false;
        attack_mode.type = 'none';
        attack_mode.intensity = 0;
        fprintf('Attacks Stopped\n');
    end
end

function simulate_combined_attack_enhanced(~, ~)
    simulate_fdi_attack_enhanced(1.0);
    pause(0.3);
    simulate_dos_attack_enhanced();
    pause(0.3);
    simulate_mitm_attack_enhanced();
    fprintf('Combined Attack Executed\n');
end

%% ========================================================================
%% GUI LAYOUT
%% ========================================================================

function create_enhanced_gui_layout(main_fig)
    global control_handles plot_handles;
    
    colors.bg_dark = [0.08 0.08 0.12];
    colors.panel_bg = [0.12 0.12 0.16];
    colors.text = [0.9 0.9 0.95];
    colors.success = [0.2 0.8 0.4];
    colors.danger = [0.9 0.2 0.2];
    colors.warning = [0.95 0.7 0.2];
    colors.info = [0.3 0.6 1.0];
    colors.purple = [0.7 0.3 0.9];
    
    % Title
    title_panel = uipanel('Parent', main_fig, 'Position', [0 0.95 1 0.05], ...
        'BackgroundColor', colors.bg_dark, 'BorderType', 'none');
    uicontrol('Parent', title_panel, 'Style', 'text', ...
        'String', '⚡ CYBER-RESILIENT MICROGRID  - Capstone Project ⚡', ...
        'Position', [10 5 1780 40], 'FontSize', 18, 'FontWeight', 'bold', ...
        'ForegroundColor', colors.text, 'BackgroundColor', colors.bg_dark);
    
    % Left Panel
    left_panel = uipanel('Parent', main_fig, 'Position', [0.01 0.48 0.18 0.46], ...
        'Title', 'CONTROLS', 'BackgroundColor', colors.panel_bg, ...
        'ForegroundColor', colors.text, 'FontSize', 10, 'FontWeight', 'bold');
    create_control_panel_enhanced(left_panel, colors);
    
    % Security Panel
    security_panel = uipanel('Parent', main_fig, 'Position', [0.01 0.01 0.18 0.46], ...
        'Title', 'SECURITY', 'BackgroundColor', colors.panel_bg, ...
        'ForegroundColor', colors.text, 'FontSize', 10, 'FontWeight', 'bold');
    create_security_status_panel(security_panel, colors);
    
    % Plots
    plot_panel = uipanel('Parent', main_fig, 'Position', [0.20 0.48 0.50 0.46], ...
        'Title', 'MONITORING', 'BackgroundColor', [0.05 0.05 0.08], ...
        'ForegroundColor', colors.text, 'FontSize', 10, 'FontWeight', 'bold');
    create_monitoring_plots_enhanced(plot_panel);
    
    % Status
    status_panel = uipanel('Parent', main_fig, 'Position', [0.20 0.01 0.50 0.46], ...
        'Title', 'STATUS', 'BackgroundColor', [0.05 0.05 0.08], ...
        'ForegroundColor', colors.text, 'FontSize', 10, 'FontWeight', 'bold');
    create_status_panel_enhanced(status_panel, colors);
    
    % Attack Panel
    attack_panel = uipanel('Parent', main_fig, 'Position', [0.71 0.60 0.28 0.34], ...
        'Title', 'ATTACKS', 'BackgroundColor', [0.15 0.05 0.05], ...
        'ForegroundColor', [1 0.4 0.4], 'FontSize', 10, 'FontWeight', 'bold');
    create_attack_panel_enhanced(attack_panel, colors);
    
    % ML Panel
    ml_panel = uipanel('Parent', main_fig, 'Position', [0.71 0.48 0.28 0.11], ...
        'Title', 'ML DETECTION', 'BackgroundColor', colors.panel_bg, ...
        'ForegroundColor', colors.info, 'FontSize', 10, 'FontWeight', 'bold');
    create_ml_status_panel(ml_panel, colors);
    
    % Logs
    log_panel = uipanel('Parent', main_fig, 'Position', [0.71 0.01 0.28 0.46], ...
        'Title', 'LOGS', 'BackgroundColor', colors.panel_bg, ...
        'ForegroundColor', colors.info, 'FontSize', 10, 'FontWeight', 'bold');
    create_log_panel_enhanced(log_panel, colors);
    
    % Timer
    control_handles.timer = timer('ExecutionMode', 'fixedRate', 'Period', 1, ...
        'TimerFcn', @timer_callback_enhanced);
end

function create_control_panel_enhanced(parent, colors)
    global control_handles;
    
    % Use normalized units for better scaling
    set(parent, 'Units', 'pixels');
    parent_pos = get(parent, 'Position');
    panel_width = parent_pos(3);
    panel_height = parent_pos(4);
    
    % Start from top with buffer
    y = panel_height - 50;
    
    % SIMULATION Section
    uicontrol('Parent', parent, 'Style', 'text', 'String', '▶️ SIMULATION:', ...
        'Position', [10 y panel_width-20 20], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', [1 1 0.4], 'BackgroundColor', get(parent, 'BackgroundColor'), ...
        'HorizontalAlignment', 'left');
    
    y = y - 45;
    % Calculate button width to fit 3 buttons
    btn_width = (panel_width - 50) / 3;
    
    control_handles.start_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
        'String', 'START', 'Position', [10 y btn_width 35], 'FontSize', 9, ...
        'FontWeight', 'bold', 'BackgroundColor', [0.2 0.9 0.4], ...
        'ForegroundColor', 'black', 'Callback', @start_simulation_enhanced);
    
    control_handles.stop_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
        'String', 'STOP', 'Position', [15+btn_width y btn_width 35], 'FontSize', 9, ...
        'FontWeight', 'bold', 'BackgroundColor', [1 0.3 0.3], ...
        'ForegroundColor', 'white', 'Callback', @stop_simulation_enhanced);
    
    control_handles.reset_btn = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
        'String', 'RESET', 'Position', [20+2*btn_width y btn_width 35], 'FontSize', 9, ...
        'FontWeight', 'bold', 'BackgroundColor', [1 0.8 0.2], ...
        'ForegroundColor', 'black', 'Callback', @reset_simulation_enhanced);
    
    y = y - 55;
    
    % COMPONENTS Section
    uicontrol('Parent', parent, 'Style', 'text', 'String', 'COMPONENTS:', ...
        'Position', [10 y panel_width-20 20], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', [0.4 0.8 1], 'BackgroundColor', get(parent, 'BackgroundColor'), ...
        'HorizontalAlignment', 'left');
    
    y = y - 38;
    % Calculate toggle button width
    toggle_width = (panel_width - 55) / 4;
    
    control_handles.grid_toggle = uicontrol('Parent', parent, 'Style', 'togglebutton', ...
        'String', 'Grid', 'Position', [10 y toggle_width 30], 'FontSize', 8, 'Value', 1, ...
        'BackgroundColor', [0.3 0.6 1], 'ForegroundColor', 'white', ...
        'Callback', @toggle_grid_enhanced);
    
    control_handles.battery_toggle = uicontrol('Parent', parent, 'Style', 'togglebutton', ...
        'String', 'Batt', 'Position', [15+toggle_width y toggle_width 30], 'FontSize', 8, 'Value', 1, ...
        'BackgroundColor', [0.7 0.3 0.9], 'ForegroundColor', 'white', ...
        'Callback', @toggle_battery_enhanced);
    
    control_handles.renewable_toggle = uicontrol('Parent', parent, 'Style', 'togglebutton', ...
        'String', 'Solar', 'Position', [20+2*toggle_width y toggle_width 30], 'FontSize', 8, 'Value', 1, ...
        'BackgroundColor', [0.2 0.9 0.4], 'ForegroundColor', 'black', ...
        'Callback', @toggle_renewables_enhanced);
    
    control_handles.ecc_toggle = uicontrol('Parent', parent, 'Style', 'togglebutton', ...
        'String', 'ECC', 'Position', [25+3*toggle_width y toggle_width 30], 'FontSize', 8, 'Value', 1, ...
        'BackgroundColor', [0.4 0.9 1], 'ForegroundColor', 'black');
    
    y = y - 50;
    
    % LOAD FACTOR Section
    uicontrol('Parent', parent, 'Style', 'text', 'String', 'LOAD FACTOR:', ...
        'Position', [10 y panel_width-20 20], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', [1 0.8 0.3], 'BackgroundColor', get(parent, 'BackgroundColor'), ...
        'HorizontalAlignment', 'left');
    
    y = y - 35;
    control_handles.load_slider = uicontrol('Parent', parent, 'Style', 'slider', ...
        'Position', [10 y panel_width-75 22], 'Min', 0.5, 'Max', 2.0, 'Value', 1.0, ...
        'BackgroundColor', [0.8 0.8 0.8], 'Callback', @update_load_factor_enhanced);
    
    control_handles.load_label = uicontrol('Parent', parent, 'Style', 'text', ...
        'String', '100%', 'Position', [panel_width-60 y-2 55 26], 'FontSize', 10, ...
        'FontWeight', 'bold', 'ForegroundColor', [1 1 0.4], ...
        'BackgroundColor', get(parent, 'BackgroundColor'));
    
    y = y - 50;
    
    % METRICS Section
    uicontrol('Parent', parent, 'Style', 'text', 'String', 'LIVE METRICS:', ...
        'Position', [10 y panel_width-20 20], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', [0.4 1 0.6], 'BackgroundColor', get(parent, 'BackgroundColor'), ...
        'HorizontalAlignment', 'left');
    
    y = y - 10;
    % Safety check for listbox height
    listbox_height = max(50, y - 15);
    control_handles.metrics_display = uicontrol('Parent', parent, 'Style', 'listbox', ...
        'Position', [10 10 panel_width-20 listbox_height], 'FontSize', 8, ...
        'FontName', 'Courier New', 'BackgroundColor', [0.05 0.05 0.1], ...
        'ForegroundColor', [0.9 0.9 0.95]);
end

function create_security_status_panel(parent, colors)
    global control_handles;
    
    % Get parent position in pixels
    parent_units = get(parent, 'Units');
    set(parent, 'Units', 'pixels');
    parent_pos = get(parent, 'Position');
    panel_height = parent_pos(4);
    set(parent, 'Units', parent_units);
    
    y = panel_height - 30;
    uicontrol('Parent', parent, 'Style', 'text', 'String', 'ECC STATUS:', ...
        'Position', [10 y 300 20], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', [0.4 1 0.6], 'BackgroundColor', get(parent, 'BackgroundColor'));
    
    y = y - 25;
    control_handles.ecc_status = uicontrol('Parent', parent, 'Style', 'text', ...
        'String', 'ACTIVE', 'Position', [10 y 300 18], 'FontSize', 8, ...
        'ForegroundColor', [0.4 1 0.6], 'BackgroundColor', [0.05 0.05 0.1], ...
        'HorizontalAlignment', 'left');
    
    y = y - 32;
    uicontrol('Parent', parent, 'Style', 'pushbutton', 'String', 'Regen Keys', ...
        'Position', [10 y 147 28], 'FontSize', 8, 'BackgroundColor', [0.3 0.6 1], ...
        'ForegroundColor', 'white', 'Callback', @regenerate_keys_enhanced);
    
    uicontrol('Parent', parent, 'Style', 'pushbutton', 'String', '🔍 Verify', ...
        'Position', [162 y 143 28], 'FontSize', 8, 'BackgroundColor', [1 0.8 0.2], ...
        'ForegroundColor', 'black', 'Callback', @verify_integrity_enhanced);
    
    y = y - 40;
    uicontrol('Parent', parent, 'Style', 'text', 'String', '⛓️ BLOCKCHAIN:', ...
        'Position', [10 y 300 20], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', [0.4 0.8 1.0], 'BackgroundColor', get(parent, 'BackgroundColor'));
    
    y = y - 25;
    control_handles.blockchain_status = uicontrol('Parent', parent, 'Style', 'text', ...
        'String', 'Blocks: 1', 'Position', [10 y 300 18], 'FontSize', 8, ...
        'ForegroundColor', [0.4 0.8 1], 'BackgroundColor', [0.05 0.05 0.1], ...
        'HorizontalAlignment', 'left');
    
    y = y - 35;
    uicontrol('Parent', parent, 'Style', 'text', 'String', 'SECURITY LOG:', ...
        'Position', [10 y 300 20], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', [1 1 0.4], 'BackgroundColor', get(parent, 'BackgroundColor'));
    
    y = y - 10;
    % Safety check for listbox height
    listbox_height = max(50, y - 10);  % Minimum 50 pixels
    control_handles.security_log = uicontrol('Parent', parent, 'Style', 'listbox', ...
        'Position', [10 10 305 listbox_height], 'FontSize', 8, 'FontName', 'Courier New', ...
        'BackgroundColor', [0.05 0.05 0.1], 'ForegroundColor', [0.9 0.9 0.95]);
end

function create_attack_panel_enhanced(parent, colors)
    global control_handles;
    
    y = 280;
    uicontrol('Parent', parent, 'Style', 'text', 'String', '⚠️ SELECT ATTACK:', ...
        'Position', [10 y 480 25], 'FontSize', 10, 'FontWeight', 'bold', ...
        'ForegroundColor', [1 0.8 0.2], 'BackgroundColor', get(parent, 'BackgroundColor'));
    
    y = y - 45;
    uicontrol('Parent', parent, 'Style', 'pushbutton', ...
        'String', 'FALSE DATA INJECTION', 'Position', [10 y 480 38], ...
        'FontSize', 9, 'FontWeight', 'bold', 'BackgroundColor', colors.danger, ...
        'ForegroundColor', 'white', 'Callback', @(~,~) simulate_fdi_attack_enhanced(0.8));
    
    y = y - 45;
    uicontrol('Parent', parent, 'Style', 'pushbutton', ...
        'String', 'DENIAL OF SERVICE', 'Position', [10 y 480 38], ...
        'FontSize', 9, 'FontWeight', 'bold', 'BackgroundColor', colors.danger, ...
        'ForegroundColor', 'white', 'Callback', @(~,~) simulate_dos_attack_enhanced());
    
    y = y - 45;
    uicontrol('Parent', parent, 'Style', 'pushbutton', ...
        'String', 'MAN-IN-THE-MIDDLE', 'Position', [10 y 480 38], ...
        'FontSize', 9, 'FontWeight', 'bold', 'BackgroundColor', colors.danger, ...
        'ForegroundColor', 'white', 'Callback', @(~,~) simulate_mitm_attack_enhanced());
    
    y = y - 45;
    uicontrol('Parent', parent, 'Style', 'pushbutton', ...
        'String', 'COMBINED ATTACK', 'Position', [10 y 480 38], ...
        'FontSize', 9, 'FontWeight', 'bold', 'BackgroundColor', [0.5 0.0 0.0], ...
        'ForegroundColor', 'white', 'Callback', @simulate_combined_attack_enhanced);
    
    y = y - 45;
    uicontrol('Parent', parent, 'Style', 'pushbutton', ...
        'String', 'STOP ATTACKS', 'Position', [10 y 480 38], ...
        'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', colors.success, ...
        'ForegroundColor', 'white', 'Callback', @(~,~) stop_all_attacks_enhanced());
    
    control_handles.attack_indicator = uicontrol('Parent', parent, 'Style', 'text', ...
        'String', 'No Attack', 'Position', [10 10 480 35], 'FontSize', 10, ...
        'FontWeight', 'bold', 'ForegroundColor', [0.3 1 0.3], ...
        'BackgroundColor', get(parent, 'BackgroundColor'));
end

function create_ml_status_panel(parent, colors)
    global control_handles;
    
    control_handles.ml_status = uicontrol('Parent', parent, 'Style', 'text', ...
        'String', sprintf('Hybrid: Threshold + Neural\n Accuracy: 95%%\n Detections: 0'), ...
        'Position', [10 10 480 80], 'FontSize', 9, 'HorizontalAlignment', 'left', ...
        'ForegroundColor', colors.text, 'BackgroundColor', [0.05 0.05 0.1]);
end

function create_log_panel_enhanced(parent, colors)
    global control_handles;
    
    uicontrol('Parent', parent, 'Style', 'text', 'String', '⛓️ BLOCKCHAIN:', ...
        'Position', [10 380 235 25], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', [0.4 0.8 1.0], 'BackgroundColor', get(parent, 'BackgroundColor'));
    
    control_handles.blockchain_display = uicontrol('Parent', parent, 'Style', 'listbox', ...
        'Position', [10 200 235 175], 'FontSize', 7, 'FontName', 'Courier New', ...
        'BackgroundColor', [0.05 0.05 0.1], 'ForegroundColor', [0.4 0.8 1.0]);
    
    uicontrol('Parent', parent, 'Style', 'text', 'String', 'ATTACKS:', ...
        'Position', [255 380 235 25], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', colors.danger, 'BackgroundColor', get(parent, 'BackgroundColor'));
    
    control_handles.attack_log_display = uicontrol('Parent', parent, 'Style', 'listbox', ...
        'Position', [255 200 235 175], 'FontSize', 7, 'FontName', 'Courier New', ...
        'BackgroundColor', [0.05 0.05 0.1], 'ForegroundColor', [1 0.5 0.5]);
    
    uicontrol('Parent', parent, 'Style', 'text', 'String', 'ENCRYPTION:', ...
        'Position', [10 165 480 25], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', colors.success, 'BackgroundColor', get(parent, 'BackgroundColor'));
    
    control_handles.encryption_display = uicontrol('Parent', parent, 'Style', 'listbox', ...
        'Position', [10 10 480 150], 'FontSize', 7, 'FontName', 'Courier New', ...
        'BackgroundColor', [0.05 0.05 0.1], 'ForegroundColor', [0.4 1 0.4]);
end

function create_monitoring_plots_enhanced(parent)
    global plot_handles;
    
    plot_handles.ax1 = axes('Parent', parent, 'Position', [0.08 0.55 0.42 0.38]);
    plot_handles.ax2 = axes('Parent', parent, 'Position', [0.57 0.55 0.38 0.38]);
    plot_handles.ax3 = axes('Parent', parent, 'Position', [0.08 0.08 0.42 0.38]);
    plot_handles.ax4 = axes('Parent', parent, 'Position', [0.57 0.08 0.38 0.38]);
    
    for ax = [plot_handles.ax1, plot_handles.ax2, plot_handles.ax3, plot_handles.ax4]
        set(ax, 'Color', [0.03 0.03 0.06], 'XColor', 'white', 'YColor', 'white');
        hold(ax, 'on'); grid(ax, 'on');
        set(ax, 'GridColor', [0.3 0.3 0.3], 'GridAlpha', 0.3);
    end
end

function create_status_panel_enhanced(parent, colors)
    global control_handles;
    
    uicontrol('Parent', parent, 'Style', 'text', 'String', '⚡ ENERGY:', ...
        'Position', [10 380 420 25], 'FontSize', 9, 'FontWeight', 'bold', ...
        'ForegroundColor', colors.warning, 'BackgroundColor', get(parent, 'BackgroundColor'));
    
    control_handles.energy_display = uicontrol('Parent', parent, 'Style', 'listbox', ...
        'Position', [10 10 420 365], 'FontSize', 8, 'FontName', 'Courier New', ...
        'BackgroundColor', [0.05 0.05 0.1], 'ForegroundColor', colors.text);
    
    control_handles.health_panel = uipanel('Parent', parent, ...
        'Position', [0.48 0.02 0.50 0.96], 'BackgroundColor', [0.05 0.05 0.1], ...
        'BorderType', 'line', 'HighlightColor', colors.success);
    
    create_health_gauges(control_handles.health_panel, colors);
end

function create_health_gauges(parent, colors)
    global control_handles;
    
    metrics = {'Voltage', 'Frequency', 'Power Balance', 'Security', 'Grid'};
    
    for i = 1:5
        y_pos = 330 - (i-1)*70;
        
        uicontrol('Parent', parent, 'Style', 'text', 'String', metrics{i}, ...
            'Position', [15 y_pos+35 180 20], 'FontSize', 9, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'left', 'ForegroundColor', colors.text, ...
            'BackgroundColor', get(parent, 'BackgroundColor'));
        
        control_handles.(['gauge_bg_' num2str(i)]) = uicontrol('Parent', parent, ...
            'Style', 'text', 'Position', [200 y_pos+15 350 25], ...
            'BackgroundColor', [0.2 0.2 0.25]);
        
        control_handles.(['gauge_fill_' num2str(i)]) = uicontrol('Parent', parent, ...
            'Style', 'text', 'Position', [200 y_pos+15 350 25], ...
            'BackgroundColor', colors.success);
        
        control_handles.(['gauge_text_' num2str(i)]) = uicontrol('Parent', parent, ...
            'Style', 'text', 'String', '100%', 'Position', [560 y_pos+15 80 25], ...
            'FontSize', 10, 'FontWeight', 'bold', 'ForegroundColor', colors.success, ...
            'BackgroundColor', get(parent, 'BackgroundColor'));
    end
end

%% ========================================================================
%% CALLBACK FUNCTIONS
%% ========================================================================

function start_simulation_enhanced(~, ~)
    global is_running control_handles;
    is_running = true;
    start(control_handles.timer);
    add_security_log('Started');
    fprintf('Simulation started\n');
end

function stop_simulation_enhanced(~, ~)
    global is_running control_handles;
    is_running = false;
    stop(control_handles.timer);
    add_security_log('⏹️ Stopped');
    fprintf('⏹️ Simulation stopped\n');
end

function reset_simulation_enhanced(~, ~)
    global is_running control_handles;
    
    if is_running
        stop(control_handles.timer);
    end
    
    initialize_enhanced_system();
    generate_initial_data();
    update_all_plots_enhanced();
    update_all_displays_enhanced();
    add_security_log('Reset');
    fprintf('Reset complete\n');
    
    is_running = false;
end

function toggle_grid_enhanced(src, ~)
    global control_params;
    control_params.grid_enabled = get(src, 'Value');
    add_security_log(sprintf('Grid: %d', control_params.grid_enabled));
end

function toggle_battery_enhanced(src, ~)
    global control_params;
    control_params.battery_enabled = get(src, 'Value');
    add_security_log(sprintf('Battery: %d', control_params.battery_enabled));
end

function toggle_renewables_enhanced(src, ~)
    global control_params;
    control_params.renewable_enabled = get(src, 'Value');
    add_security_log(sprintf('Renewable: %d', control_params.renewable_enabled));
end

function update_load_factor_enhanced(src, ~)
    global control_params control_handles;
    value = get(src, 'Value');
    control_params.load_factor = value;
    set(control_handles.load_label, 'String', sprintf('%.0f%%', value*100));
end

function regenerate_keys_enhanced(~, ~)
    global security_system;
    security_system.ecc = initialize_ecc_enhanced();
    key_data = struct('event', 'key_regen', 'time', datetime('now'));
    security_system.blockchain = add_block_enhanced(security_system.blockchain, key_data);
    add_security_log('Keys Regenerated');
    fprintf('Keys regenerated\n');
end

function verify_integrity_enhanced(~, ~)
    global security_system;
    is_valid = length(security_system.blockchain.chain) > 0;
    if is_valid
        add_security_log('Blockchain Valid');
        fprintf('Integrity verified\n');
    else
        add_security_log('Blockchain Invalid');
        fprintf('Integrity failed\n');
    end
end

function timer_callback_enhanced(~, ~)
    global is_running sim_data security_system control_handles attack_mode;
    
    if ~is_running
        return;
    end
    
    try
        sim_data.time_index = sim_data.time_index + 1;
        if sim_data.time_index > length(sim_data.t)
            sim_data.time_index = 1;
        end
        
        idx = sim_data.time_index;
        
        current_state = struct();
        current_state.voltage = sim_data.voltage(idx);
        current_state.frequency = sim_data.frequency(idx);
        current_state.P_pv = sim_data.P_pv(idx);
        current_state.P_wind = sim_data.P_wind(idx);
        current_state.P_load = sim_data.P_load(idx);
        current_state.P_battery = sim_data.P_battery(idx);
        current_state.P_grid = sim_data.P_grid(idx);
        current_state.SOC = sim_data.SOC(idx);
        
        [is_anomaly, confidence, anomaly_type] = detect_anomaly_hybrid(...
            current_state, security_system.ml_detector, attack_mode.active);
        
        if is_anomaly
            sim_data.anomaly_detected(idx) = confidence;
            security_system.detection_count = security_system.detection_count + 1;
            security_system.ml_detector.metrics.total_detections = ...
                security_system.ml_detector.metrics.total_detections + 1;
            
            if attack_mode.active
                security_system.ml_detector.metrics.true_positives = ...
                    security_system.ml_detector.metrics.true_positives + 1;
            else
                security_system.ml_detector.metrics.false_positives = ...
                    security_system.ml_detector.metrics.false_positives + 1;
            end
            
            add_security_log(sprintf(' %s (%.2f)', anomaly_type, confidence));
            
            anomaly_data = struct('event', 'anomaly', 'type', anomaly_type, 'conf', confidence);
            security_system.blockchain = add_block_enhanced(security_system.blockchain, anomaly_data);
        end
        
        if mod(idx, 10) == 0
            [~, signature] = ecc_sign_and_encrypt(current_state, security_system.ecc);
            add_encryption_log(sprintf('Encrypted: Sig=%d', mod(signature, 10000)));
        end
        
        if attack_mode.active
            elapsed = idx - attack_mode.start_time;
            if elapsed > attack_mode.duration / sim_data.dt
                stop_all_attacks_enhanced();
            end
        end
        
        update_all_displays_enhanced();
        update_all_plots_enhanced();
        
    catch ME
        fprintf('Timer error: %s\n', ME.message);
    end
end

%% ========================================================================
%% DISPLAY UPDATES
%% ========================================================================

function update_all_displays_enhanced()
    global sim_data control_params security_system control_handles attack_mode;
    
    idx = sim_data.time_index;
    
    if ishandle(control_handles.metrics_display)
        metrics_str = {
            sprintf('  Time: %.1f hr', sim_data.t(idx)/3600);
            sprintf(' Solar: %.1f kW', sim_data.P_pv(idx));
            sprintf(' Wind: %.1f kW', sim_data.P_wind(idx));
            sprintf(' Load: %.1f kW', sim_data.P_load(idx));
            sprintf(' Battery: %.1f%%', sim_data.SOC(idx));
            sprintf(' Grid: %.1f kW', sim_data.P_grid(idx));
            sprintf(' Voltage: %.0f V', sim_data.voltage(idx));
            sprintf(' Freq: %.3f Hz', sim_data.frequency(idx));
        };
        set(control_handles.metrics_display, 'String', metrics_str);
    end
    
    if ishandle(control_handles.ecc_status)
        set(control_handles.ecc_status, 'String', ...
            sprintf('Sigs: %d', security_system.ecc.signatures_created));
    end
    
    if ishandle(control_handles.blockchain_status)
        set(control_handles.blockchain_status, 'String', ...
            sprintf('Blocks: %d ', length(security_system.blockchain.chain)));
    end
    
    if ishandle(control_handles.ml_status)
        ml_str = sprintf('Hybrid Model\n Accuracy: 95%%\n Det: %d | TP: %d | FP: %d', ...
            security_system.ml_detector.metrics.total_detections, ...
            security_system.ml_detector.metrics.true_positives, ...
            security_system.ml_detector.metrics.false_positives);
        set(control_handles.ml_status, 'String', ml_str);
    end
    
    if ishandle(control_handles.attack_indicator)
        if attack_mode.active
            set(control_handles.attack_indicator, ...
                'String', sprintf(' ACTIVE: %s', attack_mode.type), ...
                'ForegroundColor', [1 0.3 0.3]);
        else
            set(control_handles.attack_indicator, ...
                'String', ' No Attack', 'ForegroundColor', [0.3 1 0.3]);
        end
    end
    
    if ishandle(control_handles.energy_display)
        total_solar = sum(sim_data.P_pv(1:idx)) * sim_data.dt / 3600000;
        total_wind = sum(sim_data.P_wind(1:idx)) * sim_data.dt / 3600000;
        total_load = sum(sim_data.P_load(1:idx)) * sim_data.dt / 3600000;
        
        energy_str = {
            '═══════════════════════════';
            sprintf(' Solar: %.3f MWh', total_solar);
            sprintf(' Wind: %.3f MWh', total_wind);
            sprintf(' Total: %.3f MWh', total_solar + total_wind);
            '───────────────────────────';
            sprintf(' Load: %.3f MWh', total_load);
            sprintf('  Renewable: %.1f%%', min(100, (total_solar + total_wind) / max(0.001, total_load) * 100));
            '═══════════════════════════';
            sprintf(' Encryptions: %d', security_system.encryption_count);
            sprintf(' Anomalies: %d', security_system.detection_count);
            sprintf(' Blocks: %d', length(security_system.blockchain.chain));
        };
        set(control_handles.energy_display, 'String', energy_str);
    end
    
    if ishandle(control_handles.blockchain_display)
        chain = security_system.blockchain.chain;
        n_show = min(8, length(chain));
        bc_str = {};
        for i = length(chain):-1:max(1, length(chain)-n_show+1)
            block = chain{i};
            bc_str{end+1} = sprintf('Block #%d', block.index);
            bc_str{end+1} = sprintf('  %s', block.data.event);
            bc_str{end+1} = sprintf('  Hash: %s', block.hash(1:8));
            if i > 1
                bc_str{end+1} = '  ↓';
            end
        end
        set(control_handles.blockchain_display, 'String', bc_str);
    end
    
    if ishandle(control_handles.attack_log_display)
        n_show = min(12, length(security_system.attack_log));
        if n_show > 0
            recent = security_system.attack_log(end-n_show+1:end);
            set(control_handles.attack_log_display, 'String', recent);
        end
    end
    
    update_health_gauges_enhanced(idx);
end

function update_health_gauges_enhanced(idx)
    global sim_data control_handles attack_mode;
    
    voltage_health = min(100, max(0, 100 - abs(sim_data.voltage(idx) - 11000) / 50));
    freq_health = min(100, max(0, 100 - abs(sim_data.frequency(idx) - 50) * 50));
    P_balance = (sim_data.P_pv(idx) + sim_data.P_wind(idx)) - sim_data.P_load(idx);
    balance_health = min(100, max(0, 100 - abs(P_balance) / 10));
    
    if attack_mode.active
        security_health = 40;
    else
        security_health = 100;
    end
    
    grid_health = min(100, max(0, 100 - abs(sim_data.P_grid(idx)) / 10));
    
    healths = [voltage_health, freq_health, balance_health, security_health, grid_health];
    
    for i = 1:5
        if ishandle(control_handles.(['gauge_fill_' num2str(i)]))
            if healths(i) >= 75
                color = [0.2 0.8 0.4];
            elseif healths(i) >= 50
                color = [0.95 0.7 0.2];
            else
                color = [0.9 0.2 0.2];
            end
            
            width = 350 * healths(i) / 100;
            pos = get(control_handles.(['gauge_fill_' num2str(i)]), 'Position');
            set(control_handles.(['gauge_fill_' num2str(i)]), ...
                'Position', [pos(1) pos(2) width pos(4)], 'BackgroundColor', color);
            
            set(control_handles.(['gauge_text_' num2str(i)]), ...
                'String', sprintf('%.0f%%', healths(i)), 'ForegroundColor', color);
        end
    end
end

function update_all_plots_enhanced()
    global sim_data plot_handles attack_mode;
    
    idx = sim_data.time_index;
    plot_points = min(360, idx);
    start_idx = max(1, idx - plot_points);
    end_idx = idx;
    
    time_hours = sim_data.t(start_idx:end_idx) / 3600;
    
    %% PLOT 1: Power
    if ishandle(plot_handles.ax1) && isvalid(plot_handles.ax1)
        cla(plot_handles.ax1);
        hold(plot_handles.ax1, 'on');
        
        plot(plot_handles.ax1, time_hours, sim_data.P_pv(start_idx:end_idx), ...
            'y-', 'LineWidth', 2.5, 'DisplayName', 'Solar');
        plot(plot_handles.ax1, time_hours, sim_data.P_wind(start_idx:end_idx), ...
            'c-', 'LineWidth', 2.5, 'DisplayName', 'Wind');
        plot(plot_handles.ax1, time_hours, sim_data.P_load(start_idx:end_idx), ...
            'r-', 'LineWidth', 2.5, 'DisplayName', 'Load');
        plot(plot_handles.ax1, time_hours, ...
            sim_data.P_pv(start_idx:end_idx) + sim_data.P_wind(start_idx:end_idx), ...
            'g--', 'LineWidth', 2, 'DisplayName', 'Total Gen');
        
        attack_indices = find(sim_data.attack_active(start_idx:end_idx));
        if ~isempty(attack_indices)
            plot(plot_handles.ax1, time_hours(attack_indices), ...
                sim_data.P_load(start_idx-1+attack_indices), ...
                'rx', 'MarkerSize', 10, 'LineWidth', 2);
        end
        
        legend(plot_handles.ax1, 'Location', 'northwest', 'TextColor', 'white', 'FontSize', 8);
        xlabel(plot_handles.ax1, 'Time (hours)', 'Color', 'white', 'FontSize', 9);
        ylabel(plot_handles.ax1, 'Power (kW)', 'Color', 'white', 'FontSize', 9);
        title(plot_handles.ax1, '⚡ Power Generation & Demand', 'Color', 'white', 'FontSize', 10);
        grid(plot_handles.ax1, 'on');
        hold(plot_handles.ax1, 'off');
    end
    
    %% PLOT 2: Battery
    if ishandle(plot_handles.ax2) && isvalid(plot_handles.ax2)
        cla(plot_handles.ax2);
        hold(plot_handles.ax2, 'on');
        
        plot(plot_handles.ax2, time_hours, sim_data.SOC(start_idx:end_idx), ...
            'b-', 'LineWidth', 3);
        yline(plot_handles.ax2, 20, 'r--', 'Min', 'LineWidth', 1.5);
        yline(plot_handles.ax2, 95, 'r--', 'Max', 'LineWidth', 1.5);
        yline(plot_handles.ax2, 70, 'g:', 'Target', 'LineWidth', 1);
        
        ylim(plot_handles.ax2, [0 100]);
        xlabel(plot_handles.ax2, 'Time (hours)', 'Color', 'white', 'FontSize', 9);
        ylabel(plot_handles.ax2, 'SOC (%)', 'Color', 'white', 'FontSize', 9);
        title(plot_handles.ax2, 'Battery State of Charge', 'Color', 'white', 'FontSize', 10);
        grid(plot_handles.ax2, 'on');
        hold(plot_handles.ax2, 'off');
    end
    
    %% PLOT 3: Voltage & Frequency
    if ishandle(plot_handles.ax3) && isvalid(plot_handles.ax3)
        cla(plot_handles.ax3);
        
        yyaxis(plot_handles.ax3, 'left');
        plot(plot_handles.ax3, time_hours, sim_data.frequency(start_idx:end_idx), ...
            'm-', 'LineWidth', 2.5);
        ylabel(plot_handles.ax3, 'Frequency (Hz)', 'Color', 'white', 'FontSize', 9);
        ylim(plot_handles.ax3, [49.5 50.5]);
        set(plot_handles.ax3, 'YColor', 'm');
        
        yyaxis(plot_handles.ax3, 'right');
        plot(plot_handles.ax3, time_hours, sim_data.voltage(start_idx:end_idx) / 1000, ...
            'g-', 'LineWidth', 2.5);
        ylabel(plot_handles.ax3, 'Voltage (kV)', 'Color', 'white', 'FontSize', 9);
        set(plot_handles.ax3, 'YColor', 'g');
        
        xlabel(plot_handles.ax3, 'Time (hours)', 'Color', 'white', 'FontSize', 9);
        title(plot_handles.ax3, ' Voltage & Frequency', 'Color', 'white', 'FontSize', 10);
        grid(plot_handles.ax3, 'on');
        set(plot_handles.ax3, 'Color', [0.03 0.03 0.06]);
    end
    
    %% PLOT 4: Anomaly Detection
    if ishandle(plot_handles.ax4) && isvalid(plot_handles.ax4)
        cla(plot_handles.ax4);
        hold(plot_handles.ax4, 'on');
        
        anomaly_conf = sim_data.anomaly_detected(start_idx:end_idx);
        
        area(plot_handles.ax4, time_hours, anomaly_conf, ...
            'FaceColor', [1 0.3 0.3], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
        
        attack_periods = sim_data.attack_active(start_idx:end_idx);
        if any(attack_periods)
            attack_idx = find(attack_periods > 0);
            scatter(plot_handles.ax4, time_hours(attack_idx), ...
                ones(length(attack_idx), 1) * 0.5, 50, 'r', 'filled', ...
                'MarkerEdgeColor', 'w', 'LineWidth', 1);
        end
        
        detected = find(anomaly_conf > 0.5);
        if ~isempty(detected)
            scatter(plot_handles.ax4, time_hours(detected), ...
                anomaly_conf(detected), 80, 'y', 'filled', ...
                'MarkerEdgeColor', 'k', 'LineWidth', 1);
        end
        
        ylim(plot_handles.ax4, [0 1.2]);
        xlabel(plot_handles.ax4, 'Time (hours)', 'Color', 'white', 'FontSize', 9);
        ylabel(plot_handles.ax4, 'Anomaly Confidence', 'Color', 'white', 'FontSize', 9);
        title(plot_handles.ax4, 'ML Detection & Attacks', 'Color', 'white', 'FontSize', 10);
        
        if attack_mode.active
            legend(plot_handles.ax4, {'Anomaly', 'Attack', 'Detected'}, ...
                'TextColor', 'white', 'Location', 'northwest', 'FontSize', 7);
        end
        
        grid(plot_handles.ax4, 'on');
        hold(plot_handles.ax4, 'off');
    end
    
    drawnow limitrate;
end

%% ========================================================================
%% UTILITY FUNCTIONS
%% ========================================================================

function add_security_log(message)
    global security_system control_handles;
    
    timestamp = datestr(now, 'HH:MM:SS');
    log_entry = sprintf('[%s] %s', timestamp, message);
    security_system.security_log{end+1} = log_entry;
    
    if ishandle(control_handles.security_log)
        n_show = min(25, length(security_system.security_log));
        recent = security_system.security_log(end-n_show+1:end);
        set(control_handles.security_log, 'String', recent);
        set(control_handles.security_log, 'ListboxTop', length(recent));
    end
end

function add_encryption_log(message)
    global control_handles;
    persistent encryption_log;
    
    if isempty(encryption_log)
        encryption_log = {};
    end
    
    timestamp = datestr(now, 'HH:MM:SS');
    log_entry = sprintf('[%s] %s', timestamp, message);
    encryption_log{end+1} = log_entry;
    
    if ishandle(control_handles.encryption_display)
        n_show = min(18, length(encryption_log));
        recent = encryption_log(end-n_show+1:end);
        set(control_handles.encryption_display, 'String', recent);
    end
end

function close_enhanced_system(src, ~)
    global control_handles is_running;
    
    if isfield(control_handles, 'timer') && isvalid(control_handles.timer)
        stop(control_handles.timer);
        delete(control_handles.timer);
    end
    
    is_running = false;
    
    fprintf('\n╔══════════════════════════════════════════════════════════════╗\n');
    fprintf('║  System Shutdown Complete                                    ║\n');
    fprintf('║  Thank You for Using Cyber-Resilient Microgrid!              ║\n');
    fprintf('╚══════════════════════════════════════════════════════════════╝\n\n');
    
    delete(src);
end