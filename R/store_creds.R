#' Store user credentials
#'
#' \code{store_creds} prompts you for a Newsriver API token and user agent and
#' \emph{permanently} stores them so they are available for \emph{every} R
#' session.
#'
#' @section Token registration:
#'
#' To register for an API token, visit the
#' \href{https://console.newsriver.io/api-token}{Newsriver site} and follow the
#' sign up procedures. Registration is free.
#'
#' @section Setting a user agent:
#'
#' The user agent is a string used to identify the client. This allows Newsriver
#' to identify who is using the API (and is important if something goes wrong).
#' A good default user agent is your email address. \strong{Note:} the
#' user agent you supply does not need to be wrapped in quotes (nor does the
#' API token).
#'
#' @section Environment variables:
#'
#' Both \code{store_creds} and \code{store_creds_temp} store the supplied API
#' token and user agent as environment variables called "NEWSRIVER_API_KEY" and
#' "NEWSRIVER_USER_AGENT" respectively. These environment variables are then
#' called by other newsrivr functions.
#'
#' To store these environment variables, \code{store_creds} tries to find a
#' .Renviron file located in your home directory. If no .Renviron file can be
#' found, one will be created. \strong{Warning:} only call \code{store_creds}
#' once to prevent multiple environment variables being stored.
#'
#' If you do not want to alter your global .Renviron file, then use
#' \code{store_creds_temp} which stores environment variables for only the
#' current R session. Alternatively an API token and user agent can be passed as
#' arguments directly into the relevant newsrivr functions. This method is not
#' recommended as credentials can accidentally get leaked in scripts and .Rhistory
#' files.
#'
#' @examples
#' \dontrun{
#' store_creds() # you will be prompted to enter your credentials
#'
#' store_creds_temp() # you will be prompted to enter your credentials
#' }
#'
#' @export

store_creds <- function() {

  # create path to home
  home <- function() {
    if (!identical(Sys.getenv("HOME"), "")) {
      file.path(Sys.getenv("HOME"))
    } else {
      file.path(normalizePath("~"))
    }
  }

  # check if .Renviron file exists in home directory, else create new file
  if (!file.exists(file.path(home(), ".Renviron"))) {
    file.create(file.path(home(), ".Renviron"))
  }

  # read environment file
  env_file <- readLines((file.path(home(), ".Renviron")),
                        encoding = "UTF-8"
  )

  # setup api_key and user_agent variables
  key <- paste0(
    "NEWSRIVER_API_KEY=",
    askpass::askpass("Please enter API key")
  )
  agent <- paste0(
    "NEWSRIVER_USER_AGENT=",
    askpass::askpass("Please enter user agent")
  )

  # add api_key and user_agent to .Renviron
  env_file <- c(
    env_file,
    key,
    agent
  )

  # write environment file
  writeLines(
    env_file,
    (file.path(home(), ".Renviron"))
  )

  # send success message
  message <- paste("Your api key was successfully appended to your .Renviron file",
                   "Restart R for changes to take effect",
                   sep = "\n"
  )
  message(message)
}

#' Store credentials temporarily
#'
#' \code{store_creds_temp} prompts you for a Newsriver API token and user agent
#' and \emph{temporarily} stores them so they are available for only the
#' \emph{current} R session.
#'
#' @rdname store_creds
#'
#' @export

store_creds_temp <- function() {
  Sys.setenv(
    NEWSRIVER_API_KEY = askpass::askpass("Please enter API key"),
    NEWSRIVER_USER_AGENT = askpass::askpass("Please enter user agent")
  )

  # send success message
  message("Your credentials have been successfully stored for the current session")
}
