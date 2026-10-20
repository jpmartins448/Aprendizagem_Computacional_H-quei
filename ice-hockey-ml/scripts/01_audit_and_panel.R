source('src/data_loader.R')
source('src/preprocessing.R')
source('src/features.R')

dir.create('data/processed', showWarnings=FALSE, recursive=TRUE)
dir.create('reports', showWarnings=FALSE, recursive=TRUE)

hockey <- load_hockey_data()
print(audit_tables(hockey))
utils::write.csv(audit_tables(hockey), 'reports/data_audit.csv', row.names=FALSE)

teams <- get_table(hockey, 'Teams')
audit_team_keys(teams)
print(league_summary(teams))
utils::write.csv(league_summary(teams), 'reports/league_summary.csv', row.names=FALSE)

panel <- build_team_panel(teams, league='NHL')
assert_no_future_features(panel)
utils::write.csv(panel, 'data/processed/nhl_team_panel.csv', row.names=FALSE, na='')
cat('\nNHL seasons:', min(panel$year), '-', max(panel$year), '\n')
cat('Rows:', nrow(panel), '\n')
cat('Panel saved to data/processed/nhl_team_panel.csv\n')
cat('WARNING: Rankings and coaching targets still need formal definitions.\n')
