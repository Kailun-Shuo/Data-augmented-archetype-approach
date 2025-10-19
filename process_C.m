function finalPath = process_C(inputB, params, outputDir)
% PROCESS_C - MATLAB Step C processing.
% This function consumes Step B result and produces the final artifact.
%
% INPUTS:
%   inputB   : either a path (string) to stepB output OR a data struct loaded by caller
%   params   : struct of algorithm parameters
%   outputDir: directory where final output should be saved
%
% OUTPUT:
%   finalPath: path to the final output artifact (e.g., a figure, CSV, or MAT)
%
% NOTE:
%   - Do not rely on global variables or hardcoded paths.
%   - Keep interfaces explicit and documented.

    if ischar(inputB) || isstring(inputB)
        assert(exist(inputB, 'file') == 2, 'process_C: Step B output not found: %s', inputB);
        s = load(inputB);  % loads variables from MAT
        data = s.data;
    elseif isstruct(inputB)
        data = inputB;
    else
        error('process_C: unsupported inputB type.');
    end

    if exist(outputDir, 'dir') ~= 7
        mkdir(outputDir);
    end

    % --- Your algorithm here ---
    % Example placeholder: maybe aggregate and export a CSV
    % Replace with your real logic (plots/statistics/model training/etc.)
    tbl = struct2table_if_possible(data);

    finalPath = fullfile(outputDir, 'final_output.csv');
    try
        if istable(tbl)
            writetable(tbl, finalPath);
        else
            % Fallback: write JSON if not a table
            fid = fopen(finalPath, 'w');
            fwrite(fid, jsonencode(data), 'char');
            fclose(fid);
            % rename to .json
            movefile(finalPath, replace(finalPath, '.csv', '.json'));
            finalPath = replace(finalPath, '.csv', '.json');
        end
    catch ME
        warning('process_C: failed to write CSV (%s). Writing MAT instead.', ME.message);
        finalPath = fullfile(outputDir, 'final_output.mat');
        save(finalPath, 'data', '-v7');
    end

    fprintf('[process_C] Final output: %s\n', finalPath);
end

function tbl = struct2table_if_possible(s)
%STRUCT2TABLE_IF_POSSIBLE - best-effort conversion from struct to table.
    try
        if isstruct(s)
            tbl = struct2table(s);
        else
            tbl = s; % maybe already a table/array
        end
    catch
        tbl = s; % return as-is if conversion fails
    end
end
