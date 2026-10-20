# Load all CSVs from data/raw; works with either flat or nested ZIP extraction.
find_hockey_csvs <- function(raw_dir = 'data/raw') {
  if (!dir.exists(raw_dir)) stop('Missing directory: ', raw_dir)
  paths <- list.files(raw_dir, pattern = '\\.csv$', recursive = TRUE,
                      full.names = TRUE, ignore.case = TRUE)
  paths <- paths[!grepl('(^|/|\\\\)__MACOSX(/|\\\\)|(^|/|\\\\)\\._', paths)]
  if (!length(paths)) stop('No CSV files found under ', raw_dir,
                           '. Unzip hockey_development_data.zip into data/raw first.')
  keys <- tolower(tools::file_path_sans_ext(basename(paths)))
  if (anyDuplicated(keys)) stop('Duplicate CSV basenames: ',
                                paste(unique(keys[duplicated(keys)]), collapse = ', '))
  stats::setNames(paths, keys)
}

load_hockey_data <- function(raw_dir = 'data/raw') {
  paths <- find_hockey_csvs(raw_dir)
  data <- lapply(paths, function(p) utils::read.csv(p, stringsAsFactors = FALSE,
                                                    check.names = FALSE,
                                                    na.strings = c('', 'NA', 'NULL')))
  message('Loaded ', length(data), ' tables (',
          format(sum(vapply(data, nrow, integer(1))), big.mark = ','), ' rows).')
  data
}

get_table <- function(data, name) {
  key <- tolower(name)
  if (!key %in% names(data)) stop('Missing table ', name)
  data[[key]]
}
