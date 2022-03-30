p <- covid_trends_actual %>%
	mutate(yday = yday(date),
		   year = year(date) %>% as.character(),
		   display_date = paste0("2020-", yday) %>% as.Date(format = "%Y-%j")) %>%
	ggplot(aes(x = display_date, y = new_tests, color = year)) +
	geom_line(data = . %>% filter(cases_complete == TRUE), size = 1.5) +
	geom_line(data = . %>% filter(cases_complete == FALSE), size = .5, linetype = 3) +
	geom_text(data = . %>% group_by(year) %>% filter(date == max(date)),
			  aes(label = year), hjust = -.2, size = 6) +
	scale_y_continuous(labels = comma_format(accuracy = 1, scale = .001, suffix = "K"), 
					   expand = expansion(mult = c(0, 0.02)), sec.axis = dup_axis()) +
	scale_x_date(expand = expansion(mult = c(0.01, 0.1)), date_labels = "%b", date_breaks = "1 month") +
	scale_color_manual(values = covidmn_colors) +
	coord_cartesian(clip = "off") +
	expand_limits(y = 0) +
	theme_covidmn() +
	theme(axis.title = element_blank(),
		  axis.ticks.x = element_line(),
		  axis.title.y.right = element_blank(),
		  legend.position = "none") +
	labs(title = "Minnesota COVID-19 test volume by year",
		 subtitle = "By sample date. Dotted line indicates preliminary data.",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/tests-years-sample.png"))
