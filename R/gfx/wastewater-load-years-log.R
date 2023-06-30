if(!exists("wastewater")) {source(here("R/download-wastewater.R"))}

p <- wastewater %>%
	distinct(date, copies_day_person_M_mn, .keep_all = TRUE) %>%
	mutate(copies_7day = rollmeanr(copies_day_person_M_mn, 7, fill = "extend")) %>%
	mutate(yday = yday(date),
		   year = year(date) %>% as.character(),
		   display_date = paste0("2020-", yday) %>% as.Date(format = "%Y-%j")) %>%
	ggplot(aes(x = display_date, y = copies_7day, color = year)) +
	geom_line(size = 1.5) +
	geom_hline(data = . %>% filter(date == max(date)), aes(yintercept = copies_7day, color = year), linetype = 2) +
	geom_text(data = . %>% group_by(year) %>% filter(date == max(date)),
			  aes(label = year), hjust = -.1, size = 6) +
	scale_color_manual(values = covidmn_colors) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.05)), sec.axis = dup_axis(), labels = comma_format(suffix = "M"), trans = "log10") +
	scale_x_date(expand = expansion(mult = c(0.01, 0.1)), date_labels = "%b", 
				 breaks = seq(as_date("2020-01-01"), as_date("2021-1-1"), by = "month")) +
	expand_limits(y = 0) +
	theme_covidmn_line() +
	theme(axis.title = element_blank(),
		  legend.position = "none") +
	labs(title = "COVID load in Twin Cities metro wastewater",
		 subtitle = "In copies per day per person",
		 caption = "Source: MPR News, Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery")
fix_ratio(p) %>% image_write(here("images/wastewater-load-years-log.png"))
