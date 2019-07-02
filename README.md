
<!-- README.md is generated from README.Rmd. Please edit that file -->

# newsrivr <img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build
Status](https://travis-ci.org/MikeJohnPage/newsrivr.svg?branch=master)](https://travis-ci.org/MikeJohnPage/newsrivr)
<!-- badges: end -->

## Overview

newsrivr is an R wrapper to the [Newsriver API](https://newsriver.io/),
providing simple functions to retrieve and clean news articles following
a tidy framework. Newsriver is a non profit free of charge news API (for
commercial purposes, a monthly subscription is encouraged), and when
combined with the newsrivr R package, can return up to 36,500 articles
in a single search.

## Installation

You can install the development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("MikeJohnPage/newsrivr")
```

## Usage

newsrivr follows a simple workflow: (1) store credentials, (2) retrieve
news, (3) clean news.

### Store credentials

To access the Newsriver API, you need to register an [API
token](https://console.newsriver.io/api-token). In addition, you are
also required to provide a user agent when using the newsrivr package.
This allows Newsriver to identify who is using the API (and is important
if something goes wrong). A good default user agent is your email
address. To make your credentials available to newsrivr at every
session, use the `store_credentials()` function, which will prompt you
for your API token and user agent and then append them to a `.Renviron`
file located in your home directory (note, you should only do this
once):

``` r
library(newsrivr)

# you will be prompted for your credentials
store_creds()
```

If you would not like newsrivr to alter your `.Renviron` file, you can
use the `store_creds_temp()` which just makes the credentials available
for the current R session only (note, you will have to do this at every
session):

``` r
# you will be prompted for your credentials
store_creds_temp()
```

Alternatively, you can manually pass your API token and user credentials
into the relevant newsrivr functions (below), however, this isn’t
recommended as credentials can accidentally get leaked in scripts and
`.Rhistory` files. See the `?store_credentials` documentation for more
information.

### Retrieve news

The `get_news()` function returns news articles from the Newsriver API
matching a user provided search query. These queries must be valid
[Lucene query
strings](https://lucene.apache.org/core/2_9_4/queryparsersyntax.html),
with the option to search the title and text fields of articles. See the
`?get_news` documentation for more information:

``` r
get_news(query = "Google")
#> # A tibble: 3,100 x 26
#>   id    publishDate discoverDate title language text  structuredText url  
#>   <chr> <chr>       <chr>        <chr> <chr>    <chr> <chr>          <chr>
#> 1 EXlv… 2019-06-02… 2019-06-02T… Disp… en       "Hel… "<div> \n <p>… http…
#> 2 dOvQ… 2019-06-03… 2019-06-03T… Goog… en       "An … "<div> \n <p>… http…
#> 3 U4d0… 2014-02-25… 2019-06-03T… 8 Go… en       Any … "<div> \n <p>… http…
#> 4 ikfM… 2012-12-08… 2019-06-03T… Goog… en       Yest… "<div> \n <p>… http…
#> 5 Zuf8… 2017-04-03… 2019-06-03T… Goog… en       "Goo… "<div> \n <p>… http…
#> # … with 3,095 more rows, and 18 more variables

get_news("Google", from = "2019-05-01", to = "2019-06-01")
#> # A tibble: 3,200 x 26
#>   id    publishDate discoverDate title language text  structuredText url  
#>   <chr> <chr>       <chr>        <chr> <chr>    <chr> <chr>          <chr>
#> 1 29nG… 2019-05-02… 2019-05-02T… How … en       "Goo… "<div> \n <p>… http…
#> 2 jAgI… 2019-05-02… 2019-05-02T… How … en       Goog… "<div> \n <p>… http…
#> 3 uDVD… 2019-05-01… 2019-05-01T… Goog… en       "Goo… "<div> \n <p>… http…
#> 4 tkYy… <NA>        2019-05-02T… Goog… en       "Bot… "<div> \n <p>… http…
#> 5 MieF… 2019-05-01… 2019-05-01T… Walm… en       Lead… "<p>Leading u… http…
#> # … with 3,195 more rows, and 18 more variables

get_news("title:Google AND text:\"Google Cloud\"", language = "it")
#> # A tibble: 2,670 x 24
#>   id    publishDate discoverDate title language text  structuredText url  
#>   <chr> <chr>       <chr>        <chr> <chr>    <chr> <chr>          <chr>
#> 1 Qbfr… 2019-06-02… 2019-06-03T… Avay… it       Avay… "<div> \n <p>… http…
#> 2 2_eR… 2019-06-03… 2019-06-03T… La p… it       Un p… "<div> \n <p>… http…
#> 3 VWo8… 2019-06-03… 2019-06-03T… La p… it       Live… "<div> \n <p>… http…
#> 4 Wsvb… 2019-06-03… 2019-06-03T… Guid… it       "Son… "<div> \n <p>… http…
#> 5 OuAo… 2019-06-03… 2019-06-03T… Stad… it       "All… "<div> \n <p>… http…
#> # … with 2,665 more rows, and 16 more variables
```

### Clean news

The `clean_news()` function wrangles the messy data fetched by
`get_news()`, returning a tidy tibble with sensible defaults.

``` r
news <- get_news(query = "Google")

clean_news(news)
#> # A tibble: 1,542 x 4
#>   text                  title                 discoverDate website.domainN…
#>   <chr>                 <chr>                 <date>       <chr>           
#> 1 "hello,    i have mu… displaying current g… 2019-06-02   spotify.com     
#> 2 "an outage of google… google cloud back to… 2019-06-03   androidcentral.…
#> 3 any google apps admi… 8 google apps admin … 2019-06-03   bettercloud.com 
#> 4 yesterday, google di… google ends free goo… 2019-06-03   bettercloud.com 
#> 5 "google have been ex… google to launch a r… 2019-06-03   madebymagnitude…
#> # … with 1,537 more rows
```

## Getting help

If you encounter a clear bug, please file a minimal reproducible example
in [issues](https://github.com/MikeJohnPage/newsrivr/issues).
