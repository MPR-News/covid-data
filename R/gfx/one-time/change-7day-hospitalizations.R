p <- covid_trends_actual %>%
	filter(cases_complete == TRUE) %>%
	select(date, new_icu, new_nonicu) %>%
	pivot_longer(-date, names_prefix = "new_") %>%
	group_by(name) %>%
	mutate(pct_chg = value / lag(value, 14) - 1) %>%
	filter(date > as_date("2020-05-01")) %>%
	ggplot(aes(x = date, y = pct_chg, color = name)) +
	geom_hline(yintercept = 0, linetype = 2) +
	geom_hline(data = . %>% filter(date == max(date)), aes(yintercept = pct_chg, color = name), linetype = 3) +
	geom_line(size = 1) +
	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y", expand = expansion(mult = c(.02, .02))) +
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
	labs(title = "Rate of change for MN <span style = 'color:#E69F00'>ICU</span> and <span style = 'color:#56B4E9'>non-ICU</span> admissions",
		 subtitle = "Data by sample date. The most recent week is incomplete and omitted.",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/change-7day-hospitalizations.png"))
