#' Check an individual URL against PhishTank's database
#'
#' @md
#' @note You _need_ an [API key](http://www.phishtank.com/api_register.php). Anonymous usage is not
#'       supported by this package.
#' @param url URL to test
#' @param phishtank_api_key a PhishTank [API key](http://www.phishtank.com/api_register.php)
#' @return data frame (tibble)
#' @references <https://www.phishtank.com/api_info.php>
#' @export
pt_check_url <- function(url, phishtank_api_key=Sys.getenv("PHISHTANK_API_KEY")) {
  
  httr::POST(
    url = "https://checkurl.phishtank.com/checkurl/",
    body = list(
      url = url,
      format = "json",
      app_key = phishtank_api_key
    )
  ) -> res
  
  httr::stop_for_status(res)
  
  res <- httr::content(res)
  
  res <- as.list(unlist(res))
  
  res <- stats::setNames(res, gsub("^[[:alpha:]]+\\.", "", names(res)))
  
  res <- as.data.frame(res, stringsAsFactors=FALSE)
  
  as.POSIXct(
    sub(":([[:digit:]]+)$", "\\1" , res$timestamp), 
    format="%Y-%m-%dT%H:%M:%S%z"
  ) -> res$timestamp
  
  res_names <- names(res)

  if ("status" %in% res_names) res$status <- as.logical(res$status)
  if ("verified" %in% res_names) res$verified <- as.logical(res$verified)
  if ("valid" %in% res_names) res$valid <- as.logical(res$valid)
  
  class(res) <- c("tbl_df", "tbl", "data.frame")
  
  res
  
}
