p <- covid_trends_actual %>%
	filter(cases_complete == TRUE) %>%
	select(date, new_cases, new_hosp) %>%
	pivot_longer(-date, names_prefix = "new_") %>%
	group_by(name) %>%
	mutate(pct_chg = value / lag(value, 7) - 1) %>%
	filter(date > max(date) - 150) %>%
	ggplot(aes(x = date, y = pct_chg, color = name)) +
	geom_hline(yintercept = 0, linetype = 2) +
	geom_line(size = 1.5) +
	scale_x_date(date_breaks = "1 months", date_labels = "%b\n%Y", expand = expansion(mult = c(.02, .02))) +
	scale_y_continuous(labels = signs_format(add_plusses = TRUE, format = percent), 
					   sec.axis = dup_axis(), breaks = seq(-2, 5, .25)) +
	scale_color_manual(values = covidmn_colors[c(1:4)]) +
	expand_limits(y = 0) +
	# theme_covidmn_line() +
	theme_covidmn() +
	theme(axis.title = element_blank(),
		  axis.ticks.x = element_line(),
		  plot.title = element_markdown(),
		  legend.position = "none") +
	labs(title = "Rate of change for MN <span style = 'color:#E69F00'>cases</span> and <span style = 'color:#56B4E9'>hospitalizations</span>",
		 subtitle = "Data by sample date. The most recent week is incomplete and omitted.",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/change-7day-sample.png"))
