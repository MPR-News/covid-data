if(!exists("current_report_date")) {source(here("R/scraping-setup.R"))}

age_table <- bind_rows(read_csv(here("data/demographics/age_table.csv")),
					   situation_report %>%
					   	html_nodes(xpath = '//*[@id="ageg"]/div/table') %>%
					   	html_table() %>%
					   	purrr::pluck(1) %>%
					   	set_names("age_group", "cases", "deaths") %>%
					   	mutate(date = as_date(current_report_date)) %>%
					   	mutate(across(cases:deaths, ~str_remove_all(., ",") %>% as.numeric()))) %>%
	distinct(date, age_group, .keep_all = TRUE) %>%
	write_csv(here("data/demographics/age_table.csv"))

race_table <- bind_rows(read_csv(here("data/demographics/race_table.csv"), guess_max = 100000), 
						situation_report %>%
							html_nodes(xpath = '//*[@id="raceethtable"]') %>%
							html_table() %>%
							magrittr::extract2(1) %>%
							slice(1:8) %>%
							set_names(c("race", "cases", "deaths")) %>%
							select(-deaths) %>%
							mutate(cases = str_remove_all(cases, ",") %>% as.numeric()) %>%
							mutate(race = str_remove_all(race, ", non-Hispanic")) %>%
							mutate(race = str_replace_all(race, "American Indian/ Alaska Native", "Native") %>%
								   	str_replace_all("Native Hawaiian/ Pacific Islander|Multiple races", "Other") %>%
								   	str_replace_all("Unknown/missing", "Unknown")) %>%
							group_by(race) %>%
							summarize(cases = sum(cases)) %>%
							transmute(race, date = current_report_date, cases) %>%
							left_join(read_csv(here("data-input/race-pop.csv")),
									  by = "race")) %>% 
	distinct(date, race, .keep_all = TRUE) %>%
	write_csv(here("data/demographics/race_table.csv"))

race_table_processed <- race_table %>%
	mutate(lag_date = date - 7) %>%
	left_join(x = .,
			  y = {.} %>% select(date, race, lag_cases = cases),
			  by = c("lag_date" = "date", "race")) %>%
	mutate(new_cases_percap_7day = ((cases - lag_cases) / 7) / (pop / 100000)) %>%
	filter(!is.na(new_cases_percap_7day))

# readxl::read_excel("/Users/la-dmontgomery/Dropbox/projects/diseases/data/demographics/webpostdate by raceeth 10052020.xlsx", skip = 2) %>%
# 	mutate(date = excel_numeric_to_date(as.numeric(web_post_date))) %>%
# 	select(-web_post_date) %>%
# 	filter(!is.na(date)) %>%
# 	pivot_longer(-date, names_to = "race", values_to = "new_cases") %>%
# 	filter(race != "Total", race != "Unknown/Pending") %>%
# 	mutate(race = fct_collapse(race,
# 							   "White" = "White, Non-Hispanic",
# 							   "Black" = "Black, Non-Hispanic",
# 							   "Asian" = "Asian, Non-Hispanic",
# 							   "Native" = "American Indian/Alaskan Native, Non-Hispanic",
# 							   "Hispanic" = "Hispanic",
# 							   other_level = "Other")) %>%
# 	group_by(race, date) %>%
# 	summarize(new_cases = sum(new_cases)) %>%
# 	arrange(date) %>%
# 	mutate(cases = cumsum(new_cases)) %>%
# 	select(-new_cases) %>%
# 	bind_rows(read_csv(here("data/demographics/race_table.csv")) %>%
# 			  	pivot_longer(-race, names_to = "date", names_prefix = "cases", values_to = "cases") %>%
# 			  	mutate(date = ymd(date)) %>%
# 			  	mutate(race = str_remove_all(race, " American")) %>%
# 			  	arrange(date) %>%
# 			  	group_by(race)) %>%
# 	distinct(date, race, .keep_all = TRUE) %>%
# 	write_csv(here("data/demographics/race_table.csv"))
