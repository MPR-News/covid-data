p <- left_join(wastewater %>%
	mutate(olympic_7day = (rollsumr(copies_day_person_M_mn, 7, fill = "extend") - rollmaxr(copies_day_person_M_mn, 7, fill = "extend") + rollmaxr(-copies_day_person_M_mn, 7, fill = NA)) / 5) %>%
		select(date, olympic_7day),
	covid_trends_actual %>%
		select(date, new_cases),
	by = "date") %>%
	pivot_longer(-date) %>%
	group_by(name) %>%
	filter(date > (min(date) + 7)) %>%
	mutate(index = value / max(value)) %>%
	filter(date >= current_report_date - 60) %>%
	ggplot(aes(x = date, y = index, color = name)) +
	# geom_hline(yintercept = 0, linetype = 3) +
	geom_line(size = 1) +
	geom_vline(data = . %>% group_by(name) %>% filter(index == max(index)), aes(xintercept = date, color = name), linetype = 3) +
	scale_y_continuous(labels = percent_format(accuracy = 1), 
					   sec.axis = dup_axis(), expand = expansion(mult = c(0, 0.02))) +
	scale_color_manual(values = covidmn_colors) +
	scale_x_date(date_breaks = "1 week", date_labels = "%b\n%d", expand = expansion(mult = .02)) +
	expand_limits(y = 0) +
	theme_covidmn_line() +
	theme(axis.title = element_blank(),
		  plot.title = element_markdown(),
		  legend.position = "none") +
	labs(title = "MN <span style = 'color: #E69F00'>COVID cases</span> and <span style = 'color: #56B4E9'>Twin Cities wastewater levels</span>",
		 subtitle = "As percent of highest recorded value",
		 caption = "Source: MPR, MN Department of Health, Metropolitan Council. Graph by David H. Montgomery")
fix_ratio(p) %>% image_write(here("images/wastewater-cases-comp-trunc.png"))


# p <- left_join(wastewater %>%
# 		  	mutate(olympic_7day = (rollsumr(copies_day_person_M_mn, 7, fill = "extend") - rollmaxr(copies_day_person_M_mn, 7, fill = "extend") + rollmaxr(-copies_day_person_M_mn, 7, fill = NA)) / 5) %>%
# 		  	select(date, olympic_7day),
# 		  covid_trends_actual %>%
# 		  	select(date, new_cases),
# 		  by = "date") %>%
# 	pivot_longer(-date) %>%
# 	group_by(name) %>%
# 	mutate(index = value / max(value) - 1,
# 		   pct_chg = value / lag(value, 7) - 1) %>%
# 	filter(date >= as_date("2020-11-17")) %>%
# 	ggplot(aes(x = date, y = pct_chg, color = name)) +
# 	geom_hline(yintercept = 0, linetype = 3) +
# 	geom_line(size = 1) +
# 	scale_y_continuous(labels = signs_format(format = scales::percent, add_plusses = TRUE, accuracy = 1), 
# 					   sec.axis = dup_axis()) +
# 	scale_color_manual(values = covidmn_colors) +
# 	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y", expand = expansion(mult = .02)) +
# 	theme_covidmn_line() +
# 	theme(axis.title = element_blank(),
# 		  plot.title = element_markdown(),
# 		  legend.position = "none") +
# 	labs(title = "<span style = 'color: #E69F00'>MN COVID-19 cases</span> and <span style = 'color: #56B4E9'>Twin Cities wastewater levels</span>",
# 		 subtitle = "Change since levels on Nov. 9, 2020",
# 		 caption = "Source: MPR, MN Department of Health, Metropolitan Council. Graph by David H. Montgomery")
# fix_ratio(p)
