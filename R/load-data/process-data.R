covid_totals_report <-  read_csv(here("data/covid_totals_report.csv")) %>%
	bind_rows(scrape_totals()) %>%
	mutate(across(contains("total") & where(is.character), parse_number)) %>%
	mutate(cases_removed = replace_na(cases_removed, 0)) %>%
	distinct(date, cases_removed, .keep_all = TRUE) %>%
	write_csv(here("data/covid_totals_report.csv"))

covid_data_report <- covid_totals_report %>%
	transmute(date, day,
			  # Calculate new cases with the reinfection case data where this exists, and the old data if it doesn't
			  new_cases = total_positives_reinfections - lag(total_positives_reinfections) + cases_removed,
			  new_cases = case_when(is.na(new_cases) ~ total_positives - lag(total_positives) + cases_removed, TRUE ~ new_cases),
			  new_antigen_cases = total_antigen_positives - lag(total_antigen_positives),
			  new_tests = total_tests - lag(total_tests),
			  new_antigen_tests = total_antigen_tests - lag(total_antigen_tests),
			  positivity = (new_cases / new_tests) %>% replace_na(0),
			  new_hosp = total_hosp - lag(total_hosp),
			  new_icu = total_icu - lag(total_icu),
			  new_deaths = total_deaths - lag(total_deaths),
			  new_ltc_deaths = total_ltc_deaths - lag(total_ltc_deaths),
			  new_recovered = total_recovered - lag(total_recovered),
			  new_vax_doses = total_vax_doses - lag(total_vax_doses),
			  new_vax_onedose = total_vax_onedose - lag(total_vax_onedose),
			  new_vax_complete = total_vax_complete - lag(total_vax_complete),
			  new_vax_boosted = total_booster_doses - lag(total_booster_doses),
			  active_cases = case_when(is.na(total_positives_reinfections) ~ total_positives - total_recovered - total_deaths,
			  						 TRUE ~ total_positives_reinfections - total_recovered - total_deaths)) %>%
	filter(!is.na(new_cases)) %>%
	write_csv(here("data/covid_data_report.csv"))

covid_trends_report <- left_join(covid_data_report, covid_totals_report, by = c("date", "day")) %>%
	full_join(tibble(date = seq(from = min(covid_data_report$date), to = max(covid_data_report$date), by = "day")),
			  by = "date") %>%
	arrange(date) %>%
	mutate(day_avg = case_when(is.na(day) ~ 0, TRUE ~ 1)) %>%
	mutate(day_avg = rollsumr(day_avg, 7, fill = "extend")) %>%
	filter(!is.na(day)) %>%
	left_join(vaccine_doses %>%
			  	filter(category == "Total vaccine doses administered") %>%
			  	arrange(report_date) %>%
			  	mutate(new_vaccine_doses_7day = (doses - lag(doses, 7)) / (report_date - lag(report_date, 7)) %>% as.numeric()) %>%
			  	select(date = report_date, new_vaccine_doses_7day) %>%
			  	filter(!is.na(new_vaccine_doses_7day)) %>%
			  	mutate(date = case_when(date == as_date("2021-06-01") ~ date - 1,
			  							date == as_date("2021-07-06") ~ date - 2,
			  							TRUE ~ date)),
			  by = "date") %>%
	filter(day_avg > 0) %>%
	arrange(date) %>%
	filter(date > min(date)) %>%
	transmute(date = date, day = day,
			  new_cases = rollmean_new(new_cases, day_avg),
			  new_tests = rollmean_new(new_tests, day_avg),
			  new_deaths = rollmean_new(new_deaths, day_avg),
			  new_ltc_deaths = rollmean_new(new_ltc_deaths, day_avg),
			  new_hosp = rollmean_new(new_hosp, day_avg),
			  positivity = rollsum_new(new_cases, day_avg) / rollsum_new(new_tests, day_avg),
			  positivity_pcr = rollsum_new(new_cases - new_antigen_cases, day_avg) / rollsum_new(new_tests - new_antigen_tests, day_avg),
			  positivity_pcr = case_when(is.na(positivity_pcr) ~ positivity, TRUE ~ positivity_pcr),
			  active_cases = rollmean_new(active_cases, day_avg),
			  new_vax_doses = new_vaccine_doses_7day,
			  new_vax_onedose = rollmean_new(new_vax_onedose, day_avg),
			  # new_vaccines_1x_adults_7day, new_vaccines_full_adults_7day,
			  new_vax_complete = rollmean_new(new_vax_complete, day_avg),
			  new_vax_boosted = rollmean_new(new_vax_boosted, day_avg),
			  new_antigen_cases = rollmean_new(new_antigen_cases, day_avg),
			  new_antigen_tests = rollmean_new(new_antigen_tests, day_avg)) %>%
	filter(!is.na(new_cases)) %>%
	mutate(across(is.numeric, ~case_when(is.infinite(.) ~ NA_real_, TRUE ~ .))) %>%
	write_csv(here("data/covid_trends_report.csv"))

