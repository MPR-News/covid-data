if(!exists("age_table")) {source(here("R/scrape-demographics.R"))}

p <- race_table_processed %>%
	ungroup() %>%
	filter(race != "Other") %>%
	ggplot(aes(x = date, y = new_cases_percap_7day, color = race)) +
	geom_line(size = 1) +
	geom_text_repel(data = . %>%
						group_by(race) %>%
						filter(date == max(date)),
					aes(label = race, x = date + 10), hjust = 0, direction = "y", size = 5, fontface = "bold") +
	geom_point(data = . %>% filter(date == max(date)), size = 2) +
	scale_y_continuous(expand = expansion(mult = 0.01), sec.axis = dup_axis()) +
	scale_x_date(date_breaks = "2 months", date_labels = "%b", expand = expansion(mult = c(0.01, .16))) +
	scale_color_manual(values = covidmn_colors) +
	# coord_cartesian(ylim = c(0, 40)) +
	theme_covidmn() +
	theme(legend.position = "none",
		  axis.ticks.x = element_line(),
		  axis.title.y.right = element_blank(),
		  axis.title.x = element_blank()) +
	labs(title = "New MN COVID-19 cases per capita, by race",
		 subtitle = "Lines represent seven-day averages",
		 caption = caption,
		 y = "New cases per 100,000 people")
fix_ratio(p) %>% image_write(here("images/new-cases-by-race.png"))
