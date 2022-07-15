inset_map8 <- left_join(county_map %>%
							select(geoid = GEOID),
						cases_county %>% 
							distinct(geoid, region) %>%
							mutate(region = fct_relevel(region, "Northwest", "Northeast", "Hennepin/Ramsey", "West Central", "East Central", "Metro suburbs", "Southwest", "Southeast")) %>%
							mutate(geoid = as.character(geoid)),
						by = "geoid") %>%
	ggplot() +
	geom_sf(aes(fill = region), size = .02) +
	scale_fill_manual(values = covidmn_colors[c(7, 6, 1, 5, 3, 2, 8, 4)]) +
	scale_x_continuous(expand = expansion(mult = .02)) +
	scale_y_continuous(expand = expansion(mult = .02)) +
	theme_void() +
	theme(legend.position = "none",
		  panel.border = element_rect(fill = NA, size = 1))
