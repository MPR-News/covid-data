if(!exists("wastewater")) {source(here("R/download-wastewater.R"))}

p <- wastewater %>%
	distinct(date, copies_day_person_M_mn, .keep_all = TRUE) %>%
	mutate(copies_7day = rollmeanr(copies_day_person_M_mn, 7, fill = "extend")) %>%
	filter(date >= as_date("2022-2-1")) %>%
	ggplot(aes(x = date, y = copies_day_person_M_mn)) +
	geom_col() +
	geom_line(aes(y = copies_7day), size = 1.5, color = covidmn_colors[4]) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.05)), sec.axis = dup_axis(), labels = comma_format(suffix = "M")) +
	scale_x_date(date_breaks = "1 week", date_labels = "%b %d", expand = expansion(mult = .01)) +
	expand_limits(y = 0) +
	# theme_covidmn_line() +
	theme_covidmn() +
	theme(axis.title = element_blank(),
		  axis.ticks.x = element_line()) +
	labs(title = "COVID load in Twin Cities metro wastewater",
		 subtitle = "In copies per day per person. Line represents seven-day average.",
		 caption = "Source: MPR News, Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery")
fix_ratio(p) %>% image_write(here("images/wastewater-load-trunc.png"))
