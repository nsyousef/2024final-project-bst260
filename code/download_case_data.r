library(httr2)

# please make sure the working directory is set to the `code` folder before running this file
# use setwd("code")

#from pset4
api <- "https://data.cdc.gov/resource/pwn4-m3yp.json"
cases_raw <- request(api) |>
  req_url_query("$limit" = 10000000) |>
  req_perform() |>
  resp_body_json(simplifyVector = TRUE)

head(cases_raw)

write.csv(cases_raw, "../raw-data/COVID19_cases.csv", row.names = FALSE)
