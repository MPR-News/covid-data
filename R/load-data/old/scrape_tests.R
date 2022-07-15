if(!exists("current_report_date")) {source(here("R/scraping-setup.R"))}

if(is.null(situation_report %>%
		   html_nodes(xpath = '//*[@id="labtable"]') %>%
		   html_table() %>%
		   purrr::pluck(1))) {
	tests_table <- read_csv(here("data/tests_table.csv"), guess_max = 100000)
} else {
	tests_table <- bind_rows(read_csv(here("data/tests_table.csv"), guess_max = 100000), 
							 situation_report %>%
							 	html_nodes(xpath = '//*[@id="labtable"]') %>%
							 	html_table() %>%
							 	purrr::pluck(1) %>%
							 	set_names("sample_date", "pcr_mdh", "pcr_external", "pcr_total", "antigen", "antigen_total", "total_tests") %>%
							 	mutate(rownum = rownames(.) %>% as.numeric()) %>%
							 	mutate(sample_date = mdy(sample_date)) %>%
							 	select(-rownum) %>%
							 	mutate(report_date = current_report_date) %>%
							 	mutate(across(pcr_mdh:total_tests, ~str_remove_all(., ",") %>% as.numeric())) %>%
							 	mutate(across(antigen:antigen_total, replace_na, 0)) %>%
							 	mutate(new_tests = total_tests - lag(total_tests))) %>%
		distinct(sample_date, report_date, .keep_all = TRUE) %>%
		group_by(sample_date) %>%
		mutate(newly_reported_tests = new_tests - lag(new_tests)) %>% 
		mutate(newly_reported_tests = coalesce(newly_reported_tests, new_tests)) %>%
		ungroup()
}

write_csv(tests_table, here("data/tests_table.csv"))
