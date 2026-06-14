data_dir <- "project_data"

rds_files <- list.files(
  data_dir,
  pattern = "^big5_player_.*\\.rds$",
  full.names = TRUE
)

if (length(rds_files) == 0) {
  stop("No big5_player_*.rds files found in ", data_dir)
}

convert_rds_to_csv <- function(rds_file) {
  player_data <- readRDS(rds_file)
  csv_name <- paste0(
    sub("^big5_", "", tools::file_path_sans_ext(basename(rds_file))),
    ".csv"
  )
  csv_path <- file.path(data_dir, csv_name)

  write.csv(player_data, file = csv_path, row.names = FALSE)
  csv_path
}

csv_files <- vapply(rds_files, convert_rds_to_csv, character(1))

message("Wrote CSV files:")
message(paste(csv_files, collapse = "\n"))
