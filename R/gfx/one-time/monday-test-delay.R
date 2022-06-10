p <- case_table %>%
	filter(wday(date) == 2) %>%
	filter(date >= as_date("2022-03-01")) %>%
	filter(date != max(date)) %>%
	group_by(date) %>%
	transmute(date, report_date, days = as.numeric(report_date - date), new_cases, newly_reported_cases, 
			  pct = newly_reported_cases / sum(newly_reported_cases),
			  cumpct = cumsum(pct)) %>%
	filter(days <= 7) %>%
	# filter(days == 4)
	ggplot(aes(x = days, y = cumpct, group = date)) +
	geom_hline(yintercept = .9, linetype = 2) +
	geom_line(size = .3) +
	geom_point(size = .6) +
	scale_y_continuous(breaks = seq(0, 1, .1), labels = percent_format(accuracy = 1)) +
	scale_x_continuous(labels = c("Wed.", "Thu.", "Fri.", " ", " ", "Mon.")) +
	expand_limits(y = 0) +
	theme_covidmn() +
	theme(axis.title.x = element_blank()) +
	labs(title = "How long does it take Monday tests to be reported?",
		 subtitle = "For tests conducted on Mondays since March 1, 2022",
		 y = "Cumulative percent of total cases",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/monday-test-delay.png"))