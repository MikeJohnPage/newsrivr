#' Clean retrieved news articles
#'
#' \code{clean_news} wrangles the messy data fetched by \code{\link{get_news}},
#' returning a tidy tibble with sensible defaults.
#'
#' @param data Tbl, returned from \code{\link{get_news}}.
#'
#' @param min_nchar Integer, specifying the minimum number of characters of
#'   articles to be kept in the corpus.
#'
#' @param as_date Logical, indicating whether dates should be transformed to
#'   class "Date".
#'
#' @param drop_vars Logical, indicating whether all variables (other than
#'   \code{title, text, discoverDate,} & \code{website.domainName}) should be
#'   dropped. The Newsriver API (typically) returns 26 variables, many of which
#'   contain sparse metadata.
#'
#' @param to_lower Logical, indicating whether the \code{title} and \code{text}
#'   variables should be transformed to lowercase.
#'
#' @param distinct Logical, indicating whether only articles with either
#'   distinct \code{title} or \code{text} values should be kept.
#'
#' @param drop_na Logical, indicating whether to drop rows containing missing
#'   values.
#'
#' @param tif_corpus Logical, indicating whether the tibble should be a
#'   \href{https://github.com/ropensci/tif}{TIF} valid corpus.
#'
#' @examples
#' \dontrun{
#' clean_news(data = my_tbl)
#'
#' clean_news(my_tbl, min_nchar = 500, tif_corpus = TRUE)
#' }
#'
#' @importFrom rlang .data
#'
#' @export

clean_news <- function(data,
                       min_nchar = 300,
                       as_date = TRUE,
                       drop_vars = TRUE,
                       to_lower = TRUE,
                       distinct = TRUE,
                       drop_na = FALSE,
                       tif_corpus = FALSE) {

  # Check data
  if(!tibble::is_tibble(data)) {
    stop("data is not of class tibble")
  }

  if(!all(c("elements",
            "text",
            "publishDate",
            "discoverDate",
            "title",
            "website.domainName") %in% colnames(data))) {
    stop("please provide a valid newsrivr tibble from \"get_news()\"")
  }

  # Check min_nchar
  stopifnot(is.numeric(min_nchar))

  if(!(min_nchar >= 0)) {
    stop("\"min_nchar\" cannot be negative")
  }

  # Check as_date
  stopifnot(is.logical(as_date))

  # Check drop_vars
  stopifnot(is.logical(drop_vars))

  # Check to_lower
  stopifnot(is.logical(to_lower))

  # Check distinct
  stopifnot(is.logical(distinct))

  # Check drop_na
  stopifnot(is.logical(drop_na))

  # check tif_corpus
  stopifnot(is.logical(tif_corpus))

  # Remove 'elements' column
  data <- dplyr::select(
    data,
    -.data$elements
  )

  # Remove articles containing text less than n characters
  data <- dplyr::filter(
    data,
    nchar(.data$text) >= min_nchar
  )

  # Transform date variables to class "Date"
  if (as_date == TRUE) {
    data <- dplyr::mutate(data,
                          discoverDate = as.Date(.data$discoverDate),
                          publishDate = as.Date(.data$publishDate)
    )
  }

  # Drop unwanted variables
  if (drop_vars == TRUE) {
    data <- dplyr::select(
      data,
      .data$text,
      .data$title,
      .data$discoverDate,
      .data$website.domainName
    )
  } else {
    message("If a limited number of observations have been returned,
    consider setting the argument 'drop_na' to FALSE.")
  }

  # Transform title and text to lower case
  if (to_lower == TRUE) {
    data <- dplyr::mutate(data,
                          title = tolower(.data$title),
                          text = tolower(.data$text)
    )
  }

  # Remove duplicates
  if (distinct == TRUE) {
    data <- dplyr::distinct(data,
                            .data$text,
                            .data$title,
                            .keep_all = TRUE
    )
  }

  # Drop rows conaining NA values
  if (drop_na == TRUE) {
    data <- stats::na.omit(data)
  }

  # Make Text Interchange Format (tif) compliant corpus
  if (tif_corpus == TRUE) {
    data <- dplyr::mutate(data, doc_id = dplyr::row_number())
    data <- dplyr::mutate(data, doc_id = as.character(.data$doc_id))
    data <- dplyr::select(
      data,
      .data$doc_id,
      .data$text,
      .data$title,
      .data$discoverDate,
      .data$website.domainName
    )
  }

  return(data)
}
