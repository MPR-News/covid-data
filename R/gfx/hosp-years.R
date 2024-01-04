p <- covid_trends_actual %>%
	filter(cases_complete == TRUE) %>%
	filter(year(date) <= 2023) %>%
	pivot_longer(c(new_icu, new_nonicu), names_prefix = "new_") %>%
	mutate(name = str_replace_all(name, "icu", "ICU") %>% str_replace_all("non", "Non-")) %>%
	mutate(year = year(date) %>% as.character()) %>%
	mutate(display_date = paste("2020", month(date), mday(date), sep = "-") %>% as_date()) %>%
	ggplot(aes(x = display_date, y = value, color = year)) +
	geom_line(size = 1) +
	geom_point(data = . %>% group_by(name) %>% filter(date == max(date)), size = 3) +
	geom_hline(data = . %>% filter(date == max(date)), aes(yintercept = value, color = year), linetype = 3) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.05)), sec.axis = dup_axis()) +
	scale_x_date(date_labels = "%b", date_breaks = "2 months", expand = expansion(mult = c(0.01, 0.01))) +
	scale_color_manual(values = covidmn_colors) +
	expand_limits(y = 0) +
	facet_wrap(vars(name), ncol = 2, scales = "free_y") +
	coord_cartesian(clip = "off") +
	theme_covidmn() +
	theme(axis.title.x = element_blank(),
		  axis.title.y.right = element_blank(),
		  axis.ticks.x = element_line(),
		  plot.subtitle = element_markdown(lineheight = 1.1),
		  legend.position = "none") +
	labs(title = "New ICU and non-ICU COVID hospitalizations in MN",
		 subtitle = "By admission date in <span style='color:#E69F00'>2020</span>, <span style='color:#56B4E9'>2021</span>, <span style='color:#009E73'>2022</span> and <span style='color:#D55E00'>2023</span>. The most recent week of<br>data is incomplete and omitted.",
		 caption = caption,
		 y = "New admissions")
fix_ratio(p) %>% image_write(here("images/new-hospital-admissions-both.png"))
