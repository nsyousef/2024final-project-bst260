#Data Wrangling

# Set the working directory to the `code` folder before running this file.

library(dplyr)
library(tidyr)
library(lubridate)
library(httr2)
library(readr)
library(stringr)
library(ggplot2)

#1. Population Data Set
#2020-2023 population by state
pop_2020_2023 <- read.csv("../raw-data/2020-2023_US_POP_by_State.csv")
#2024 population by state
pop_2024 <- read.csv("../raw-data/2024_US_POP_by_State.csv")

##Arrange each population dataset
pop_2020_2023 <- pop_2020_2023 |>
  rename(
    state = NAME,
    '2020' = POPESTIMATE2020,
    '2021' = POPESTIMATE2021,
    '2022' = POPESTIMATE2022,
    '2023' = POPESTIMATE2023
  ) |>
  select(state, '2020', '2021', '2022', '2023')

pop_2024 <- pop_2024 |>
  rename(state = US.State, '2024' = Population.2024) |>
  select(state, '2024')

##Combine the two population datasets:
pop_all <- full_join(pop_2020_2023, pop_2024, by = "state")
pop_all$"2024" <- ifelse(is.na(pop_all$"2024"), pop_all$"2023", pop_all$"2024") #if population is NA for 2024, use 2023 population
pop_all <- pop_all |>
  mutate(state = case_when(
    state == "District of Columbia" ~ "DC",
    state == "Puerto Rico" ~ "PR",
    TRUE ~ ifelse(is.na(state.abb[match(state, state.name)]), NA, state.abb[match(state, state.name)])
  )) |>
  filter(!is.na(state)) |>
  pivot_longer(
    cols = c("2020", "2021", "2022", "2023", "2024"),
    names_to = "year",
    values_to = "population"
  ) |>
  mutate(year = as.numeric(year), population = as.numeric(population))

###############################################################
#2. COVID-19 Death and Overall Death Data Set
#Total COVID19 deaths by state each year from 2020 to 2024
covid_death <- read.csv("../raw-data/COVID19_death.csv")

#Data wrangling
covid_death_clean <- covid_death |>
  filter(Group == "By Week") |> 
  rename(
    start_date = `Start.Date`,
    end_date = `End.Date`,
    covid_death = `COVID.19.Deaths`,
    week = `MMWR.Week`,
    state = State,
    total_death = `Total.Deaths`,
    percentage_expected_death = Percent.of.Expected.Deaths
  ) |>
  mutate(start_date = mdy(start_date),
         end_date = mdy(end_date)) |>
  mutate(year = year(start_date)) |>
  mutate(
    covid_death = as.numeric(covid_death),
    total_death = as.numeric(total_death),
    year = as.numeric(year),
    week = as.numeric(week)
  ) |>
  filter(year > 2019) |>
  mutate(
    state = case_when(
      state == "District of Columbia" ~ "DC",
      state == "Puerto Rico" ~ "PR",
      TRUE ~ state.abb[match(state, state.name)]
    )
  ) |>
  filter(state %in% pop_all$state) |>
  select(
    state,
    start_date,
    end_date,
    week,
    covid_death,
    total_death,
    year,
    percentage_expected_death
  )

###############################################################
#3, Combine Population and COVID-19 Cases Date Sets
deaths_population <- pop_all |>
  left_join(covid_death_clean, by = c("state", "year"))

###############################################################
#4. COVID19 Cases Data Set

# to refresh this file with new data, please run `code/download_case_data.r`
cases_raw <- read_csv("../raw-data/COVID19_cases.csv")

cases <- cases_raw |>
  mutate(
    cases = new_cases,
    date = as_date(end_date),
    year = year(date),
    week = week(date)
  ) |> # Add week number
  mutate(cases = as.numeric(cases),
         year = as.numeric(year),
         week = as.numeric(week)) |>
  rename(case_date = date) |>
  filter(state %in% pop_all$state) |>
  select(state, case_date, cases, year, week) |> # Include the week column
  arrange(state, case_date)



###############################################################
#5. Complete Dataset

<<<<<<< Updated upstream
covid <- deaths_population |>
  left_join(cases, by = c("state", "year", "week")) |>
  group_by(state, year) |>
  fill(population, .direction = "downup") |>
  ungroup() |> mutate(date = end_date) |>
  select(
    state,
    date,
    week,
    covid_death,
    total_death,
    year,
    percentage_expected_death,
    population,
    cases
  ) |> mutate(week = epiweek(date), year = epiyear(date))

# write file
write.csv(covid, file = "../data/covid_cases_deaths.csv", row.names = FALSE)
=======
covid <- covid_death_clean|>
  left_join(cases_population, by = c("state", "year", "week"))|>
  group_by(state, year)|>
  fill(population, .direction = "downup")|>
  ungroup()
>>>>>>> Stashed changes
