# Data-augmented-archetype-approach
The framework and key code source of the data-augmented archetype approach 

All **user-specific paths and parameters are externalized** in `config.json` to ease reproducibility.

## Quick Start

1. **Install dependencies**
   - MATLAB R2020b+ (or compatible)
   - Ruby 2.7+ (or compatible)
2. **Edit `config.json`**
   - `data_dir`: path to your input data directory
   - `input_file`: the main input filename (without path)
   - `output_dir`: where outputs will be written
   - `ruby_bin`: Ruby interpreter command (e.g., `"ruby"` or an absolute path)
   - `params`: algorithm parameters (e.g., `threshold`, `max_iter`, `seed`)
3. **Run the full pipeline (from MATLAB)**
   ```matlab
   run_all;           % uses the default config.json
   % or
   run_all('path/to/your_config.json');
