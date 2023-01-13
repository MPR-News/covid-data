p <- hosp_beds %>%
	filter(region == "State", report_date == max(report_date)) %>%
	select(date, contains("beds_covid")) %>%
	pivot_longer(-date, names_to = "bed_type") %>%
	mutate(bed_type = case_when(str_detect(bed_type, "non_") ~ "Non-ICU", TRUE ~ "ICU")) %>%
	mutate(year = year(date) %>% as.character()) %>%
	mutate(display_date = paste("2020", month(date), mday(date), sep = "-") %>% as_date()) %>%
	filter(date < current_report_date - 2) %>%
	ggplot(aes(x = display_date, y = value, color = year)) +
	geom_line(size = 1) +
	geom_hline(data = . %>% filter(date == max(date)), aes(yintercept = value, color = year), linetype = 3) +
	geom_point(data = . %>% filter(date == max(date)), size = 3) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.05)), sec.axis = dup_axis(), labels = comma_format(accuracy = 1)) +
	scale_x_date(date_labels = "%b", date_breaks = "2 months", expand = expansion(mult = c(0.01, 0.01))) +
	scale_color_manual(values = covidmn_colors) + 
	expand_limits(y = 0) +
	facet_wrap(vars(bed_type), scales = "free_y") +
	theme_covidmn() +
	theme(axis.title.x = element_blank(),
		  axis.title.y.right = element_blank(),
		  axis.ticks.x = element_line(),
		  plot.subtitle = element_markdown(),
		  legend.position = "none") +
	labs(title = "COVID-19 hospital bed use in Minnesota",
		 subtitle = "In <span style='color:#E69F00'>2020</span>, <span style='color:#56B4E9'>2021</span>, <span style='color:#009E73'>2022</span> and <span style='color:#D55E00'>2023</span>",
		 caption = caption,
		 y = "Hospital beds")
fix_ratio(p) %>% image_write(here("images/hospital-bed-use-flipped.png"))