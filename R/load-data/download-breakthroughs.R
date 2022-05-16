GET(url = "https://www.health.state.mn.us/diseases/coronavirus/stats/vbtcounts.xlsx",
	user_agent(user_agent),
	write_disk(tmp <- tempfile()))

breakthroughs <- read_excel(tmp) %>%
	set_names("week", "week_start", "metric", "vax", "number") %>% 
	filter(!is.na(number)) %>%
	separate(week, c("year", "week"), sep = -2) %>%
	mutate(week_start = as_date(week_start))

write_csv(breakthroughs, here("data/breakthroughs", paste0("breakthroughs-", current_report_date, ".csv")))
write_csv(breakthroughs, here("data/breakthroughs", "breakthroughs.csv"))

GET(url = "https://www.health.state.mn.us/diseases/coronavirus/stats/vbtaarates.xlsx",
	user_agent(user_agent),
	write_disk(tmp <- tempfile()), overwrite = TRUE)

breakthroughs_weighted <- read_excel(tmp, range = cell_cols("A:H")) %>%
	set_names("week", "week_start", "cases_vax", "cases_unvax", "hosp_vax", "hosp_unvax", "deaths_vax", "deaths_unvax") %>%
	filter(!is.na(cases_vax)) %>%
	separate(week, c("year", "week"), sep = -2) %>%
	# mutate(week_start = excel_numeric_to_date(week_start)) %>%
	mutate(week_start = as_date(week_start)) %>%
	pivot_longer(cases_vax:deaths_unvax) %>%
	separate(name, c("metric", "vax"), sep = "_") 

write_csv(breakthroughs_weighted, here("data/breakthroughs", paste0("breakthroughs-weighted-", current_report_date, ".csv")))
write_csv(breakthroughs_weighted, here("data/breakthroughs", "breakthroughs-weighted.csv"))

GET(url = "https://www.health.state.mn.us/diseases/coronavirus/stats/vbtcirates.xlsx",
	user_agent(user_agent),
	write_disk(tmp <- tempfile()), overwrite = TRUE)

breakthroughs_weighted_age <- read_excel(tmp, skip = 1) %>%
	set_names("week", "week_start", "age", "vaxxed_caserate", "unvaxxed_caserate", "vaxxed_hosprate", "unvaxxed_hosprate", "vaxxed_deathrate", "unvaxxed_deathrate") %>%
	filter(week_start != "Overall") %>%
	separate(week, c("year", "week"), sep = -2) %>%
	mutate(week_start = week_start %>% as.numeric() %>% excel_numeric_to_date()) %>%
	mutate(across(contains("rate"), as.numeric)) %>%
	pivot_longer(contains("rate")) %>%
	mutate(value = replace_na(value, 0)) %>%
	separate(name, c("vax", "metric"), sep = "_")

write_csv(breakthroughs_weighted_age, here("data/breakthroughs", paste0("breakthroughs-weighted-age-", current_report_date, ".csv")))
write_csv(breakthroughs_weighted_age, here("data/breakthroughs", "breakthroughs-weighted-age.csv"))