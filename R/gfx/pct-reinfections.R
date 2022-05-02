p <- left_join(covid_data_actual %>%
		  	select(date, new_cases, cases_complete),
		  reinfections %>%
		  	filter(report_date == max(report_date)) %>%
		  	transmute(date, new_reinfections = total_reinfections - lag(total_reinfections)),
		  by = "date") %>%
	filter(!is.na(new_reinfections)) %>%
	filter(cases_complete == TRUE) %>%
	mutate(across(where(is.numeric), ~rollmeanr(., 7, fill = "extend"))) %>%
	mutate(pct_reinfections = new_reinfections / new_cases) %>%
	filter(pct_reinfections > 0) %>%
	ggplot(aes(x = date, y= pct_reinfections)) +
	geom_line(size = .8) +
	scale_y_continuous(labels = percent_format(accuracy = 1), sec.axis = dup_axis(), breaks = seq(0, 1, .02),
					   expand = expansion(mult = c(0, 0.02))) +
	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y", expand = expansion(mult = 0.01)) +
	expand_limits(y = 0) +
	theme_covidmn_line() +
	theme(axis.title = element_blank()) +
	labs(title = "MN COVID-19 cases that are confirmed reinfections",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/pct-reinfections.png"))