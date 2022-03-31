if(!exists("breakthroughs_weighted")) {
	breakthroughs_weighted <- read_csv(here("data/breakthroughs/breakthroughs-weighted.csv"))
	}

p <- breakthroughs_weighted %>%
	group_by(metric, vax) %>%
	mutate(value_3week = rollmeanr(value, 3, fill = "extend")) %>%
	pivot_wider(names_from = vax, values_from = c(value_3week), id_cols = c(week_start, metric)) %>%
	mutate(ratio = unvax / vax,
		   inverse_ratio = 1 - vax / unvax) %>%
	mutate(metric = str_replace_all(metric, "hosp", "Hosp.")) %>%
	ggplot(aes(x = week_start, y = inverse_ratio, color = metric)) +
	geom_line(size = 1.5) +
	geom_text_repel(data = . %>% group_by(metric) %>% filter(week_start == max(week_start)),
					aes(label = str_to_title(metric), x = week_start + 3), hjust = 0, fontface = "bold", size = 6, direction = "y") +
	scale_y_continuous(sec.axis = dup_axis(), labels = percent_format(accuracy = 1)) +
	scale_x_date(date_labels = "%b", date_breaks = "1 month", expand = expansion(mult = c(.03, .15))) +
	scale_color_manual(values = covidmn_colors) +
	expand_limits(y = 1) +
	theme_covidmn() +
	theme(axis.ticks.x = element_line(),
		  axis.title = element_blank(),
		  legend.position = "none") +
	labs(title = "Observed vaccine effectiveness in Minnesota",
		 subtitle = "Reduced observation of COVID-19 among vaccinated Minnesotans",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/breakthrough-effectiveness.png"))
