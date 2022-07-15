if(!exists("current_report_date")) {source(here("R/scraping-setup.R"))}

deaths <- bind_rows(read_csv(here("data/death_date_table.csv"), guess_max = 100000),
					situation_report %>%
						html_nodes(xpath = '//*[@id="deathtable"]') %>%
						html_table(fill = TRUE) %>%
						purrr::pluck(1) %>%
						set_names("death_date", "new_deaths", "total_deaths") %>%
						mutate(death_date = mdy(death_date)) %>%
						mutate(across(contains("deaths"), ~str_remove_all(., ",") %>% as.numeric() %>% replace_na(0))) %>%
						mutate(report_date = current_report_date)) %>%
	distinct(death_date, report_date, .keep_all = TRUE) %>%
	group_by(death_date) %>%
	mutate(newly_reported_deaths = new_deaths - lag(new_deaths)) %>% 
	mutate(newly_reported_deaths = coalesce(newly_reported_deaths, new_deaths)) %>%
	ungroup() %>%
	write_csv(here("data/death_date_table.csv"))
