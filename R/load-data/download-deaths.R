if(!exists("current_report_date")) {source(here("R/scraping-setup.R"))}

deaths_total <- "https://www.health.state.mn.us/diseases/coronavirus/stats/d7day.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	select(date, new_deaths = case_count, new_deaths_percap = rate, outcome) %>%
	mutate(report_date = current_report_date,
		   date = mdy(date)) %>%
	write_csv(here("data/deaths_total.csv")) 

deaths_county <- "https://www.health.state.mn.us/diseases/coronavirus/stats/dcounty.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	separate(death_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), mdy)) %>%
	mutate(report_date = current_report_date) %>%
	select(year, week, mmwr_startdate, mmwr_enddate, report_date, county, pop_size, new_deaths = case_count, new_deaths_7day = rate) %>%
	write_csv(here("data/deaths_county.csv")) 

deaths_age <- "https://www.health.state.mn.us/diseases/coronavirus/stats/dage.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	separate(death_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), mdy)) %>%
	mutate(report_date = current_report_date) %>%
	select(year, week, mmwr_startdate, mmwr_enddate, report_date, age_group, pop_size, new_deaths = case_count, new_deaths_7day = rate) %>%
	write_csv(here("data/deaths_age.csv")) 

deaths_sex <- "https://www.health.state.mn.us/diseases/coronavirus/stats/dsex.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	separate(death_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), mdy)) %>%
	mutate(report_date = current_report_date) %>%
	select(year, week, mmwr_startdate, mmwr_enddate, report_date, sex, pop_size, new_deaths = case_count, new_deaths_7day = rate) %>%
	write_csv(here("data/deaths_sex.csv")) 

deaths_race <- "https://www.health.state.mn.us/diseases/coronavirus/stats/drace.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	separate(death_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), mdy)) %>%
	mutate(report_date = current_report_date) %>%
	select(year, week, mmwr_startdate, mmwr_enddate, report_date, race_ethnicity, pop_size, new_deaths = case_count, new_deaths_7day = rate) %>%
	write_csv(here("data/deaths_race.csv")) 
