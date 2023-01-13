if(!exists("wastewater")) {source(here("R/download-wastewater.R"))}

p <- wastewater %>%
	distinct(date, copies_day_person_M_mn, .keep_all = TRUE) %>%
	mutate(copies_7day = rollmeanr(copies_day_person_M_mn, 7, fill = "extend")) %>%
	ggplot(aes(x = date, y = copies_day_person_M_mn)) +
	geom_line(size = .3) +
	geom_line(aes(y = copies_7day), size = 1.5) +
	geom_hline(data = . %>% filter(date == max(date)), aes(yintercept = copies_7day), linetype = 3) +
	geom_point(data = . %>% filter(date == max(date)), aes(y = copies_7day), size = 3) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.05)), sec.axis = dup_axis(), labels = comma_format(suffix = "M")) +
	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y", expand = expansion(mult = .01)) +
	expand_limits(y = 0) +
	theme_covidmn_line() +
	theme(axis.title = element_blank()) +
	labs(title = "COVID load in Twin Cities metro wastewater",
		 subtitle = "In copies per day per person",
		 caption = "Source: MPR News, Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery")
fix_ratio(p) %>% image_write(here("images/wastewater-load.png"))
