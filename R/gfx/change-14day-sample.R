p <- covid_trends_actual %>%
	filter(cases_complete == TRUE) %>%
	select(date, new_cases, positivity, new_icu, new_nonicu) %>%
	pivot_longer(-date, names_prefix = "new_") %>%
	group_by(name) %>%
	mutate(pct_chg = value / lag(value, 7) - 1) %>%
	mutate(name = case_when(name == "icu" ~ "ICU",
							name == "nonicu" ~ "Non-ICU",
							TRUE ~ str_to_title(name))) %>%
	filter(date > max(date) - 150) %>%
	ggplot(aes(x = date, y = pct_chg, color = name)) +
	geom_hline(yintercept = 0, linetype = 2) +
	geom_line(size = 1) +
	geom_text_repel(data = . %>% filter(date == max(date)), 
										aes(label = name, x = date + 3),
					hjust = 0, direction = "y", fontface = "bold", size = 5) +
	scale_x_date(date_breaks = "1 months", date_labels = "%b\n%Y", expand = expansion(mult = c(.02, .15))) +
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
	labs(title = "Change in COVID-19 metrics vs. the past week",
		 subtitle = "Data by sample date. The most recent week is incomplete and omitted.",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/change-14day-sample.png"))
