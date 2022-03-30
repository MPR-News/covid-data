if(!exists("hospitals_dir")) {source(here("R/helper-functions.R"))}

is_captcha <- FALSE

raw_hospital_data <- url_picker_hosp(c("TELETRACKING", "MNTRAC"), is_captcha) %>%
	map(GET, user_agent(user_agent)) %>%
	map(content) %>%
	map(select, metric = Metric, bed_type = Detail1, metric_type = Detail2, is_covid = Detail3, date = `Data Date (MM/DD/YYYY)`, geography = "GeographicLevel", GeographicName, value = Value_NUMBER, units = Units, most_recent = `MOST RECENT (1)`, team = `COVID Team`) %>%
	reduce(bind_rows) %>%
	mutate(date = date_parser(date)) %>%
	distinct(date, metric_type, bed_type, is_covid, GeographicName, .keep_all = TRUE) %>%
	mutate(metric_type = str_to_upper(metric_type)) %>%
	write_csv(here("data/raw_hospital_data.csv"))

# raw_hospital_data <- url_picker_hosp(c("TELETRACKING", "MNTRAC"), is_captcha) %>%
# 	map(read_csv) %>%
# 	map(select, metric = Metric, bed_type = Detail1, metric_type = Detail2, is_covid = Detail3, date = `Data Date (MM/DD/YYYY)`, geography = "GeographicLevel", GeographicName, value = Value_NUMBER, units = Units, most_recent = `MOST RECENT (1)`, team = `COVID Team`) %>%
# 	reduce(bind_rows) %>%
# 	# mutate(date = mdy(date) %>% as_date()) %>%
# 	mutate(date = date_parser(date)) %>%
# 	distinct(date, metric_type, bed_type, is_covid, GeographicName, .keep_all = TRUE) %>%
# 	mutate(metric_type = str_to_upper(metric_type))
