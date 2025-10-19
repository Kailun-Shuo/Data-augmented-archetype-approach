function run_all(configPath)
% RUN_ALL - Main entry point to run the full pipeline.
% This script:
%   1) Reads user-editable configuration from config.json
%   2) Prepares paths and output folders
%   3) Runs the Ruby step (A_ruby.rb)
%   4) Runs MATLAB steps process_B and process_C in order
%
% USAGE:
%   run_all;              % uses default 'config.json' in current folder
%   run_all('myconf.json');

    if nargin < 1 || isempty(configPath)
        configPath = 'config.json'; % <-- users can change this if needed
    end

    % --- Read configuration (JSON) ---
    assert(exist(configPath, 'file') == 2, 'Config file not found: %s', configPath);
    cfgText = fileread(configPath);
    cfg = jsondecode(cfgText);

    % --- Resolve paths ---
    dataDir = cfg.data_dir;           % e.g., "path/to/your/data"
    inputFile = cfg.input_file;       % e.g., "input.csv"
    outputDir = cfg.output_dir;       % e.g., "path/to/output"
    rubyBin = cfg.ruby_bin;           % e.g., "ruby" or full path to ruby
    params = cfg.params;              % struct with algorithm params

    % Validate basic fields
    assert(ischar(dataDir) || isstring(dataDir), 'data_dir must be a string.');
    assert(ischar(inputFile) || isstring(inputFile), 'input_file must be a string.');
    assert(ischar(outputDir) || isstring(outputDir), 'output_dir must be a string.');

    % Create output directory if it doesn't exist
    if exist(outputDir, 'dir') ~= 7
        mkdir(outputDir);
    end

    % Build full input path
    inputPath = fullfile(dataDir, inputFile);
    assert(exist(inputPath, 'file') == 2, 'Input file not found: %s', inputPath);

    % --- Log start ---
    fprintf('[RUN_ALL] Starting pipeline...\n');
    fprintf('[RUN_ALL] Data dir : %s\n', dataDir);
    fprintf('[RUN_ALL] Input    : %s\n', inputPath);
    fprintf('[RUN_ALL] Output   : %s\n', outputDir);

    % --- Step A: Run Ruby script ---
    % Pass arguments via CLI flags; keep everything explicit for users to change.
    % We pass: --input, --output, --threshold, --max_iter, --seed
    rubyCmd = sprintf('"%s" A_ruby.rb --input "%s" --output "%s" --threshold %g --max_iter %d --seed %d', ...
        rubyBin, inputPath, outputDir, params.threshold, params.max_iter, params.seed);

    fprintf('[RUN_ALL] Running Ruby step:\n  %s\n', rubyCmd);
    [statusA, outA] = system(rubyCmd);
    fprintf('[RUN_ALL][Ruby stdout/stderr]\n%s\n', outA);
    assert(statusA == 0, 'Ruby step failed. See logs above.');

    % Example: Ruby step produces an intermediate file (adjust name as needed)
    interA = fullfile(outputDir, 'ruby_output.json');
    assert(exist(interA, 'file') == 2, 'Expected Ruby output not found: %s', interA);

    % --- Step B: MATLAB processing ---
    fprintf('[RUN_ALL] Running MATLAB Step B...\n');
    outB = process_B(interA, params, outputDir);
    % outB is typically a path to another intermediate or a data struct.

    % --- Step C: MATLAB processing ---
    fprintf('[RUN_ALL] Running MATLAB Step C...\n');
    finalOut = process_C(outB, params, outputDir);

    % --- Done ---
    fprintf('[RUN_ALL] Pipeline completed successfully.\n');
    fprintf('[RUN_ALL] Final output: %s\n', string(finalOut));
end
