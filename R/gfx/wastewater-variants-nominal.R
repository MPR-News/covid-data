p <- wastewater_variants_nominal %>%
	mutate(variant = case_when(variant == "Omicron BA.2 (Excluding BA.2.12.1)" ~ "Omicron BA.2", TRUE ~ variant)) %>%
	# filter(str_detect(variant, "Omicron BA.2|BA.4|BA.5")) %>%# View()
	ggplot(aes(x = date, y = copies_gapfill, fill = variant)) +
	geom_area() +
	scale_x_date(date_breaks = "3 months", date_labels = "%b\n%Y", expand = expansion(mult = .02)) +
	scale_y_continuous(sec.axis = dup_axis(), expand = expansion(mult = c(0, 0.05)),
					   labels = comma_format(accuracy = 1)) +
	scale_color_manual(values = covidmn_colors) +
	expand_limits(y = 0) +
	guides(color = guide_legend(override.aes = list(size = 3))) +
	coord_cartesian(clip = "off") +
	theme_covidmn_line() +
	theme(axis.title.y = element_blank(),
		  legend.position = c(.2, .75)) +
	labs(title = "Variant load in Twin Cities wastewater",
		 caption = "Source: Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery | MPR News",
		 subtitle = "Copies per day per million people",
		 fill = "Variant")
fix_ratio(p) %>% image_write(here("images/wastewater-variants-nominal.png"))
# 
# wastewater_variants_nominal %>% filter(variant == "Alpha, Beta & Gamma") %>%
# 	ggplot(aes(x = date, y = copies_7day)) +
# 	geom_line() +
# 	geom_point()
