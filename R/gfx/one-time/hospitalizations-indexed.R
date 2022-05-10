p <- covid_trends_actual %>%
	select(date, new_icu, new_nonicu) %>%
	# filter(date >= as_date("2020-05-01")) %>%
	pivot_longer(-date) %>%
	group_by(name) %>%
	mutate(index = value / value[date == as_date("2020-11-19")]) %>%
	ggplot(aes(x = date, y = index, color = name)) +
	geom_line(size = 1) +
	scale_color_manual(values = covidmn_colors) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.02)), labels = percent_format(accuracy = 1), sec.axis = dup_axis(), breaks = seq(0, 1, .25)) +
	scale_x_date(date_labels = "%b\n%Y", date_breaks = "3 months", expand = expansion(mult = .02)) +
	theme_covidmn_line() +
	theme(axis.title = element_blank(),
		  plot.title = element_markdown(),
		  legend.position = "none") +
	labs(title = "MN <span style = 'color:#E69F00'>ICU</span> and <span style = 'color:#56B4E9'>non-ICU</span> admissions as share of peak",
		 subtitle = "Values indexed to rates as of Nov. 19, 2020",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/hospitalizations-indexed.png"))