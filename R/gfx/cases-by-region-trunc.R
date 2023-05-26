p <- cases_county %>%
	filter(report_date == max(report_date)) %>%
	mutate(region = fct_relevel(region, "Northwest", "Northeast", "Hennepin/Ramsey", "West Central", "East Central", "Metro suburbs", "Southwest", "Southeast")) %>%
	group_by(county) %>%
	arrange(mmwr_enddate) %>%
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
	filter(date >= (max(date) - 35)) %>% 
	ggplot(aes(x = date, y = cases_percap, color = color)) +
	geom_line(size = 1.5) +
	geom_text_repel(data = . %>% group_by(region) %>% filter(date == max(date)), aes(label = region, x = date + .5), 
					hjust = 0, direction = "y", fontface = "bold", size = 5) +
	geom_point(data = . %>% filter(date == max(date)), size = 3, show.legend = FALSE) +
	scale_color_identity() +
	scale_y_continuous(labels = comma_format(accuracy = 1), sec.axis = dup_axis(), expand = expansion(mult = c(0, 0.05))) +
	scale_x_date(date_labels = "%b %d", expand = expansion(mult = c(.02, .3))) + 
	expand_limits(y = 0) +
	theme_covidmn_line() +
	theme(axis.title = element_blank()) +
	labs(title = "Weekly COVID-19 cases in Minnesota regions",
		 subtitle = "Per 100,000 residents. Recent weeks may have incomplete data.",
		 capton = caption) +
	annotation_custom(grob = ggplotify::as.grob(inset_map8), xmin = current_report_date - 13, xmax = current_report_date + 12, ymin = 25, ymax = 45)
fix_ratio(p) %>% image_write(here("images/cases-by-region-trunc.png"))