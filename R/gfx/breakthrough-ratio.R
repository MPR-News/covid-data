if(!exists("breakthroughs_weighted")) {source(here("R/load-files/download-breakthroughs.R"))}

p <- breakthroughs_weighted %>%
	group_by(metric, vax) %>%
	mutate(value_3week = rollmeanr(value, 3, fill = "extend")) %>%
	# pivot_wider(names_from = vax, values_from = c(value_3week), id_cols = c(week_start, metric)) %>%
	pivot_wider(names_from = vax, values_from = c(value), id_cols = c(week_start, metric)) %>%
	mutate(ratio = unvax / vax,
		   inverse_ratio = 1 - vax / unvax) %>%
	mutate(metric = str_replace_all(metric, "hosp", "Hosp.")) %>%
	ggplot(aes(x = week_start, y = ratio, color = metric)) +
	geom_line(size = 1.5) +
	geom_text_repel(data = . %>% group_by(metric) %>% filter(week_start == max(week_start)),
					aes(label = str_to_title(metric), x = week_start + 3), hjust = 0, fontface = "bold", size = 6, direction = "y") +
	scale_y_continuous(expand = expansion(mult = c(0, .02)), sec.axis = dup_axis(), breaks = c(1, 2, 4, 8, 16, 32, 64),
					   labels = number_format(suffix = "x", accuracy = 1), trans = "log2") +
	scale_x_date(date_labels = "%b", date_breaks = "1 month", expand = expansion(mult = c(.03, .15))) +
	scale_color_manual(values = covidmn_colors) +
	expand_limits(y = 1) +
	# coord_cartesian(ylim = c(1, 30)) +
	theme_covidmn() +
	theme(axis.ticks.x = element_line(),
		  axis.title.x = element_blank(),
		  axis.title.y.right = element_blank(),
		  legend.position = "none") +
	labs(title = "Unvaxxed more likely to get COVID",
		 subtitle = "COVID prevalance among the unvaccinated relative to vaccinated, in\nMinnesota. Data represents three-week rolling averages.",
		 caption = caption,
		 y = "How many times more common\namong the unvaccinated")
fix_ratio(p) %>% image_write(here("images/breakthrough-ratio.png"))



