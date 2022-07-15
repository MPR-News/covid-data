if(!exists("cases_race")) {source(here("R/load-data/download-cases.R"))}

p <- cases_race %>%
	mutate(race = case_when(race_ethnicity == "American Indian" ~ "Native",
							race_ethnicity == "Asian/Pacific Islander" ~ "Asian",
							race_ethnicity == "Black/African American" ~ "Black",
							TRUE ~ race_ethnicity)) %>%
	rename("date" = mmwr_enddate) %>%
	filter(date < max(date)) %>%
	filter(race != "Multiracial") %>%
	ggplot(aes(x = date, y = new_cases_percap, color = race)) +
	geom_line(size = 1) +
	geom_text_repel(data = . %>%
						group_by(race) %>%
						filter(date == max(date)),
					aes(label = race, x = date + 10), hjust = 0, direction = "y", size = 5, fontface = "bold") +
	geom_point(data = . %>% filter(date == max(date)), size = 2) +
	scale_y_continuous(expand = expansion(mult = 0.01), sec.axis = dup_axis(), labels = comma_format(accuracy = 1)) +
	scale_x_date(date_breaks = "2 months", date_labels = "%b", expand = expansion(mult = c(0.01, .16))) +
	scale_color_manual(values = covidmn_colors) +
	# coord_cartesian(ylim = c(0, 40)) +
	theme_covidmn() +
	theme(legend.position = "none",
		  axis.ticks.x = element_line(),
		  axis.title.y.right = element_blank(),
		  axis.title.x = element_blank()) +
	labs(title = "Weekly COVID-19 cases per capita, by race",
		 subtitle = "Lines represent seven-day averages",
		 caption = caption,
		 y = "New cases per 100,000 people")
fix_ratio(p) %>% image_write(here("images/new-cases-by-race.png"))
