if(!exists("current_report_date")) {source(here("R/scraping-setup.R"))}

hospitals <- situation_report %>%
	html_nodes(xpath = '//*[@id="hosptable"]') %>%
	html_table(fill = TRUE) %>%
	purrr::pluck(1) %>%
	set_names("date", "new_icu", "new_hosp", "total_hosp", "total_icu") %>%
	filter(!is.na(date)) %>%
	mutate(date = mdy(date)) %>%
	mutate(report_date = today()) %>%
	mutate(across(2:5, ~str_remove_all(., ",") %>% as.numeric())) %>%
	mutate(new_nonicu = new_hosp - new_icu) %>%
	mutate(new_icu_7day = rollmean(new_icu, 7, align = "right", fill = NA),
		   new_nonicu_7day = rollmean(new_nonicu, 7, align = "right", fill = NA)) %>%
	bind_rows(read_csv(here("data/hospitalizations.csv"), guess_max = 100000) %>% mutate(across(contains("date"), ~as_date(.)))) %>%
	distinct(date, report_date, .keep_all = TRUE) %>%
	filter(!is.na(date)) %>%
	group_by(date) %>%
	arrange(report_date) %>%
	mutate(newly_reported_hosp = new_hosp - lag(new_hosp)) %>% 
	mutate(newly_reported_hosp = coalesce(newly_reported_hosp, new_hosp)) %>%
	ungroup()
write_csv(hospitals, here("data/hospitalizations.csv"))