if(!exists("current_report_date")) {source(here("R/scraping-setup.R"))}

case_table <- bind_rows(read_csv(here("data/cases_sample_date.csv"), guess_max = 100000), 
						situation_report %>%
							html_nodes(xpath = '//*[@id="casetable"]') %>%
							html_table() %>%
							purrr::pluck(1) %>%
							set_names("date", "new_cases_confirmed", "total_cases_confirmed", "new_cases_probable", "total_cases_probable", "total_cases") %>%
							mutate(date = mdy(date)) %>%
							mutate(across(contains("cases"), ~str_remove_all(., ",") %>% as.numeric())) %>%
							mutate(report_date = current_report_date) %>%
							mutate(across(new_cases_probable:total_cases_probable, replace_na, 0)) %>%
							mutate(new_cases = new_cases_confirmed + new_cases_probable)) %>%
	distinct(date, report_date, .keep_all = TRUE) %>%
	group_by(date) %>%
	mutate(newly_reported_cases = new_cases - lag(new_cases)) %>% 
	mutate(newly_reported_cases = coalesce(newly_reported_cases, new_cases)) %>%
	ungroup() %>%
	write_csv(here("data/cases_sample_date.csv"))
