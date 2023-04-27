p <- cases_county %>%
	filter(report_date == max(report_date)) %>%
	mutate(region = fct_relevel(region, "Northwest", "Northeast", "Hennepin/Ramsey", "West Central", "East Central", "Metro suburbs", "Southwest", "Southeast")) %>%
	group_by(county) %>%
	arrange(mmwr_startdate) %>%
	group_by(date = mmwr_enddate, region) %>%
	summarize(cases = sum(new_cases, na.rm = TRUE),
			  pop = sum(pop, na.rm = TRUE)) %>%
	group_by(region) %>%
	mutate(cases_percap = cases / (pop / 100000)) %>%
	mutate(region_order = as.numeric(region)) %>%
	left_join(tibble(region = c("Northwest", "Northeast", "Hennepin/Ramsey", "West Central", "East Central", "Metro suburbs", "Southwest", "Southeast") %>% as_factor(),
					 color = covidmn_colors[c(7, 6, 1, 5, 3, 2, 8, 4)])) %>%
	filter(!is.na(region)) %>%
	mutate(region_label = paste0("<strong><span style='color:", color, "'>", region, "</span></strong>") %>% fct_reorder(region_order)) %>%
	filter(date < max(date)) %>%
	ggplot(aes(x = date, y = cases_percap, color = color)) +
	geom_line(size = 1.5) +
	geom_hline(data = . %>% filter(date == max(date)), aes(yintercept = cases_percap, color = color), linetype = 3) +
	geom_point(data = . %>% filter(date == max(date)), size = 1.5, show.legend = FALSE) +
	# geom_point(data = . %>% filter(date == min(date)), size = 1.5, show.legend = FALSE) +
	scale_y_continuous(labels = comma_format(accuracy = 1), sec.axis = dup_axis(), expand = expansion(mult = c(0.02, 0.05))) +
	scale_x_date(expand = expansion(mult = .01), breaks = seq.Date(from = as_date("2020-01-01"), to = as_date("2023-01-01"), by = "12 months"), date_labels = "%Y") +
	scale_color_identity() +
	coord_cartesian(clip = "off") +
	facet_wrap(vars(region_label), strip.position = "bottom") +
	theme_covidmn() +
	theme(axis.ticks.x = element_line(),
		  axis.title.x = element_blank(),
		  axis.title.y.right = element_blank(),
		  panel.grid.major.y = element_line(color = "grey95", size = .3),
		  legend.position = "none",
		  strip.placement = "outside",
		  # panel.border = element_rect(fill = NA, color = "#02334e"),
		  # strip.background = element_rect(fill = NA, color = "#02334e"),
		  strip.text = ggtext::element_markdown(size = 18)) +
	labs(title = "New weekly COVID-19 cases per capita by region",
		 subtitle = "Based solely on cases confirmed by the MN Department of Health.\nMost recent data may be incomplete.",
		 caption = caption,
		 y = "New cases per 100,000 residents",
		 color = "Area of state", linetype = "Area of state")
# annotation_custom(grob = ggplotify::as.grob(inset_map), xmin = as_date("2020-03-28"), xmax = as_date("2020-04-27"), ymin = 25, ymax = 45)
tmp <- tempfile()
ggsave(tmp, plot = inset_map8, width = 4.28, height = 3.91, device = "png")

p1 <- image_composite(fix_ratio(p, ratio = "square"),
					  image_read(tmp) %>% image_scale("540x493.3178"),
					  offset = "+1350+1400")
p1 %>%
	image_write(here("images/cases-by-region-facet.png"))
