p <- covid_trends_report %>%
	pivot_longer(c(new_vax_onedose, new_vax_complete, new_vax_boosted)) %>%
	mutate(name = str_replace_all(name, "new_vax_onedose", "First") %>% str_replace_all("new_vax_complete", "Final") %>% str_replace_all("new_vax_boosted", "Booster") %>% fct_relevel("First", "Final", "Booster")) %>%
	filter(value >= 0) %>%
	select(date, name, value) %>% 
	ggplot(aes(x = date, y= value, color = name)) +
	geom_line(size = 1.5) + 
	geom_hline(data = . %>% group_by(name) %>% filter(date == max(date)), 
			   aes(yintercept = value, color = name), linetype = 3) +
	geom_point(data = . %>% group_by(name) %>% filter(date == max(date)), size = 3) +
	scale_color_manual(values = covidmn_colors[c(2, 1, 3)]) + 
	scale_y_continuous(labels = comma_format(scale = 0.001, accuracy = 1, suffix = "K"), sec.axis = dup_axis(), 
					   expand = expansion(mult = c(0, 0.03)), breaks = seq(0, 100000, 5000)) +
	scale_x_date(expand = expansion(mult = .02), date_labels = "%b", date_breaks = "1 month") +
	expand_limits(y = 0) +
	theme_covidmn() +
	theme(legend.position = "none",
		  axis.title = element_blank(),
		  axis.ticks.x = element_line(),
		  plot.title = element_markdown()) +
	labs(title = "New MN <span style='color:#56B4E9'>first</span>, <span style='color:#E69F00'>final</span> and <span style='color:#009E73'>booster</span> doses, by day",
		 subtitle = "Lines represent seven-day averages",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/new-first-second-doses.png"))
