if(!exists("wastewater_variants")) {source(here("R/download-wastewater.R"))}

p <- wastewater_variants %>%
	filter(!is.na(frequency_7day)) %>%
	ggplot(aes(x = date, y = frequency_7day, color = variant)) +
	geom_line(size = 1.5)  +
	scale_y_continuous(labels = percent_format(), sec.axis = dup_axis(), expand = expansion(mult = c(0, 0.05))) +
	scale_x_date(date_breaks = "2 months", date_labels = "%b\n%Y", expand = expansion(mult = .01)) +
	scale_color_manual(values = covidmn_colors) +
	expand_limits(y = 0) +
	coord_cartesian(clip = "off") +
	theme_covidmn_line() +
	theme(axis.title = element_blank(),
		  plot.subtitle = element_markdown(lineheight = 1.1),
		  legend.position = "none") +
	labs(title = "Variant frequency in Twin Cities wastewater",
		 subtitle = "Relative occurrence of genetic markers for the <span style='color:#E69F00'>alpha, beta and gamma <br>variants</span>, the <span style='color:#56B4E9'>delta variant</span> and <span style='color:#009E73'>omicron variant BA.1</span> and <span style='color:#D55E00'>omicron BA.2</span>",
		 caption = "Source: MPR News, Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery")
fix_ratio(p) %>% image_write(here("images/wastewater-variants.png"))
