GET(url = "https://www.health.state.mn.us/diseases/coronavirus/stats/vbtadultaarates.xlsx",
	user_agent(user_agent),
	write_disk(tmp <- tempfile()))

breakthroughs_weighted_adults <- read_excel(tmp) %>%
	set_names("week", "week_start", "cases_boosted", "cases_vaxxed", "cases_unvaxxed", "hosp_boosted", "hosp_vaxxed", "hosp_unvaxxed", "deaths_boosted", "deaths_vaxxed", "deaths_unvaxxed") %>%
	filter(!is.na(cases_boosted)) %>%
	separate(week, c("year", "week"), sep = -2) %>%
	mutate(week_start = as_date(week_start))

write_csv(breakthroughs_weighted_adults, here("data/breakthroughs", paste0("breakthroughs-weighted-adults-", current_report_date, ".csv")))
write_csv(breakthroughs_weighted_adults, here("data/breakthroughs", "breakthroughs-weighted-adults.csv"))

GET(url = "https://www.health.state.mn.us/diseases/coronavirus/stats/vbtpedsaarates.xlsx",
	user_agent(user_agent),
	write_disk(tmp <- tempfile()))

breakthroughs_weighted_kids <- read_excel(tmp, range = cell_cols("A:F")) %>%
	set_names("week", "week_start", "cases_vaxxed", "cases_unvaxxed", "hosp_vaxxed", "hosp_unvaxxed") %>%
	filter(!is.na(cases_vaxxed)) %>%
	separate(week, c("year", "week"), sep = -2) %>%
	mutate(week_start = as_date(week_start))

write_csv(breakthroughs_weighted_kids, here("data/breakthroughs", paste0("breakthroughs-weighted-kids-", current_report_date, ".csv")))
write_csv(breakthroughs_weighted_kids, here("data/breakthroughs", "breakthroughs-weighted-kids.csv"))

GET(url = "https://www.health.state.mn.us/diseases/coronavirus/stats/vbtadultcirates.xlsx",
	user_agent(user_agent),
	write_disk(tmp <- tempfile()))

breakthroughs_weighted_age_adults <- read_excel(tmp, skip = 1) %>%
	set_names("week", "week_start", "age", 
			  "pop_boosted_count", "pop_vaxxed_count", "pop_unvaxxed_count", 
			  "cases_boosted_count", "cases_boosted_rate", "cases_vaxxed_count", "cases_vaxxed_rate", "cases_unvaxxed_count", "cases_unvaxxed_rate",
			  "hosp_boosted_count", "hosp_boosted_rate", "hosp_vaxxed_count", "hosp_vaxxed_rate", "hosp_unvaxxed_count", "hosp_unvaxxed_rate",
			  "deaths_boosted_count", "deaths_boosted_rate", "deaths_vaxxed_count", "deaths_vaxxed_rate", "deaths_unvaxxed_count", "deaths_unvaxxed_rate") %>%
	filter(!is.na(age)) %>%
	pivot_longer(4:ncol(.), names_to = c("metric", "vax_status", "metric_type"), names_sep = "_") %>%
	separate(week, c("year", "week"), sep = -2) %>%
	mutate(week_start = as_date(week_start))

write_csv(breakthroughs_weighted_age_adults, here("data/breakthroughs", paste0("breakthroughs-weighted-age-adults-", current_report_date, ".csv")))
write_csv(breakthroughs_weighted_age_adults, here("data/breakthroughs", "breakthroughs-weighted-age-adults.csv"))

GET(url = "https://www.health.state.mn.us/diseases/coronavirus/stats/vbtpedscirates.xlsx",
	user_agent(user_agent),
	write_disk(tmp <- tempfile()))

breakthroughs_weighted_age_kids <- read_excel(tmp, skip = 1) %>%
	set_names("week", "week_start", "age", 
			  "pop_vaxxed_count", "pop_unvaxxed_count", 
			  "cases_vaxxed_count", "cases_vaxxed_rate", "cases_unvaxxed_count", "cases_unvaxxed_rate",
			  "hosp_vaxxed_count", "hosp_vaxxed_rate", "hosp_unvaxxed_count", "hosp_unvaxxed_rate") %>%
	filter(!is.na(age)) %>%
	pivot_longer(4:ncol(.), names_to = c("metric", "vax_status", "metric_type"), names_sep = "_") %>%
	separate(week, c("year", "week"), sep = -2) %>%
	mutate(week_start = as_date(week_start))

write_csv(breakthroughs_weighted_age_kids, here("data/breakthroughs", paste0("breakthroughs-weighted-age-kids-", current_report_date, ".csv")))
write_csv(breakthroughs_weighted_age_kids, here("data/breakthroughs", "breakthroughs-weighted-age-kids.csv"))