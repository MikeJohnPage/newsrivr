#' Retrieve news articles
#'
#' \code{get_news} returns news articles from the Newsriver API matching a user
#' provided search query.
#'
#' \strong{Search queries}
#'
#' \code{get_news} calls the Newsriver API by generating custom HTTP GET
#' requests. These requests are composed of multiple query parameters (see the
#' Newsriver API
#' \href{https://console.newsriver.io/river/0/doc}{reference manual}). While
#' many search fields of the Newsriver \emph{query} parameter can be searched,
#' the \code{query} parameter of \code{get_news} should only be used to search
#' the \emph{title} and \emph{text} fields of new articles. This is because
#' other fields are handled by default or passed as alternate arguments to
#' \code{get_news} (e.g., \emph{language}).
#'
#' \strong{Date sequences}
#'
#' Results from the Newsriver API are limited to a maximum of 100 articles per
#' GET request. In order to return the maximum number of results,
#' \code{get_news} creates a sequence of search dates, by day, specified between
#' the \code{from} and \code{to} parameters. Each search date from the sequence
#' is then combined with the other query parameters to create a unique GET
#' request for that date. The results from each GET request are then combined
#' and returned.
#'
#' \strong{Rate limiting}
#'
#' Rate limiting is handled automatically by \code{get_news}.
#'
#' @param query Character string, specifying the query to be searched when
#'   calling the Newsriver API. Many fields of retrieved articles can be
#'   searched, but \code{query} should only be used to search the
#'   \emph{title} and \emph{text} fields (other fields are handled by default
#'   or specified as separate parameters to \code{get_news}). Search queries
#'   must be valid
#'   \href{https://lucene.apache.org/core/2_9_4/queryparsersyntax.html}{Lucene query strings}.
#'
#'   To build valid search queries, search terms can be passed into the
#'   \emph{title} and \emph{text} fields using a colon. For example, to search
#'   for any articles containing the word "Google" in the text, use
#'   \code{query = "text:Google"}, or to search for any articles with "Twitter"
#'   in the title use \code{query = "title:Twitter"}. Multiple search
#'   terms/fields can be placed together separated by "OR", "AND", and "NOT"
#'   operators (which perform as expected) to build more complex queries. To
#'   group multiple search terms in one field, use parentheses. For example, to
#'   search for any articles that contain "Google" in the title, \strong{and}
#'   "Cloud" \strong{or} "BigQuery" in the text, use
#'   \code{query = "title:Google AND text:(Cloud OR BigQuery)"}.
#'
#'   To search exact phrases, use double quotes. To do this, either wrap single
#'   quotes around a search query using double quotes, e.g.,
#'   \code{query = 'title:"RStudio Connect"'} or escape each internal double
#'   quote with a single backslash, e.g., \code{query = "\"RStudio Connect\""}.
#'   \strong{Note:} (i) search queries are case sensitive, (ii) spaces behave
#'   like OR operators, (iii) encoded queries cannot exceed 414 characters. For
#'   more examples and information on building queries, see the official
#'   \href{https://console.newsriver.io/code-book}{Newsriver Code Book}.
#'
#' @param from,to Character string, specifying the date range of your search.
#'   Must be in the "\%Y-\%m-\%d" format. \code{to} defaults to the current date
#'   and \code{from} defaults to one month prior that (i.e., the past month).
#'   \strong{Note:} Newsriver can only retrieve articles from the past year.
#'
#' @param language Character string, specifying the language of the articles to
#'   return. Must be in the
#'   \href{https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes}{ISO 639-1}
#'   two-letter code format (e.g., "en", "it", "es", etc.).
#'
#' @param limit Integer, specifying the maximum number of results to return
#'   \emph{per} day between the supplied \code{to} and \code{from} dates.
#'   Accepts values from 1 to 100 (e.g., a search period of 10 days can return
#'   a maximum of 1000 articles).
#'
#' @param api_token,ua Character string, specifying a Newsriver API token and
#'   user agent. Defaults to the values set using \code{\link{store_creds}}.
#'
#' @examples
#' \dontrun{
#' get_news("Google")
#'
#' get_news("title:Google", language = "es", limit = 50)
#'
#' get_news("title:\"Google Cloud\"", from = "2018-12-01", to = "2019-05-01")
#'
#' get_news("title:Google AND text:\"Google Cloud\"")
#' }
#'
#' @export


