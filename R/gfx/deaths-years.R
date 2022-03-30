p <- covid_trends_report %>%
	mutate(yday = yday(date),
		   year = year(date) %>% as.character(),
		   display_date = paste0("2020-", yday) %>% as.Date(format = "%Y-%j")) %>%
	filter(date >= as_date("2020-04-01")) %>%
	ggplot(aes(x = display_date, y = new_deaths, color = year)) +
	geom_line(size = 1.5) +
	geom_text(data = . %>% group_by(year) %>% filter(date == max(date)),
			  aes(label = year), hjust = -.1, size = 6) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.02)),
					   sec.axis = dup_axis()) +
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
	labs(title = "Minnesota COVID-19 deaths by year",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/deaths-years.png"))
