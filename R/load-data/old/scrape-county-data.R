library(tidyverse)
library(lubridate)
library(rvest)
library(here)

if(!exists("current_report_date")) {source(here("R/scraping-setup.R"))}

county_data <- situation_report %>%
	html_nodes(xpath = '//*[@id="maptable"]') %>%
	html_table() %>%
	purrr::pluck(1) %>%
	set_names("county", "cases_confirmed", "cases_probable", "cases", "deaths") %>%
	mutate(date = current_report_date) %>%
	mutate(county = str_to_title(county)) %>%
	mutate(county = str_remove_all(county, " County") %>% str_squish()) %>%
	select(-cases_confirmed, -cases_probable) %>%
	mutate(across(c(cases, deaths), parse_number)) %>%
	mutate(join_county = str_to_upper(county)) %>%
	left_join(read_csv(here("data-input/mn-county-pop.csv")) %>% 
			  	select(county, geoid, region, pop),
			  by = c("join_county" = "county")) %>%
	select(date, geoid, county, region, pop, cases, deaths) %>%
	filter(!is.na(geoid))
write_csv(county_data, paste0(here("data/county-data/mn_county_data"), current_report_date, ".csv"))
 
combined_county_data <- read_csv(here("data/combined_county_data.csv"), guess_max = 100000) %>% 
	bind_rows(county_data) %>% 
	arrange(date, county) %>%
	distinct(date, geoid, .keep_all = TRUE) %>%
	mutate(county = case_when(county == "Mcleod" ~ "McLeod",
							  county == "Lac Qui Parle" ~ "Lac qui Parle",
							  county == "Lake Of The Woods" ~ "Lake of the Woods",
							   TRUE ~ county)) %>%
	mutate(geoid = as.character(geoid)) %>%
	write_csv(here("data/combined_county_data.csv"))

combined_county_wide <- combined_county_data %>%
 	mutate(county = str_to_title(county), date = format(date, "%Y%m%d")) %>%
	group_by(county) %>%
	arrange(desc(date)) %>%
	pivot_wider(values_from = cases:deaths, names_from = date, names_sep = "") %>%
	janitor::remove_empty("cols") %>%
	select(geoid, county, region, pop, everything()) %>%
	write_csv(here("data/combined_county_data_wide.csv"))
