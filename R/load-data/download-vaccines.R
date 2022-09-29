if(!exists("date_parser")) {source(here("R/helper-functions.R"))}

is_captcha <- FALSE

vaccine_doses <- url_picker("vaccine_doses", is_captcha) %>%
	GET(user_agent(user_agent)) %>%
	content(encoding = "UTF-8") %>%
	set_names("category", "doses", "filed_date", "report_date") %>%
	mutate(filed_date = mdy(filed_date),
		   report_date = date_parser(report_date)) %>%
	bind_rows(read_csv(here("data/vaccine-data/total-doses.csv")) %>%
			  	# rename("filed_date" = "actual_date") %>%
			  	mutate(across(contains("date"), as_date))) %>%
	distinct(category, report_date, .keep_all = TRUE) %>%
	write_csv(here("data/vaccine-data/total-doses.csv"))

vaccine_age <- url_picker("vaccine_age", is_captcha) %>%
	GET(user_agent(user_agent)) %>% 	content(encoding = "UTF-8") %>%
	set_names("age", "doses", "filed_date", "report_date") %>%
	mutate(filed_date = mdy(filed_date),
		   report_date = date_parser(report_date)) %>%
	mutate(age = case_when(age == "15-Dec" ~ "12-15",
						   age == "11-May" ~ "5-11",
						   TRUE ~ age)) %>%
	bind_rows(read_csv(here("data/vaccine-data/vaccine_age.csv")) %>%
			  	# rename("filed_date" = "actual_date") %>%
			  	mutate(across(contains("date"), as_date))) %>%
	distinct(age, report_date, .keep_all = TRUE) %>%
	filter(!is.na(report_date)) %>%
	write_csv(here("data/vaccine-data/vaccine_age.csv"))

vaccine_gender <- url_picker("vaccine_gender", is_captcha) %>%
	GET(user_agent(user_agent)) %>% 	content(encoding = "UTF-8") %>%
	set_names("gender", "doses", "filed_date", "report_date") %>%
	mutate(filed_date = mdy(filed_date),
		   report_date = date_parser(report_date)) %>%
	bind_rows(read_csv(here("data/vaccine-data/vaccine_gender.csv")) %>%
			  	# rename("filed_date" = "actual_date") %>%
			  	mutate(across(contains("date"), as_date))) %>%
	distinct(gender, report_date, .keep_all = TRUE) %>%
	filter(!is.na(report_date)) %>%
	write_csv(here("data/vaccine-data/vaccine_gender.csv"))

vaccine_providers <- url_picker("vaccine_providers", is_captcha) %>%
	GET(user_agent(user_agent)) %>% 	content(encoding = "UTF-8") %>%
	set_names("provider", "doses", "filed_date", "report_date") %>%
	mutate(filed_date = mdy(filed_date),
		   report_date = date_parser(report_date)) %>%
	bind_rows(read_csv(here("data/vaccine-data/vaccine_provider.csv")) %>%
			  	# rename("filed_date" = "actual_date") %>%
			  	mutate(across(contains("date"), as_date))) %>%
	distinct(provider, report_date, .keep_all = TRUE) %>%
	filter(!is.na(report_date)) %>%
	write_csv(here("data/vaccine-data/vaccine_provider.csv"))

vaccine_1x_county <- url_picker("vaccine_1x_county", is_captcha) %>%
	GET(user_agent(user_agent)) %>% 	
	content(encoding = "UTF-8") %>%
	select(1:6) %>%
	set_names("county", "people_onedose", "people_complete", "people_boosted", "filed_date", "report_date") %>%
	mutate(filed_date = mdy(filed_date),
		   report_date = date_parser(report_date)) %>%
	bind_rows(read_csv(here("data/vaccine-data/vaccine-1dose-county.csv")) %>%
			  	# rename("filed_date" = "actual_date") %>%
			  	mutate(across(contains("date"), as_date))) %>%
	distinct(county, report_date, .keep_all = TRUE) %>%
	filter(!is.na(report_date)) %>%
	write_csv(here("data/vaccine-data/vaccine-1dose-county.csv"))

vaccine_1x_age <- url_picker("vaccine_1x_age", is_captcha) %>%
	GET(user_agent(user_agent)) %>% 	content(encoding = "UTF-8") %>%
	set_names("age", "people_onedose", "people_complete", "people_boosted", "filed_date", "report_date") %>%
	mutate(filed_date = mdy(filed_date),
		   report_date = date_parser(report_date)) %>%
	mutate(age = case_when(age == "15-Dec" ~ "12-15",
						   age == "11-May" ~ "5-11",
						   TRUE ~ age)) %>%
	bind_rows(read_csv(here("data/vaccine-data/vaccine-1dose-age.csv")) %>%
			  	# rename("filed_date" = "actual_date") %>%
			  	mutate(across(contains("date"), date_parser))) %>%
	distinct(age, report_date, .keep_all = TRUE) %>%
	filter(!is.na(report_date)) %>%
	write_csv(here("data/vaccine-data/vaccine-1dose-age.csv"))

