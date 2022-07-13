if(!exists("current_report_date")) {source(here("R/scraping-setup.R"))}

cases_total <- "https://www.health.state.mn.us/diseases/coronavirus/stats/c7day.csv" %>% 
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8") %>%
	mutate(report_date = current_report_date,
		   date = mdy(date)) %>%
	rename("new_cases" = case_count,
		   "new_cases_7day" = cases) %>%
	write_csv(here("data/cases_total.csv"))

cases_county <- "https://www.health.state.mn.us/diseases/coronavirus/stats/ccounty.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8") %>%
	separate(spec_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), anydate)) %>%
	rename("new_cases" = case_count,
		   "new_cases_percap" = rate) %>%
	mutate(report_date = current_report_date) %>%
	write_csv(here("data/cases_county.csv"))

cases_age <- "https://www.health.state.mn.us/diseases/coronavirus/stats/cage.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8") %>%
	separate(spec_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), anydate)) %>%
	rename("new_cases" = case_count,
		   "new_cases_percap" = rate) %>%
	mutate(age_group = fct_relevel(age_group, "0-4", "5-11", "12-17", "18-49", "50-64", "65+")) %>%
	mutate(report_date = current_report_date) %>%
	write_csv(here("data/cases_age.csv"))

cases_sex <- "https://www.health.state.mn.us/diseases/coronavirus/stats/csex.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8") %>%
	separate(spec_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), anydate)) %>%
	rename("new_cases" = case_count,
		   "new_cases_percap" = rate) %>%
	mutate(report_date = current_report_date) %>%
	write_csv(here("data/cases_sex.csv"))

cases_race <- "https://www.health.state.mn.us/diseases/coronavirus/stats/crace.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8") %>%
	separate(spec_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), anydate)) %>%
	rename("new_cases" = case_count,
		   "new_cases_percap" = rate) %>%
	mutate(report_date = current_report_date) %>%
	write_csv(here("data/cases_race.csv"))

variants <- "https://www.health.state.mn.us/diseases/coronavirus/stats/cvariant.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8") %>%
	separate(spec_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), anydate)) %>%
	rename("new_cases" = case_count) %>%
	mutate(report_date = current_report_date) %>%
	write_csv(here("data/variants.csv"))