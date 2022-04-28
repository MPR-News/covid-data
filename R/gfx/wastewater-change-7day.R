p <- wastewater %>%
	mutate(copies_7day = rollmeanr(copies_day_person_M_mn, 7, fill = "extend")) %>%
	mutate(olympic_7day = (rollsumr(copies_day_person_M_mn, 7, fill = "extend") - 
						   	rollmaxr(copies_day_person_M_mn, 7, fill = "extend") + 
						   	rollmaxr(-copies_day_person_M_mn, 7, fill = "extend")) / 5) %>%
	mutate(pct_chg = olympic_7day / lag(olympic_7day, 7) - 1) %>%
	filter(date > max(date) - 150) %>%
	ggplot(aes(x = date, y = pct_chg)) +
	geom_hline(yintercept = 0, linetype = 2) +
	geom_line(size = 1.5) +
	scale_x_date(date_breaks = "1 months", date_labels = "%b\n%Y", expand = expansion(mult = c(.02, .02))) +
	scale_y_continuous(labels = signs_format(add_plusses = TRUE, format = percent), 
					   sec.axis = dup_axis(), breaks = seq(-2, 5, .25)) +
	expand_limits(y = 0) +
	# theme_covidmn_line() +
	theme_covidmn() +
	theme(axis.title = element_blank(),
		  axis.ticks.x = element_line(),
		  plot.title = element_markdown(),
		  legend.position = "none") +
	labs(title = "Rate of change for COVID in Twin Cities wastewater",
		 subtitle = "Over the prior week, based on a rolling Olympic average",
		 caption = "Source: MPR News, Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery")
fix_ratio(p) %>% image_write(here("images/wastewater_change_7day.png"))