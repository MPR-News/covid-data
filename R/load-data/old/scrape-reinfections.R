if(!exists("current_report_date")) {source(here("R/scraping-setup.R"))}

reinfections <- bind_rows(read_csv(here("data/reinfections.csv"), guess_max = 100000), 
						  situation_report %>%
							html_nodes(xpath = '//*[@id="casetablero"]') %>%
							html_table() %>%
							purrr::pluck(1) %>%
							set_names("date", "reinfections_confirmed", "reinfections_probable", "total_reinfections") %>%
							mutate(date = mdy(date)) %>%
							mutate(across(contains("reinfections"), ~str_remove_all(., ",") %>% as.numeric())) %>%
							mutate(report_date = current_report_date) %>%
							mutate(across(is.numeric, replace_na, 0)) %>%
							mutate(new_reinfections = reinfections_confirmed + reinfections_probable)) %>%
	distinct(date, report_date, .keep_all = TRUE) %>%
	group_by(date) %>%
	mutate(newly_reported_reinf = new_reinfections - lag(new_reinfections)) %>% 
	mutate(newly_reported_reinf = coalesce(newly_reported_reinf, new_reinfections)) %>%
	ungroup() %>%
	write_csv(here("data/reinfections.csv"))