p <- covid_trends_report %>%
	mutate(yday = yday(date),
		   year = year(date) %>% as.character(),
		   display_date = paste0("2020-", yday) %>% as.Date(format = "%Y-%j")) %>%
	filter(date >= as_date("2020-04-01")) %>%
	filter(!is.na(positivity)) %>%
	ggplot(aes(x = display_date, y = positivity, color = year)) +
	geom_line(size = 1.5) +
	geom_text(data = . %>% group_by(year) %>% filter(display_date <= as_date("2020-07-01")) %>% filter(positivity == max(positivity)),
			  aes(label = year), hjust = -.2, size = 6) +
	scale_y_continuous(labels = percent_format(accuracy = 1), expand = expansion(mult = c(0, 0.02)), breaks = seq(0.0, 1, .02),
					   sec.axis = dup_axis()) +
	scale_x_date(expand = expansion(mult = c(0.01, 0)), date_labels = "%b", date_breaks = "1 month") +
	scale_color_manual(values = covidmn_colors) +
	expand_limits(y = 0) +
	theme_covidmn() +
	theme(axis.title = element_blank(),
		  axis.ticks.x = element_line(),
		  axis.title.y.right = element_blank(),
		  legend.position = "none") +
	labs(title = "Minnesota COVID-19 positivity rate by year",
		 subtitle = "By report date",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/positivity-years.png"))
