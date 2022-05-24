p <- left_join(wastewater %>%
	mutate(olympic_7day = (rollsumr(copies_day_person_M_mn, 7, fill = "extend") - rollmaxr(copies_day_person_M_mn, 7, fill = "extend") + rollmaxr(-copies_day_person_M_mn, 7, fill = NA)) / 5) %>%
		select(date, olympic_7day),
	covid_trends_actual %>%
		select(date, new_cases),
	by = "date") %>%
	pivot_longer(-date) %>%
	group_by(name) %>%
	filter(date > (min(date) + 7)) %>%
	mutate(index = value / value[date == min(date, na.rm = TRUE)] - 1) %>%
	ggplot(aes(x = date, y = index, color = name)) +
	geom_hline(yintercept = 0, linetype = 3) +
	geom_line(size = 1) +
	scale_y_continuous(labels = signs_format(format = scales::percent, add_plusses = TRUE, accuracy = 1), 
					   sec.axis = dup_axis()) +
	scale_color_manual(values = covidmn_colors) +
	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y", expand = expansion(mult = .02)) +
	theme_covidmn_line() +
	theme(axis.title = element_blank(),
		  plot.title = element_markdown(),
		  legend.position = "none") +
	labs(title = "<span style = 'color: #E69F00'>MN COVID-19 cases</span> and <span style = 'color: #56B4E9'>Twin Cities wastewater levels</span>",
		 subtitle = "Change since levels on Nov. 9, 2020",
		 caption = "Source: MPR, MN Department of Health, Metropolitan Council. Graph by David H. Montgomery")
fix_ratio(p)


p <- left_join(wastewater %>%
		  	mutate(olympic_7day = (rollsumr(copies_day_person_M_mn, 7, fill = "extend") - rollmaxr(copies_day_person_M_mn, 7, fill = "extend") + rollmaxr(-copies_day_person_M_mn, 7, fill = NA)) / 5) %>%
		  	select(date, olympic_7day),
		  covid_trends_actual %>%
		  	select(date, new_cases),
		  by = "date") %>%
	pivot_longer(-date) %>%
	group_by(name) %>%
	mutate(index = value / value[date == min(date, na.rm = TRUE)] - 1,
		   pct_chg = value / lag(value, 7) - 1) %>%
	filter(date >= as_date("2020-11-17")) %>%
	ggplot(aes(x = date, y = pct_chg, color = name)) +
	geom_hline(yintercept = 0, linetype = 3) +
	geom_line(size = 1) +
	scale_y_continuous(labels = signs_format(format = scales::percent, add_plusses = TRUE, accuracy = 1), 
					   sec.axis = dup_axis()) +
	scale_color_manual(values = covidmn_colors) +
	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y", expand = expansion(mult = .02)) +
	theme_covidmn_line() +
	theme(axis.title = element_blank(),
		  plot.title = element_markdown(),
		  legend.position = "none") +
	labs(title = "<span style = 'color: #E69F00'>MN COVID-19 cases</span> and <span style = 'color: #56B4E9'>Twin Cities wastewater levels</span>",
		 subtitle = "Change since levels on Nov. 9, 2020",
		 caption = "Source: MPR, MN Department of Health, Metropolitan Council. Graph by David H. Montgomery")
fix_ratio(p)
