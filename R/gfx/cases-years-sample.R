p <- covid_trends_actual %>%
	filter(cases_complete == TRUE) %>%
	mutate(yday = yday(date),
		   year = year(date) %>% as.character(),
		   display_date = paste0("2020-", yday) %>% as.Date(format = "%Y-%j")) %>%
	ggplot(aes(x = display_date, y = new_cases, color = year)) +
	geom_line(data = . %>% filter(date <= (current_report_date - 6)), size = 1.5) +
	geom_line(data = . %>% filter(date > (current_report_date - 7)), size = 1, linetype = 3) +
	geom_text(data = . %>% group_by(year) %>% filter(date == max(date)),
			  aes(label = year), hjust = -.1, size = 6) +
	# geom_vline(xintercept = as_date("2020-11-25"), linetype = 3) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.02)),
					   sec.axis = dup_axis(), labels = comma_format(accuracy = 1)) +
	scale_x_date(expand = expansion(mult = c(0.01, 0.1)), date_labels = "%b", 
				 breaks = seq(as_date("2020-01-01"), as_date("2021-1-1"), by = "month")) +
	scale_color_manual(values = covidmn_colors) +
	expand_limits(y = 0) +
	coord_cartesian(clip = "off") +
	theme_covidmn() +
	theme(axis.title = element_blank(),
		  axis.ticks.x = element_line(),
		  axis.title.y.right = element_blank(),
		  legend.position = "none") +
	labs(title = "Minnesota COVID-19 cases by year",
		 # subtitle = "Confirmed cases by date reported",
		 subtitle = "By sample date. Dotted line is preliminary data.",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/cases-years-sample.png"))
