# R starter: hockey project

Copy `src/*.R` into your existing project's `src/` folder and
`scripts/01_audit_and_panel.R` into its `scripts/` folder.

1. Extract `hockey_development_data.zip` into `data/raw/` (nested folder is fine).
2. Open an R session with the project root as the working directory.
3. Run `source('scripts/01_audit_and_panel.R')`.

Outputs:
- `reports/data_audit.csv`
- `reports/league_summary.csv`
- `data/processed/nhl_team_panel.csv`

No external R packages required for this first milestone.

IMPORTANT:
- NHL is an initial working assumption; confirm target league first.
- `rank` in source is not assumed to be overall league rank. The code
  derives a provisional league-wide ranking based on points per game.
- `points_per_game` is NOT necessarily points percentage. Historical
  scoring systems vary; this version is exploratory, not the final target.
- Franchise lagging is a first pass; teams with relocated/reorganized
  identifiers or gaps require manual audit.
- Coach-change labels are intentionally not created yet: distinguish
  preseason replacements from in-season changes before defining them.
- Never use columns beginning `target_` as predictors.