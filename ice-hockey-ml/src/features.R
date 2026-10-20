# Construct a team-season supervised dataset using only previous-season performance.
# Historical row (team, year) receives features from the latest STRICTLY EARLIER
# available year for its franchise, not the performance of the target year.
build_team_panel <- function(teams, league = 'NHL') {
  needed <- c('year','lgID','tmID','franchID','rank','G','W','L','Pts','GF','GA')
  if (!all(needed %in% names(teams))) stop('Missing columns: ', paste(setdiff(needed, names(teams)), collapse=', '))
  x <- teams[teams$lgID == league, , drop = FALSE]
  x$year <- as.integer(x$year)
  for (nm in c('rank','G','W','L','Pts','GF','GA')) x[[nm]] <- suppressWarnings(as.numeric(x[[nm]]))
  x <- x[order(x$franchID, x$year, x$tmID), , drop = FALSE]
  if (anyDuplicated(x[, c('year','lgID','tmID')])) stop('Duplicate team-season keys')
  # Avoid cross-era franchise collisions by detecting duplicate franchise/year pairs.
  if (anyDuplicated(x[, c('franchID','year')])) stop('Franchise/year collisions; review identifiers')
  x$points_per_game <- ifelse(x$G > 0, x$Pts / x$G, NA_real_)
  x$goal_diff_per_game <- ifelse(x$G > 0, (x$GF - x$GA) / x$G, NA_real_)
  # "rank" may reflect division standings rather than league-wide rank.
  # Keep raw rank only as a diagnostic; define league rank by sorted points-per-game.
  x$league_rank <- NA_integer_
  for (yr in unique(x$year)) {
    idx <- which(x$year == yr)
    x$league_rank[idx] <- rank(-x$points_per_game[idx], ties.method='min', na.last='keep')
  }
  feature_names <- c('year','points_per_game','goal_diff_per_game','W','L','rank','league_rank')
  for (nm in feature_names) x[[paste0('prev_',nm)]] <- NA_real_
  groups <- split(seq_len(nrow(x)), x$franchID)
  for (idx in groups) {
    idx <- idx[order(x$year[idx])]
    if (length(idx) < 2L) next
    for (nm in feature_names) x[[paste0('prev_', nm)]][idx[-1]] <- as.numeric(x[[nm]][idx[-length(idx)]])
  }
  x$years_since_prev <- x$year - x$prev_year
  x$target_points_per_game <- x$points_per_game
  x$target_league_rank <- x$league_rank
  # Only immediate previous calendar season, except explicitly declared skipped years.
  # 2004 is absent from NHL dataset (lockout). Retain gaps but flag them.
  x
}

assert_no_future_features <- function(panel) {
  ok <- is.na(panel$prev_year) | panel$prev_year < panel$year
  if (!all(ok)) stop('Leakage: previous season is not strictly earlier')
  invisible(TRUE)
}
