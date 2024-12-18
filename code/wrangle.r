#1. Install necessary packages
# install.packages("httr2")
# install.packages("jsonlite")
# install.packages("ggthemes")

# For this to work, please set the working directory to the `code` folder.

library(tidyverse)
library(janitor)
library(httr2)
library(jsonlite)
library(dplyr)
library(lubridate)
library(ggthemes)


#1. Load necessary dataset
#Population
pop_2020_2023 <- read.csv("../raw-data/2020-2023_US_POP_by_State.csv")
pop_2024 <- read.csv("../raw-data/2024_US_POP_by_State.csv")

head(pop_2020_2023)
head(pop_2024)

##Arrange population dataset
pop_2020_2023 <- pop_2020_2023|>
  rename(state = NAME,
         '2020' = POPESTIMATE2020,
         '2021' = POPESTIMATE2021,
         '2022' = POPESTIMATE2022,
         '2023' = POPESTIMATE2023)|>
  select(state, '2020', '2021', '2022', '2023')
  
pop_2024 <- pop_2024|>
  rename(state = US.State,
         '2024' = Population.2024)|>
  select(state, '2024')
   
##Check the state differences
setdiff(pop_2020_2023$state, pop_2024$state)

##Combine the two population datasets:

##pop_2020_2023 and pop_2024 have some differences on the state data. 
##pop_combined_common includes only common states
pop_combined_common <- inner_join(pop_2020_2023, pop_2024, by = "state") 
pop_combined_common <- pop_combined_common|>
  mutate(state = state.abb[match(state, state.name)])
  
head(pop_combined_common)

##pop_combined_all includes all states 
pop_combined_all <- full_join(pop_2020_2023, pop_2024, by = "state")
pop_combined_all <- pop_combined_all|>
  mutate(state = state.abb[match(state, state.name)])|>
  mutate(state = case_when(
    state == "District of Columbia" ~ "DC",
    state == "Puerto Rico" ~ "PR",
    .default = state))|>
  filter(!is.na(state)) # exulce state with NA value because they don't have matching abbreviation

head(pop_combined_all)

# TODO: both tables contain all the same data, so we can probably delete one
all.equal(pop_combined_all, pop_combined_common)
# |> TRUE

#COVID19 cases
#online source
covid_death <- read_csv("../raw-data/COVID19_death.csv")

# this file is downloaded from the internet using `download_case_data.r`
# run that file to update this data
cases_raw <- read_csv("../raw-data/COVID19_cases.csv")

cases <- cases_raw|>
  mutate(cases = as.numeric(new_cases),
         date = as_date(ymd_hms(end_date)))|>
  filter(state %in% pop_combined_common$state)|> #can switch to pop_combined_all
  select(state, date, cases)|>
  arrange(state, date)

head(cases)

#Combine COVID19 cases and population 2020-2024 dataset
pop_combined_common <- pop_combined_common|>
  pivot_longer(cols = '2020':'2024', 
               names_to = "year",
               values_to = "population")|>
  mutate(year = as.integer(year))
  
cases_population <- cases|>
  mutate(year = year(date))|>
  group_by(state, year)|>
  summarise(cases_total = sum(cases), .groups = 'drop')|>
  left_join(pop_combined_common, by=c("state", "year")) # TODO: only contains cases 2020-2023, needs to find 2024 cases

#Total COVID19 deaths by state each year from 2020 to 2024
covid_death <- read_csv("../raw-data/COVID19_death.csv")

covid_death <- covid_death|>
  rename(start_date = `Start Date`,
         end_date = `End Date`,
         covid_deaths = `COVID-19 Deaths`,
         mmwr_week = `MMWR Week`,
         state = State,
         total_death = `Total Deaths`)|>
  mutate(start_date = mdy(start_date),
         end_date = mdy(end_date))|>
  mutate(year = year(start_date))|>
  filter(year>2019)|>
  mutate(state = state.abb[match(state, state.name)],
         state = case_when(
           state == "District of Columbia" ~ "DC",
           state == "Puerto Rico" ~ "PR",
           .default = state))|>
  filter(state %in% pop_combined_common$state) #or pop_combined_all

#COVID19 deaths by state with only year, state, and total deaths
covid_death_total_state <- covid_death|>
  group_by(year, state)|>
  summarise(total_death = sum(covid_deaths, na.rm = TRUE),
            .groups = 'drop')

##Total COVID19 deaths from 2020 to 2024
covid_death_total<- covid_death_total_state|>
  group_by(year)|>
  summarise(total_death = sum(total_death, na.rm = TRUE))

#Combine COVID19 death and population by state 2020-2024
##With cases
covid_death_total_state_pop <- covid_death_total_state|>
  left_join(cases_population, by=c("state", "year"))|>
  mutate(total_death = as.numeric(total_death),
         population = as.numeric(population),
         death_rate_per_100k = (total_death / population)*100000
         )|>
  filter(!is.na(death_rate_per_100k)) ##missing 2024 because no case data for 2024

##Without cases because no 2024 case dataset
covid_death_total_state_pop <- covid_death_total_state|>
  left_join(pop_combined_common, by=c("year", "state"))|>
  mutate(death_rate_per_100k =(total_death/population)*1e5)|>
  filter(!is.na(death_rate_per_100k))
    
ggplot(covid_death_total_state_pop, 
       aes(x = year, y = death_rate_per_100k, color = state)) +
  geom_line() +
  geom_point() +
  labs(
    title = "COVID-19 Death Rate per 100,000 People Over Time by State",
    x = "Year",
    y = "Death Rate (per 100,000)",
    color = "State"
  )
  
#5.Excess death
covid_death_excess <- covid_death|>
  group_by(state, mmwr_week)|>
  summarise(expected_deaths = mean(total_death, na.rm = TRUE),
            expected_covid_deaths = mean(covid_deaths, na.rm = TRUE),
            .groups = 'drop')|>
  mutate(excess_mortality = expected_deaths-expected_covid_deaths)
