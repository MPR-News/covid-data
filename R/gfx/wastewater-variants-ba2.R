p <- wastewater_variants_nominal %>%
	filter(variant == "Omicron BA.2") %>%# View()
	ggplot(aes(x = date, y = copies_7day)) +
	geom_line(aes(y = copies_gapfill), size = .3) +
	geom_line(size = 1.5) +
	scale_x_date(date_breaks = "1 month", date_labels = "%b\n%Y", expand = expansion(mult = .02)) +
	scale_y_continuous(sec.axis = dup_axis(), expand = expansion(mult = c(0, 0.05)),
					   labels = comma_format(accuracy = 1)) +
	expand_limits(y = 0) +
	coord_cartesian(clip = "off") +
	theme_covidmn_line() +
	theme(axis.title.y = element_blank()) +
	labs(title = "Omicron BA.2 load in Twin Cities wastewater",
		 caption = "Source: Metropolitan Council Environmental Services, University of Minnesota Genomics Center\nGraph by David H. Montgomery | MPR News",
		 subtitle = "Copies per day per million people")
fix_ratio(p) %>% image_write(here("images/wastewater-variants-ba2.png"))