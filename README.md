
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

newsrivr is a R wrapper to the [Newsriver API](https://newsriver.io/),
providing simple functions to retrieve and clean news articles following
a tidy framework. The Newsriver API is free for non-commercial purposes,
and when combined with newsrivr, can return over 350,000 articles in a
single call.

## Installation

You can install the development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("MikeJohnPage/newsrivr")
```

## Usage

newsrivr follows a simple workflow: (1) store credentials, (2) retrieve
news, (3) clean news.

### Storing credentials

To access the Newsriver API, you will need to (freely) register an [API
token](https://console.newsriver.io/api-token). In addition to an API
token, you are also required to provide a user agent to use the newsrivr
package. This allows Newsriver to identify who is using the API (and is
important if something goes wrong). A good default user agent is your
email address. To make your credentials available to newsrivr at every
session, use the `store_credentials()` function, which will prompt you
for your API token and user agent and then append them to a `.Renviron`
file located in your home directory:

``` r
library(newsrivr)

# you will be prompted for your credentials
store_creds()
```

If you would not like newsrivr to alter your `.Renviron` file, you can
use the `store_creds_temp()` which just makes the credentials available
for the current R session only:

``` r
# you will be prompted for your credentials
store_creds_temp()
```

Alternatively, you can manually pass your API token and user credentials
into the relevant newsrivr functions (below), however, this isn’t
recommended as credentials can accidentally get leaked in scripts and
`.Rhistory` files. See the `?store_credentials` documentation for more
information.

### Retrieving news

The `get_news()` function returns news articles from the Newsriver API
matching a user provided search query. This query allows users to search
across the title and text fields of news articles. See the `?get_news`
documentation for more information:

``` r
get_news(query = "Google")
#> # A tibble: 3,100 x 26
#>   id    publishDate discoverDate title language text  structuredText url  
#>   <chr> <chr>       <chr>        <chr> <chr>    <chr> <chr>          <chr>
#> 1 QMTZ… 2019-05-23… 2019-05-23T… How … en       Goog… "<div> \n <p>… http…
#> 2 pIPn… 2019-05-24… 2019-05-24T… Goog… en       Goog… "<div> \n <p>… http…
#> 3 iSWA… 2019-05-23… 2019-05-23T… Goog… en       It w… "<div> \n <p>… http…
#> 4 zRmU… 2019-05-01… 2019-05-24T… Goog… en       One … "<div>\n  One… http…
#> 5 Ronp… <NA>        2019-05-23T… Pizz… en       Is i… "<div> \n <sp… http…
#> # … with 3,095 more rows, and 18 more variables: elements <list>,
#> #   score <dbl>, website.name <chr>, website.hostName <chr>,
#> #   website.domainName <chr>, website.iconURL <chr>,
#> #   website.countryName <chr>, website.countryCode <chr>,
#> #   website.region <lgl>, metadata.readTime.type <chr>,
#> #   metadata.readTime.seconds <int>, metadata.category.type <chr>,
#> #   metadata.category.country <chr>, metadata.category.region <chr>,
#> #   metadata.category.category <chr>, metadata.category.countryCode <chr>,
#> #   metadata.finSentiment.type <chr>,
#> #   metadata.finSentiment.sentiment <dbl>

get_news("Google", from = "2019-05-01", to = "2019-06-01")
#> # A tibble: 3,200 x 26
#>   id    publishDate discoverDate title language text  structuredText url  
#>   <chr> <chr>       <chr>        <chr> <chr>    <chr> <chr>          <chr>
#> 1 29nG… 2019-05-02… 2019-05-02T… How … en       "Goo… "<div> \n <p>… http…
#> 2 jAgI… 2019-05-02… 2019-05-02T… How … en       Goog… "<div> \n <p>… http…
#> 3 uDVD… 2019-05-01… 2019-05-01T… Goog… en       "Goo… "<div> \n <p>… http…
#> 4 tkYy… <NA>        2019-05-02T… Goog… en       "Bot… "<div> \n <p>… http…
#> 5 MieF… 2019-05-01… 2019-05-01T… Walm… en       Lead… "<p>Leading u… http…
#> # … with 3,195 more rows, and 18 more variables: elements <list>,
#> #   score <dbl>, website.name <chr>, website.hostName <chr>,
#> #   website.domainName <chr>, website.iconURL <chr>,
#> #   website.countryName <chr>, website.countryCode <chr>,
#> #   website.region <chr>, metadata.readTime.type <chr>,
#> #   metadata.readTime.seconds <int>, metadata.finSentiment.type <chr>,
#> #   metadata.finSentiment.sentiment <dbl>, metadata.category.type <chr>,
#> #   metadata.category.country <chr>, metadata.category.region <chr>,
#> #   metadata.category.category <chr>, metadata.category.countryCode <chr>

get_news("title:Google AND text:\"Google Cloud\"", language = "it")
#> # A tibble: 2,774 x 24
#>   id    publishDate discoverDate title language text  structuredText url  
#>   <chr> <chr>       <chr>        <chr> <chr>    <chr> <chr>          <chr>
#> 1 6fRj… 2019-05-23… 2019-05-23T… SAP … it       SAP … "<span> <p><a… http…
#> 2 t98A… 2019-05-23… 2019-05-23T… Goog… it       Con … "<p>Con l’arr… http…
#> 3 72ZT… 2019-05-23… 2019-05-23T… Sams… it       Sams… "<p>Samsung a… http…
#> 4 eOHQ… 2019-05-23… 2019-05-23T… Adob… it       Disp… "<div> \n <p>… http…
#> 5 GBty… 2019-05-23… 2019-05-23T… Veea… it       Veea… "<div> \n <p>… http…
#> # … with 2,769 more rows, and 16 more variables: elements <list>,
#> #   score <dbl>, website.name <chr>, website.hostName <chr>,
#> #   website.domainName <chr>, website.iconURL <chr>,
#> #   website.countryName <chr>, website.countryCode <chr>,
#> #   website.region <lgl>, metadata.readTime.type <chr>,
#> #   metadata.readTime.seconds <int>, metadata.category.type <chr>,
#> #   metadata.category.country <chr>, metadata.category.region <chr>,
#> #   metadata.category.category <chr>, metadata.category.countryCode <chr>
```

### Cleaning news

The `clean_news()` function wrangles the messy data fetched by
get\_news, returning a tidy tibble with sensible defaults.

``` r
news <- get_news(query = "Google")

clean_news(news)
#> # A tibble: 89 x 4
#>   text                  title                discoverDate website.domainNa…
#>   <chr>                 <chr>                <date>       <chr>            
#> 1 google is not just t… how google collects… 2019-05-23   practicalecommer…
#> 2 google has officiall… google releases gro… 2019-05-24   bgr.in           
#> 3 it was more than a y… google pay and assi… 2019-05-23   slashgear.com    
#> 4 one of the things go… google search, maps… 2019-05-24   ubergizmo.com    
#> 5 google’s radical new… google rolls out ra… 2019-05-23   forbes.com       
#> # … with 84 more rows
```

## Getting help

If you encounter a clear bug, please file a minimal reproducible example
in [issues](https://github.com/MikeJohnPage/newsrivr/issues).
