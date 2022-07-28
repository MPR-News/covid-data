covid_data_actual <- list(cases_total, hosp_total, deaths_total) %>%
	map(select, date, outcome, contains("new")) %>%
	map(select, !contains("7day")) %>%
	map(pivot_wider, names_from = outcome, values_from = contains("new"), names_prefix = "new_") %>%
	reduce(left_join, by = "date") %>%
	rename(new_cases = new_case, new_deaths = new_death, new_hosp = new_hospitalization) %>%
	mutate(new_nonicu = new_hosp - new_icu) %>%
	mutate(day = wday(date, label = TRUE, abbr = FALSE), .after = date) %>%
	mutate(cases_complete = case_when(date <= current_report_date - 7 ~ TRUE, TRUE ~ FALSE),
		   deaths_complete = case_when(date <= current_report_date - 21 ~ TRUE, TRUE ~ FALSE)) %>%
	write_csv(here("data/covid_data_actual.csv"))
	

covid_trends_actual <- list(cases_total, hosp_total, deaths_total) %>%
	map(select, date, outcome, contains("7day")) %>%
	map(pivot_wider, names_from = outcome, values_from = contains("new"), names_prefix = "new_") %>%
	reduce(left_join, by = "date") %>%
	rename(new_cases = new_case, new_deaths = new_death, new_hosp = new_hospitalization) %>%
	mutate(new_nonicu = new_hosp - new_icu) %>%
	mutate(day = wday(date, label = TRUE, abbr = FALSE), .after = date) %>%
	mutate(cases_complete = case_when(date <= current_report_date - 7 ~ TRUE, TRUE ~ FALSE),
		   deaths_complete = case_when(date <= current_report_date - 21 ~ TRUE, TRUE ~ FALSE)) %>%
	write_csv(here("data/covid_trends_actual.csv"))

# Archive data by report date

comp_cases_total <- bind_rows(read_csv(here("data/comp/comp_cases_total.csv")),
		  cases_total) %>%
	distinct(date, report_date, .keep_all = TRUE) %>%
	arrange(report_date, date) %>%
	group_by(date) %>%
	mutate(newly_reported_cases = new_cases - lag(new_cases)) %>%
	mutate(newly_reported_cases = coalesce(newly_reported_cases, new_cases)) %>%
	write_csv(here("data/comp/comp_cases_total.csv"))

comp_hosp_total <- bind_rows(read_csv(here("data/comp/comp_hosp_total.csv")),
							 hosp_total) %>%
	distinct(date, report_date, outcome, .keep_all = TRUE) %>%
	arrange(report_date, outcome, date) %>%
	group_by(date, outcome) %>%
	mutate(newly_reported_hosp = new_hosp - lag(new_hosp)) %>%
	mutate(newly_reported_hosp = coalesce(newly_reported_hosp, new_hosp)) %>%
	write_csv(here("data/comp/comp_hosp_total.csv"))


comp_death_total <- bind_rows(read_csv(here("data/comp/comp_deaths_total.csv")),
		  deaths_total) %>%
	distinct(date, report_date, outcome, .keep_all = TRUE) %>%
	arrange(report_date, date) %>%
	group_by(date) %>%
	mutate(newly_reported_deaths = new_deaths - lag(new_deaths)) %>%
	mutate(newly_reported_deaths = coalesce(newly_reported_deaths, new_deaths)) %>%
	write_csv(here("data/comp/comp_deaths_total.csv"))

comp_tibble %>%
	filter(!str_detect(raw_file, "total")) %>%
	select(object, comp_file, group_col) %>%
	slice(1) %>%
	pmap(process_comps)

# list(cases_total %>% 
# 	 	group_by(report_date) %>%
# 	 	summarize(new_cases = sum(new_cases)),
# 	 hosp_total %>%
# 	 	group_by(report_date, outcome) %>%
# 	 	summarize(new_hosp = sum(new_hosp)) %>%
# 	 	pivot_wider(names_from = outcome, values_from = new_hosp, names_prefix = "new_"),
# 	 deaths_total %>%
# 		group_by(report_date) %>%
# 	 	summarize(new_deaths = sum(new_deaths))) %>%
# 	reduce(left_join, by = "report_date")
# 
# 
# list(cases_total, hosp_total, deaths_total) %>%
# 	map(select, !contains("7day")) %>%
# 	map(group_by, report_date, outcome) %>%
# 	map(summarize, across(contains("new"), sum)) %>%
# 	map(pivot_wider, names_from = outcome, values_from = contains("new"), names_prefix = "new_") %>%
# 	reduce(left_join, by = "report_date") %>%
# 	rename(new_cases = new_case, new_deaths = new_death, new_hosp = new_hospitalization)
