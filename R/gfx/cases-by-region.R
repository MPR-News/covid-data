if(!exists("inset_map8")) {source(here("R/inset-map8.R"))}

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
	left_join(data_frame(region = c("Northwest", "Northeast", "Hennepin/Ramsey", "West Central", "East Central", "Metro suburbs", "Southwest", "Southeast") %>% as_factor(),
						 color = c("#9e5d26", "#ffcc22", "#f7941e", "#84bd00", "#b1d1e6", "#638d00", "#02334e", "#aebdc2"))) %>%
	mutate(region_label = paste0("<strong><span style='color:", color, "'>", region, "</span></strong>") %>% fct_reorder(region_order)) %>%
	filter(!is.na(new_cases_percap_7day)) %>%
	filter(!is.infinite(new_cases_percap_7day)) %>%
	filter(date >= as_date("2022-02-01")) %>%
	ggplot(aes(x = date, y = new_cases_percap_7day, color = color)) +
	geom_line(size = 1) +
	geom_point(data = . %>% filter(date == max(date)), size = 3, show.legend = FALSE) +
	# geom_text_repel(data = . %>% filter(date == max(date)) %>% mutate(date = date + 3), aes(label = region), hjust = 0, size = 6, direction = "y", family = "Inter-Bold", point.size = NA, show.legend = FALSE) +
	scale_y_continuous(labels = comma_format(accuracy = 1), sec.axis = dup_axis(), expand = expansion(mult = c(0.01, 0.05))) +
	scale_x_date(expand = expansion(mult = c(0.01, .02)), date_breaks = "1 month", date_labels = "%b") +
	scale_color_identity() +
	expand_limits(y = 0) +
	theme_covidmn() +
	theme(axis.ticks.x = element_line(),
		  axis.title.x = element_blank(),
		  axis.title.y.right = element_blank(),
		  legend.position = "none") +
	labs(title = "New MN COVID-19 cases per capita by region",
		 subtitle = "Based solely on cases confirmed by the MN Department of Health.\nLine represents average of seven prior days of data.",
		 caption = "Source: Minnesota Department of Health. Graphic by David H. Montgomery | MPR News",
		 y = "New cases per 100,000 residents",
		 color = "Area of state", linetype = "Area of state") +
	annotation_custom(grob = ggplotify::as.grob(inset_map8), xmin = as_date("2022-3-01"), xmax = as_date("2022-4-1"), ymin = 100, ymax = 250)
fix_ratio(p) %>% image_write(here("images/cases-by-region.png"))
