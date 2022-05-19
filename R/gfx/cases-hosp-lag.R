p <- left_join(hospitals %>% select(date, new_hosp, total_hosp, report_date, newly_reported_hosp),
			   case_table %>% select(1:5),
			   by = c("date", "report_date")) %>%
	filter(report_date > min(report_date)) %>%
	mutate(report_date = case_when(report_date == as_date("2022-01-18") ~ report_date - 1, TRUE ~ report_date)) %>%
	group_by(report_date) %>%
	mutate(days_ago = as.numeric(report_date - date)) %>%
	filter(days_ago <= 21) %>%
	mutate(x = newly_reported_cases * days_ago,
		   y = newly_reported_hosp * days_ago) %>%
	mutate(x = case_when(x < 0 ~ 0, TRUE ~ x),
		   y = case_when(y < 0 ~ 0, TRUE ~ y)) %>%
	summarize(newly_reported_cases = sum(newly_reported_cases, na.rm = TRUE),
			  newly_reported_hosp = sum(newly_reported_hosp, na.rm = TRUE),
			  total_day_cases = sum(x, na.rm = TRUE),
			  total_day_hosp = sum(y, na.rm = TRUE))  %>%
	mutate(avg_case_lag = total_day_cases / newly_reported_cases,
		   avg_hosp_lag = total_day_hosp / newly_reported_hosp) %>%
	full_join(x = .,
			  y = tibble(report_date = seq(from = min({.}$report_date, na.rm = TRUE), to = max({.}$report_date, na.rm = TRUE), by = "day")),
			  by = "report_date") %>% 
	arrange(report_date) %>%
	mutate(day_avg = case_when(is.na(newly_reported_cases) ~ 0, TRUE ~ 1)) %>%
	mutate(day_avg = rollsumr(day_avg, 7, fill = "extend")) %>% 
	filter(!is.na(newly_reported_cases)) %>%
	mutate(avg_case_lag_7day = rollapplyr(avg_case_lag, day_avg, FUN = mean, fill = NA),
		   avg_hosp_lag_7day = rollapplyr(avg_hosp_lag, day_avg, FUN = mean, fill = NA)) %>%
	mutate(ratio = avg_hosp_lag_7day / avg_case_lag_7day) %>%
	pivot_longer(contains("7day"), names_prefix = "avg_") %>%
	filter(!is.na(value)) %>%
	# ggplot(aes(x = report_date, y = ratio)) +
	ggplot(aes(x = report_date, y = value, color = name)) +
	geom_line(size = 1.5) +
	scale_color_manual(values = covidmn_colors) +
	theme_covidmn_line() +
	theme(plot.title = element_markdown(),
		  legend.position = "none",
		  axis.title = element_blank()) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.05)), breaks = seq(0, 10, 1), sec.axis = dup_axis()) +
	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y") +
	expand_limits(y = 0) +
	labs(title = "Average lag reporting <span style='color:#E69F00'>cases</span> and <span style='color:#56B4E9'>hospitalizations</span>",
		 subtitle = "In days. Lines represent seven-day averages",
		 caption = caption)
NULL
fix_ratio(p) %>% image_write(here("images/cases-hosp-lag.png"))