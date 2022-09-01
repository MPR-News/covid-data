if(!exists("wastewater")) {source(here("R/download-wastewater.R"))}

p <- wastewater %>%
	distinct(date, copies_day_person_M_mn, .keep_all = TRUE) %>%
	mutate(copies_7day = rollmeanr(copies_day_person_M_mn, 7, fill = "extend")) %>%
	mutate(olympic_7day = (rollsumr(copies_day_person_M_mn, 7, fill = "extend") - rollmaxr(copies_day_person_M_mn, 7, fill = "extend") + rollmaxr(-copies_day_person_M_mn, 7, fill = "extend")) / 5) %>%
	filter(date >= current_report_date - 60) %>%
	ggplot(aes(x = date, y = copies_day_person_M_mn)) +
	geom_col() +
	geom_line(aes(y = copies_7day), size = 1.5, color = covidmn_colors[4]) +
	geom_line(aes(y = olympic_7day), size = 1.5, color = covidmn_colors[3]) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.05)), sec.axis = dup_axis(), labels = comma_format(suffix = "M")) +
	scale_x_date(date_breaks = "1 week", date_labels = "%b\n%d", expand = expansion(mult = .01)) +
	expand_limits(y = 0) +
	theme_covidmn() +
	theme(axis.title.x = element_blank(),
		  axis.title.y.right = element_blank(),
		  axis.ticks.x = element_line(),
		  plot.subtitle = element_markdown(lineheight = 1.1)) +
	labs(title = "COVID load in Twin Cities metro wastewater",
		 subtitle = "The <span style = 'color:#D55E00'>dark orange line</span> is a seven-day rolling average, while the <span style = 'color:#009E73'>green line</span> is <br>an \"Olympic average\" that drops the highest and lowest values.",
		 caption = "Source: MPR News, Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery",
		 y = "Copies per day per person")
fix_ratio(p) %>% image_write(here("images/wastewater-load-trunc.png"))
