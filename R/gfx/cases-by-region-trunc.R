p <- combined_county_data %>%
	mutate(region = fct_relevel(region, "Northwest", "Northeast", "Hennepin/Ramsey", "West Central", "East Central", "Metro suburbs", "Southwest", "Southeast")) %>%
	group_by(county) %>%
	arrange(date) %>%
	group_by(date, region) %>%
	summarize(cases = sum(cases, na.rm = TRUE),
			  deaths = sum(deaths, na.rm = TRUE),
			  pop = sum(pop, na.rm = TRUE)) %>%
	mutate(lag_date = date - 7) %>%
	left_join(x = .,
			  y = {.} %>% select(date, region, lag_cases = cases),
			  by = c("lag_date" = "date", "region")) %>%
	group_by(region) %>%
	mutate(new_cases_percap_7day = ((cases - lag_cases) / 7) / (pop / 100000)) %>%
	mutate(region_order = as.numeric(region)) %>%
	left_join(tibble(region = c("Northwest", "Northeast", "Hennepin/Ramsey", "West Central", "East Central", "Metro suburbs", "Southwest", "Southeast") %>% as_factor(),
					 color = covidmn_colors[c(7, 6, 1, 5, 3, 2, 8, 4)])) %>%
	mutate(region_label = paste0("<strong><span style='color:", color, "'>", region, "</span></strong>") %>% fct_reorder(region_order)) %>%
	filter(!is.na(new_cases_percap_7day)) %>%
	mutate(case_odds_30 = 1 - (1 - (new_cases_percap_7day / 100000))^30 ) %>%
	mutate(case_odds_365 = 1 - (1 - (new_cases_percap_7day / 100000))^365 ) %>%
	filter(!is.na(region)) %>%
	filter(date >= max(date) - 28) %>%
	ggplot(aes(x = date, y = new_cases_percap_7day, color = color)) +
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
	labs(title = "COVID-19 cases in Minnesota regions",
		 subtitle = "Per 100,000 residents. By date reported to the MN Department of Health.",
		 capton = caption) +
	annotation_custom(grob = ggplotify::as.grob(inset_map8), xmin = current_report_date - 28, xmax = current_report_date - 21, ymin = 34, ymax = 53)
fix_ratio(p) %>% image_write(here("images/cases-by-region-trunc.png"))