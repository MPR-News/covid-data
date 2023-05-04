if(!exists("current_report_date")) {source(here("R/scraping-setup.R"))}

hosp_total <- "https://www.health.state.mn.us/diseases/coronavirus/stats/h7day.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	mutate(across(contains("date"), anydate)) %>%
	mutate(report_date = current_report_date) %>%
	rename("new_hosp" = case_count,
		   "new_hosp_percap" = rate) %>%
	write_csv(here("data/hosp_total.csv")) 

hosp_county <- "https://www.health.state.mn.us/diseases/coronavirus/stats/hcounty.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	separate(adm_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), mdy)) %>%
	mutate(report_date = current_report_date) %>%
	rename("new_hosp" = case_count,
		   "new_hosp_percap" = rate) %>%
	write_csv(here("data/hosp_county.csv")) 

hosp_age <- "https://www.health.state.mn.us/diseases/coronavirus/stats/hage.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	separate(adm_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), mdy)) %>%
	mutate(report_date = current_report_date) %>%
	rename("new_hosp" = case_count,
		   "new_hosp_percap" = rate) %>%
	write_csv(here("data/hosp_age.csv")) 

hosp_sex <- "https://www.health.state.mn.us/diseases/coronavirus/stats/hsex.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	separate(adm_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), mdy)) %>%
	mutate(report_date = current_report_date) %>%
	rename("new_hosp" = case_count,
		   "new_hosp_percap" = rate) %>%
	write_csv(here("data/hosp_sex.csv")) 

hosp_race <- "https://www.health.state.mn.us/diseases/coronavirus/stats/hrace.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	separate(adm_date_mmwr, c("year", "week"), sep = 4, convert = TRUE) %>%
	mutate(across(contains("date"), mdy)) %>%
	mutate(report_date = current_report_date) %>%
	rename("new_hosp" = case_count,
		   "new_hosp_percap" = rate) %>%
	write_csv(here("data/hosp_race.csv")) 

hosp_beds <- "https://www.health.state.mn.us/diseases/coronavirus/stats/hcdsource.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	mutate(date = date_parser(date)) %>%
	mutate(report_date = current_report_date) %>%
	write_csv(here("data/hosp_beds.csv")) 

hosp_bed_avail <- "https://www.health.state.mn.us/diseases/coronavirus/stats/hcapacity.csv" %>%
	GET(user_agent(user_agent)) %>% 
	content(encoding = "UTF-8", type = "text/csv") %>%
	janitor::clean_names() %>%
	mutate(date = mdy(date)) %>%
	mutate(report_date = current_report_date) %>%
	write_csv(here("data/hosp_bed_avail.csv")) 
