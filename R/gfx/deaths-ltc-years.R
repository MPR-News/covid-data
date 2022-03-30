p <- covid_trends_report %>%
	transmute(date, day, new_deaths, new_ltc_deaths, non_ltc_deaths = new_deaths - new_ltc_deaths) %>% 
	filter(!is.na(non_ltc_deaths)) %>%
	pivot_longer(contains("ltc"), values_to = "deaths") %>%
	mutate(name = case_when(name == "new_ltc_deaths" ~ "Long-term care deaths", TRUE ~ "Non-long-term care deaths")) %>%
	mutate(year = year(date) %>% as.character()) %>%
	mutate(display_date = paste("2020", month(date), mday(date), sep = "-") %>% as_date()) %>%
	ggplot(aes(x = display_date, y = deaths, color = year)) +
	geom_line(size = 1) +
	geom_point(data = . %>% filter(date == max(date)), size = 2) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.05)), sec.axis = dup_axis(), labels = comma_format(accuracy = 1)) +
	scale_x_date(date_labels = "%b", date_breaks = "3 months", expand = expansion(mult = c(0.02, 0.2))) +
	scale_color_manual(values = covidmn_colors) + 
	expand_limits(y = 0) +
	facet_wrap(vars(name)) +
	theme_covidmn() +
	theme(axis.title.x = element_blank(),
		  axis.title.y.right = element_blank(),
		  axis.ticks.x = element_line(),
		  plot.subtitle = element_markdown(),
		  legend.position = "none") +
	labs(title = "MN COVID-19 deaths by long-term care status",
		 subtitle = "Rolling seven-day averages in <span style='color:#E69F00'>2020</span>, <span style='color:#56B4E9'>2021</span> and <span style='color:#009E73'>2022</span>",
		 caption = caption,
		 y = "Deaths")
fix_ratio(p) %>% image_write(here("images/deaths-ltc-years.png"))
