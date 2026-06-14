# Playing Style Analysis

This repository analyzes 2022-23 football player style data for midfielders in Europe's big five leagues. The project cleans raw player stat tables, merges midfield-specific features into a single modeling dataset, and applies principal component analysis with a Marchenko-Pastur noise threshold to study meaningful dimensions of playing style.

The current pipeline is organized around two notebooks:

- `data_cleaning.ipynb` builds the cleaned midfielder dataset.
- `mf_23_pca.ipynb` runs the exploratory PCA and interpretation workflow.

## Data Source

The project uses the 2022-23 football player stats dataset credited in the analysis notebook to Vivo Vinco on Kaggle:

https://www.kaggle.com/datasets/vivovinco/20222023-football-player-stats

The raw RDS files in `project_data/` are converted into CSV files before notebook-based analysis. The analysis focuses on players whose position string contains `MF` during the 2022-23 season.

## Repository Structure

```text
.
|-- README.md
|-- rds_to_csv.R
|-- data_cleaning.ipynb
|-- mf_23_pca.ipynb
|-- mf_data_europe_2023.csv
`-- project_data/
    |-- big5_player_defense.rds
    |-- big5_player_gca.rds
    |-- big5_player_passing.rds
    |-- big5_player_possession.rds
    |-- big5_player_shooting.rds
    |-- big5_player_standard.rds
    |-- player_defense.csv
    |-- player_gca.csv
    |-- player_passing.csv
    |-- player_possession.csv
    |-- player_shooting.csv
    `-- player_standard.csv
```

## File Guide

`rds_to_csv.R`

Converts every `project_data/big5_player_*.rds` file into a matching CSV file in `project_data/`. For example, `big5_player_possession.rds` becomes `player_possession.csv`.

`data_cleaning.ipynb`

Reads the repo-local CSV files from `project_data/`, filters to 2022-23 midfielders, removes redundant percentage-derived columns where appropriate, merges stat categories, drops duplicate rows, and writes:

```text
mf_data_europe_2023.csv
```

The current generated file has `1022` rows and `106` columns.

`mf_23_pca.ipynb`

Reads `mf_data_europe_2023.csv`, performs additional filtering and feature preparation, standardizes the feature matrix, computes covariance eigenvalues, compares them against the Marchenko-Pastur distribution, extracts outlier principal components, and visualizes/interprets the resulting player-style space.

`project_data/`

Stores the raw RDS files and their converted CSV equivalents. The converted CSV tables currently include:

| File | Rows | Columns | Description |
| --- | ---: | ---: | --- |
| `player_defense.csv` | 16,139 | 33 | Defensive actions and tackling data |
| `player_gca.csv` | 16,139 | 26 | Shot-creating and goal-creating actions |
| `player_passing.csv` | 16,139 | 34 | Passing volume, distance, and progression data |
| `player_possession.csv` | 16,139 | 36 | Touches, dribbles, carries, and receiving data |
| `player_shooting.csv` | 37,984 | 27 | Shooting and expected-goals data |
| `player_standard.csv` | 38,008 | 34 | Standard playing time, scoring, and expected stats |

## Requirements

Python:

- Python 3.10 or newer
- `pandas`
- `numpy`
- `matplotlib`
- `jupyter`
- `nbconvert`

R:

- R with base packages available

The R conversion script uses only base R functions, including `readRDS`, `write.csv`, `list.files`, and `tools::file_path_sans_ext`.

## Setup

Create and activate a Python environment if desired:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install Python dependencies:

```bash
python3 -m pip install pandas numpy matplotlib jupyter nbconvert
```

Confirm R is available:

```bash
Rscript --version
```

## Reproducing the Pipeline

Run commands from the repository root.

1. Convert RDS files to CSV:

```bash
Rscript rds_to_csv.R
```

This writes the six `player_*.csv` files into `project_data/`.

2. Build the cleaned midfielder dataset:

```bash
python3 -m jupyter nbconvert --to notebook --execute data_cleaning.ipynb --inplace --ExecutePreprocessor.timeout=300
```

This regenerates `mf_data_europe_2023.csv` in the repository root.

3. Run the PCA analysis notebook:

```bash
python3 -m jupyter nbconvert --to notebook --execute mf_23_pca.ipynb --inplace --ExecutePreprocessor.timeout=300
```

This executes the analysis cells and refreshes notebook outputs.

## Analysis Workflow

The project follows this sequence:

1. Load category-level player stat tables from `project_data/`.
2. Filter each table to the 2022-23 season and players whose position contains `MF`.
3. Remove URL fields and selected redundant or mostly missing columns.
4. Merge possession, passing, shooting, defense, goal-creating action, and standard stat tables.
5. Write the merged midfielder dataset to `mf_data_europe_2023.csv`.
6. Load the merged dataset for PCA.
7. Filter to players with at least 5 appearances and at least 186 minutes.
8. Encode league labels numerically.
9. Standardize the feature matrix.
10. Compute covariance eigenvalues and compare them with the Marchenko-Pastur distribution.
11. Extract outlier principal components as signal dimensions.
12. Project players into the signal-PC space and inspect feature loadings.

## Path Conventions

The notebooks are written to use repo-relative paths:

```python
from pathlib import Path

PROJECT_DIR = Path.cwd()
DATA_DIR = PROJECT_DIR / "project_data"
```

Run notebooks and scripts from the repository root so these paths resolve correctly.

## Outputs

Primary generated output:

```text
mf_data_europe_2023.csv
```

Intermediate generated outputs:

```text
project_data/player_defense.csv
project_data/player_gca.csv
project_data/player_passing.csv
project_data/player_possession.csv
project_data/player_shooting.csv
project_data/player_standard.csv
```

Notebook outputs include data previews, histograms, eigenvalue visualizations, Marchenko-Pastur comparisons, PCA scatter plots, feature-loading summaries, and selected-player projections.

## Maintenance Notes

- Keep raw `big5_player_*.rds` files in `project_data/`.
- Re-run `rds_to_csv.R` whenever raw RDS files are replaced or updated.
- Re-run `data_cleaning.ipynb` after CSV regeneration.
- Re-run `mf_23_pca.ipynb` after the cleaned dataset changes.
- Avoid absolute local paths such as `~/Desktop/...`; the project expects repo-relative paths.
- `project_data/player_possession.csv` uses the corrected spelling `possession`.

## Known Caveats

- The dataset may contain multiple rows for a player who transferred clubs during the season. The analysis treats those rows as distinct player-team observations.
- Some columns have mixed types in the source CSVs. The notebooks use `low_memory=False` where needed.
- PCA interpretation depends on the cleaned feature set and filtering thresholds, especially the minimum appearances and minutes filters.
- Notebook outputs are refreshed when the notebooks are executed in place, so diffs can be large even when code changes are small.
