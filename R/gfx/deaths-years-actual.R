p <- covid_trends_actual %>%
	mutate(yday = yday(date),
		   year = year(date) %>% as.character(),
		   display_date = paste0("2020-", yday) %>% as.Date(format = "%Y-%j")) %>%
	filter(year <= 2023) %>%
	ggplot(aes(x = display_date, y = new_deaths, color = year)) +
	geom_hline(data = . %>% filter(cases_complete == TRUE) %>% filter(year == max(year), date == max(date)), aes(yintercept = new_deaths, color = year), linetype = 3) +
	geom_line(data = . %>% filter(deaths_complete == TRUE), size = 1.5) +
	geom_line(data = . %>% filter(deaths_complete == FALSE, cases_complete == TRUE), size = 1.5, linetype = 3) +
	geom_text(data = . %>% filter(cases_complete == TRUE) %>% group_by(year) %>% filter(date == max(date)),
			  aes(label = year), hjust = -.1, size = 6) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.02)),
					   breaks = seq(0, 200, 10),
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
		 subtitle = "Dotted line indicates incomplete recent data",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/deaths-years-actual.png"))
