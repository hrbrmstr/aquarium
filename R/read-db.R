#' Retrieve a complete copy of the current PhishTank database
#'
#' @md
#' @note You _need_ an [API key](http://www.phishtank.com/api_register.php). Anonymous usage is not
#'       supported by this package.
#' @param .progress if `TRUE`, display a download progress bar
#' @param phishtank_api_key a PhishTank [API key](http://www.phishtank.com/api_register.php)
#' @references <https://www.phishtank.com/developer_info.php>
#' @export
pt_read_db <- function(phishtank_api_key=Sys.getenv("PHISHTANK_API_KEY"),
                       .progress=TRUE) {
  
  sprintf(
    fmt = "https://data.phishtank.com/data/%s/online-valid.json.gz", 
    phishtank_api_key
  ) -> pt_url
  
  tf <- tempfile(fileext = ".json.gz")
  on.exit(unlink(tf), add=TRUE)
  
  res <- httr::GET(pt_url, write_disk(tf), if(.progress) httr::progress())
  
  httr::stop_for_status(res)
  
  res <- jsonlite::fromJSON(tf)
  
  as.POSIXct(
    sub(":([[:digit:]]+)$", "\\1" , res$submission_time), 
    format="%Y-%m-%dT%H:%M:%S%z"
  ) -> res$submission_time
  
  as.POSIXct(
    sub(":([[:digit:]]+)$", "\\1" , res$verification_time), 
    format="%Y-%m-%dT%H:%M:%S%z"
  ) -> res$verification_time
  
  data.frame(
    ip_address = NA,
    cidr_block = NA,
    announcing_network = NA,
    rir = NA,
    country = NA,
    detail_time = NA
  ) -> blank_details
  
  for (r in which(sapply(res$details, nrow) == 0)) {
    res$details[[r]] <- blank_details
  }
  
  class(res) <- c("tbl_df", "tbl", "data.frame")
  
  res
  
}
