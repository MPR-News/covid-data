if(!exists("wastewater_variants")) {source(here("R/download-wastewater.R"))}

p <- wastewater_variants %>%
	filter(!is.na(frequency_7day)) %>%
	mutate(variant = case_when(variant == "Omicron BA.2 (Excluding BA.2.12.1)" ~ "Omicron BA.2", 
							   variant == "Omicron BA.5 (Excluding BQ.1)" ~ "Omicron BA.5", 
							   TRUE ~ variant)) %>%
	filter(variant != "Omicron BA.4 and BA.5") %>%
	ggplot(aes(x = date, y = frequency_7day, color = variant)) +
	geom_line(size = 1.5)  +
	geom_text(data = . %>% group_by(variant) %>% slice_max(frequency_7day, with_ties = FALSE), 
			  aes(label = variant), vjust = -.2, hjust = 1, size = 5) +
	scale_y_continuous(labels = percent_format(), sec.axis = dup_axis(), expand = expansion(mult = c(0, 0.08))) +
	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y", expand = expansion(mult = .01)) +
	scale_color_manual(values = c("grey80", covidmn_colors, "grey50")) +
	expand_limits(y = 0) +
	coord_cartesian(clip = "off") +
	theme_covidmn_line() +
	theme(axis.title = element_blank(),
		  plot.subtitle = element_markdown(lineheight = 1.1),
		  legend.position = "none") +
	labs(title = "Variant frequency in Twin Cities wastewater",
		 subtitle = "Relative occurrence of genetic markers for key COVID-19 variants",
		 caption = "Source: MPR News, Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery")
fix_ratio(p) %>% image_write(here("images/wastewater-variants.png"))
