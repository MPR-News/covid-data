p <-wastewater %>% 
	mutate(rollsd = rollapply(copies_day_person_M_mn, width = 7, FUN = sd, fill = NA)) %>%
	mutate(covar = rollsd / copies_day_person_7day) %>%
	ggplot(aes(x = date, y = covar)) +
	geom_line() +
	scale_y_continuous(expand = expansion(mult = c(0, 0.02)), sec.axis = dup_axis()) +
	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y", expand = expansion(mult = .02)) +
	expand_limits(y = 0) +
	theme_covidmn_line() +
	theme(axis.title = element_blank()) +
	labs(title = "Rolling coefficient of variation of wastewater levels",
		 caption = "Source: MPR News, Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery")
fix_ratio(p) %>% image_write(here("wastewater-covar.png"))

p <-wastewater %>% 
	mutate(rollsd = rollapply(copies_day_person_M_mn, width = 7, FUN = sd, fill = NA)) %>%
	mutate(covar = rollsd / copies_day_person_7day) %>%
	ggplot(aes(x = date, y = rollsd)) +
	geom_line() +
	scale_y_continuous(expand = expansion(mult = c(0, 0.02)), sec.axis = dup_axis()) +
	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y", expand = expansion(mult = .02)) +
	expand_limits(y = 0) +
	theme_covidmn_line() +
	theme(axis.title = element_blank()) +
	labs(title = "Rolling standard deviation of wastewater levels",
		 caption = "Source: MPR News, Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery")
fix_ratio(p) %>% image_write(here("wastewater-sd.png"))