covid_trends_report %>%
	select(date, day, new_cases, new_tests, positivity, new_hosp, new_deaths, active_cases, new_vax_onedose, new_vax_complete, new_vax_boosted) %>%
	arrange(desc(date)) %>%
	# mutate(positive_rate_7day = percent(positive_rate_7day, accuracy = .01)) %>%
	# mutate(across(is.numeric, comma, accuracy = .1)) %>%
	write_csv(here("data/covid_trends_report_short.csv"))

covid_data_actual <- list(case_table %>% filter(report_date == max(report_date)) %>% select(date, new_cases),
						  tests_table %>% filter(report_date == max(report_date)) %>% select(date = sample_date, new_tests),
						  hospitals %>% filter(report_date == max(report_date)) %>% select(date, new_icu, new_nonicu, new_hosp),
						  deaths %>% filter(report_date == max(report_date)) %>% select(date = death_date, new_deaths)) %>%
	reduce(left_join, by = "date") %>% 
	filter(!is.na(date)) %>%
	mutate(day = wday(date, label = TRUE, abbr = FALSE),
		   positivity = new_cases / new_tests,
		   cases_complete = case_when(date <= current_report_date - 7 ~ TRUE, TRUE ~ FALSE),
		   deaths_complete = case_when(date <= current_report_date - 21 ~ TRUE, TRUE ~ FALSE)) %>%
	select(date, day, everything()) %>%
	write_csv(here("data/covid_data_actual.csv"))

covid_trends_actual <- covid_data_actual %>%
	mutate(positivity = rollsumr(new_cases, 7, fill = NA) / rollsumr(new_tests, 7, fill = NA)) %>%
	mutate(across(new_cases:new_deaths, rollmeanr, 7, fill = NA)) %>%
	filter(!is.na(new_cases)) %>%
	write_csv(here("data/covid_trends_actual.csv"))

bind_cols(covid_totals_report %>%
		  	filter(date == max(date)) %>%
		  	select(cases = total_positives_reinfections,
		  		   deaths = total_deaths,
		  		   vax_onedose = total_vax_onedose,
		  		   vax_complete = total_vax_complete),
		  covid_trends_report %>%
		  	filter(date == max(date)) %>%
		  	select(positivity)) %>% 
	pivot_longer(everything(), names_to = "variable") %>%
	left_join(tibble(variable = c("cases", "deaths", "vax_onedose", "vax_complete", "positivity"),
					 label = c("Total\ncases", "Total\ndeaths", "People with at least 1 vaccine dose", "Completed vaccinations", "Seven-day positivity rate")),
			  by = "variable") %>%
	mutate(Date = paste0("Updated ", format(current_report_date, "%B %d, %Y"))) %>%
	mutate(formatted_value = case_when(variable == "positivity" ~ percent(value, accuracy = .1),
										 TRUE ~ comma(value, accuracy = 1))) %>%
	write_csv(here("data/flourish-data.csv"))