vaccine_1x_gender <- url_picker("vaccine_1x_gender", is_captcha) %>%
	GET(user_agent(user_agent)) %>% 	content(encoding = "UTF-8") %>%
	set_names("gender", "people_onedose", "people_complete", "people_boosted", "filed_date", "report_date") %>%
	mutate(filed_date = mdy(filed_date),
		   report_date = date_parser(report_date)) %>%
	bind_rows(read_csv(here("data/vaccine-data/vaccine-1dose-gender.csv")) %>%
			  	# rename("filed_date" = "actual_date") %>%
			  	mutate(across(contains("date"), as_date))) %>%
	distinct(gender, report_date, .keep_all = TRUE) %>%
	filter(!is.na(report_date)) %>%
	write_csv(here("data/vaccine-data/vaccine-1dose-gender.csv"))

# doses_shipped <- url_picker("doses_shipped", is_captcha) %>%
# 	GET(user_agent(user_agent)) %>% 	content(encoding = "UTF-8") %>%
# 	set_names("product", "doses_shipped", "filed_date", "report_date") %>%
# 	mutate(filed_date = mdy(filed_date),
# 		   report_date = date_parser(report_date)) %>%
# 	mutate(is_ltc = "General population") %>%
# 	bind_rows(url_picker("doses_shipped", is_captcha, TRUE) %>%
# 			  	GET(user_agent(user_agent)) %>% 	content(encoding = "UTF-8") %>%
# 			set_names("product", "doses_shipped", "filed_date", "report_date") %>%
# 			mutate(filed_date = mdy(filed_date)) %>%
# 			mutate(report_date = as_date(report_date)) %>%
# 			mutate(is_ltc = "Long-term care")) %>%
# 	bind_rows(read_csv(here("data/vaccine-data/doses-shipped.csv"))) %>%
# 	distinct(product, report_date, is_ltc, .keep_all = TRUE) %>%
# 	write_csv(here("data/vaccine-data/doses-shipped.csv"))

vaccine_1x_age_county <- url_picker("vaccine_1x_age_county", is_captcha) %>%
	GET(user_agent(user_agent)) %>% 	
	content(encoding = "UTF-8") %>%
	select(1:7) %>%
	set_names("county", "percent_onedose", "percent_completed", "percent_boosted", "age", "filed_date", "report_date") %>%
	mutate(across(contains("percent"), ~as.character(.) %>% parse_number() / 100)) %>%
	mutate(filed_date = date_parser(filed_date),
		   report_date = date_parser(report_date)) %>%
	bind_rows(read_csv(here("data/vaccine-data/vaccine-1dose-age-county.csv")) %>%
			  	# rename("filed_date" = "date_as_of") %>%
			  	# mutate(across(percent_completed:percent_boosted, ~parse_number(.) / 100)) %>%
			  	mutate(report_date = as_date(report_date))) %>%
	distinct(county, age, report_date, .keep_all = TRUE) %>%
	write_csv(here("data/vaccine-data/vaccine-1dose-age-county.csv"))

vaccine_race <- url_picker("vaccine_race", is_captcha) %>%
	GET(user_agent(user_agent)) %>% 	
	content(encoding = "UTF-8") %>%
	janitor::clean_names() %>%
	mutate(web_date = date_parser(web_date)) %>%
	mutate(across(white:hispanic, ~as.character(.) %>% parse_number() / 100)) %>%
	bind_rows(read_csv(here("data/vaccine-data/vaccine-race.csv"))) %>%
	distinct(age_group, year, week, case_definition, .keep_all = TRUE) %>%
	write_csv(here("data/vaccine-data/vaccine-race.csv"))

vaccine_race_progress <- url_picker("vaccine_race_progress", is_captcha) %>%
	GET(user_agent(user_agent)) %>% 	
	content(encoding = "UTF-8") %>%
	janitor::clean_names() %>%
	mutate(web_date = date_parser(web_date)) %>%
	mutate(across(white:hispanic, ~as.character(.) %>% parse_number() / 100)) %>%
	distinct(age_group, year, week, case_definition, .keep_all = TRUE) %>%
	write_csv(here("data/vaccine-data/vaccine-race-progress.csv"))

vaccine_zip <- url_picker("vaccine_zip", is_captcha) %>%
	GET(user_agent(user_agent)) %>% 	
	content(encoding = "UTF-8") %>%
	set_names("zip", "people_onedose", "people_complete", "people_boosted", "filed_date", "report_date") %>%
	mutate(people_onedose = case_when(people_onedose == "<=5" ~ "5", TRUE ~ people_onedose) %>% as.numeric(),
		   people_complete = case_when(people_complete == "<=5" ~ "5", TRUE ~ people_complete) %>% as.numeric()) %>%
	mutate(report_date = date_parser(report_date)) %>%
	bind_rows(read_csv(here("data/vaccine-data/vaccine-zip.csv"), col_types = cols(zip = col_character()))) %>%
	distinct(zip, report_date, .keep_all = TRUE) %>%
	write_csv(here("data/vaccine-data/vaccine-zip.csv"))
