# Descriptive audit: do not impute or alter source data here.
audit_tables <- function(data) {
  do.call(rbind, lapply(names(data), function(nm) {
    x <- data[[nm]]
    data.frame(table = nm, rows = nrow(x), columns = ncol(x),
               missing_cells = sum(is.na(x)),
               missing_pct = if (length(x)) round(100 * mean(is.na(x)), 2) else NA_real_,
               duplicate_rows = sum(duplicated(x)),
               stringsAsFactors = FALSE)
  }))
}

audit_team_keys <- function(teams) {
  needed <- c('year', 'lgID', 'tmID')
  stopifnot(all(needed %in% names(teams)))
  key <- teams[, needed, drop = FALSE]
  if (anyNA(key)) warning('Missing values in team-season keys')
  if (anyDuplicated(key)) stop('Duplicate team-season keys: investigate before modeling')
  invisible(TRUE)
}

league_summary <- function(teams) {
  out <- stats::aggregate(year ~ lgID, data = teams,
                          FUN = function(x) c(first = min(x), last = max(x), rows = length(x)))
  data.frame(league = out$lgID, first_year = out$year[, 'first'],
             last_year = out$year[, 'last'], teams_seasons = out$year[, 'rows'],
             row.names = NULL)
}