get_news <- function(query,
                     from = NULL,
                     to = NULL,
                     language = "en",
                     limit = 100,
                     api_token = NULL,
                     ua = NULL) {

  # Check query
  if(!is.null(query)) {
    stopifnot(is.character(query))
    stopifnot(nchar(query) > 0)
    stopifnot(length(query) == 1)
  } else {
    stop("argument \"query\" cannot be NULL")
  }

  if(nchar(utils::URLencode(query, reserved = TRUE)) > 414) {
    stop("query is too long, please make it shorter")
  }

  # Check from
  if(is.null(from)) {
    from <- as.character(seq(Sys.Date(), by = "-1 month", length = 2)[2])
  }

  if(!grepl("\\d{4}-\\d{2}-\\d{2}", from)) {
    stop("\"from\" argument needs to be a character string in \"%Y-%m-%d\" format")
  }

  if(is.na(lubridate::parse_date_time(from,
                                      orders="Ymd",
                                      quiet = TRUE))) {
    stop("\"from\" argument needs to be a character string in \"%Y-%m-%d\" format")
  }

  if(!(as.Date(from) >= seq(Sys.Date(), by = "-1 year", length = 2)[2])) {
    stop("\"from\" date must be within the past year")
  }

  if(as.Date(from) > Sys.Date()) {
    stop("\"from\" date can't be in the future, unless you're a time traveller!?")
  }

  # Check to
  if(is.null(to)) {
    to <- as.character(Sys.Date())
  }

  if(!grepl("\\d{4}-\\d{2}-\\d{2}", to)) {
    stop("\"to\" argument needs to be a character string in \"%Y-%m-%d\" format")
  }

  if(is.na(lubridate::parse_date_time(to,
                                      orders="Ymd",
                                      quiet = TRUE))) {
    stop("\"to\" argument needs to be a character string in \"%Y-%m-%d\" format")
  }

  if(!(to >= from)) {
    stop("\"to\" must be geater than or equal to \"from\"")
  }

  if(as.Date(to) > Sys.Date()) {
    stop("\"to\" date can't be in the future, unless you're a time traveller!?")
  }

  # Check language code
  if(!(language %in%
       c("ab", "aa", "af", "ak", "sq", "am", "ar", "an", "hy", "as", "av", "ae", "ay",
         "az", "bm", "ba", "eu", "be", "bn", "bh", "bi", "bs", "br", "bg", "my", "ca",
         "ch", "ce", "ny", "zh", "cv", "kw", "co", "cr", "hr", "cs", "da", "dv", "nl",
         "dz", "en", "eo", "et", "ee", "fo", "fj", "fi", "fr", "ff", "gl", "gd", "gv",
         "ka", "de", "el", "kl", "gn", "gu", "ht", "ha", "he", "hz", "hi", "ho", "hu",
         "is", "io", "ig", "id", "in", "ia", "ie", "iu", "ik", "ga", "it", "ja", "jv",
         "kl", "kn", "kr", "ks", "kk", "km", "ki", "rw", "rn", "ky", "kv", "kg", "ko",
         "ku", "kj", "lo", "la", "lv", "li", "ln", "lt", "lu", "lg", "lb", "gv", "mk",
         "mg", "ms", "ml", "mt", "mi", "mr", "mh", "mo", "mn", "na", "nv", "ng", "nd",
         "ne", "no", "nb", "nn", "oc", "oj", "cu", "or", "om", "os", "pi", "ps", "fa",
         "pl", "pt", "pa", "qu", "rm", "ro", "ru", "se", "sm", "sg", "sa", "sr", "sh",
         "st", "tn", "sn", "ii", "sd", "si", "ss", "sk", "sl", "so", "nr", "es", "su",
         "sw", "ss", "sv", "tl", "ty", "tg", "ta", "tt", "te", "th", "bo", "ti", "to",
         "ts", "tr", "tk", "tw", "ug", "uk", "ur", "uz", "ve", "vi", "vo", "wa", "cy",
         "wo", "fy", "xh", "yi", "ji", "yo", "za", "zu"))) {
    stop("Language not recognised, please provide a valid 2 character ISO language code")
  }

  # Check limit
  stopifnot(is.numeric(limit))

  if (limit > 100 || limit < 1) {
    stop("limit must be between 1 to 100")
  }

  limit = as.character(limit)

  # Check api token
  if(is.null(api_token)) {
    api_token <- Sys.getenv("NEWSRIVER_API_KEY")
  }

  if (nchar(api_token) == 0) {
    stop(
      "api_token cannot be length 0."
    )
  }

  # Check user agent
  if(is.null(ua)) {
    ua <- httr::user_agent(Sys.getenv("NEWSRIVER_USER_AGENT"))
  } else {
    ua <- httr::user_agent(ua)
  }

  if (nchar(ua$options$useragent) == 0) {
    stop(
      "user agent cannot be length 0."
    )
  }

  # Set date range for api search
  search_dates <- seq(as.Date(from),
                      as.Date(to),
                      by = "day"
  )

  # Set query parameters to be called
  query_params <- sprintf(
    paste0(
      '"',
      query,
      '" AND language:',
      language,
      ' AND discoverDate:[%s TO %s]'
    ),
    search_dates,
    search_dates + 1
  )

  # Initialise progress bar
  p <- dplyr::progress_estimated(length(search_dates))

  # create call to api
  api_call <- function(query_parameters) {

    # Show progress
    p$tick()$print()

    # Make GET request
    # query parameters are escaped and URL encoded by default in httr:
    # https://github.com/r-lib/httr/issues/588
    resp <- httr::GET("https://api.newsriver.io/v2/search",
                      query = list(
                        "query" = query_parameters,
                        "sortBy" = "_score",
                        "sortOrder" = "DESC",
                        "limit" = limit
                      ),
                      ua,
                      httr::add_headers(Authorization = api_token)
    )

    # Return error and stop execution if a json is not returned
    if (httr::http_type(resp) != "application/json") {
      stop("API did not return json", call. = FALSE)
    }

    # Return error if there is a http error, else parse the content from the
    # json file and store the title, text, date, and website in a tibble
    if (httr::http_error(resp) == TRUE) {
      warning("The request failed")
    } else {
      news_tbl <- jsonlite::fromJSON(httr::content(resp,
                                                   as = "text",
                                                   encoding = "UTF-8"
      ),
      flatten = TRUE
      )

      news_tbl <- tibble::as_tibble(news_tbl)

      return(news_tbl)
    }

    # Documented on 25.04.19:
    # The API rate limit is 225 calls per window per API token.
    # The rate limiting window is 15 minutes long.
    # Conservatively set rate limit and show progress.
    Sys.sleep(4)
  }

  # Call newsriver_api function over the vector of query parameters
  news_results <- purrr::map_dfr(query_params, api_call)

  return(news_results)
}
