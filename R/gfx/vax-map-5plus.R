p <- county_map %>%
	transmute(county = str_to_upper(NAME)) %>%
	left_join(vaccine_1x_age_county %>% 
			  	mutate(county = str_replace_all(county, "ST LOUIS", "ST. LOUIS")) %>%
			  	filter(report_date == max(report_date, na.rm = TRUE), 
			  		   age == "5+"), 
			  by = c("county")) %>%
	mutate(bins = case_when(percent_completed < .1 ~ "0% - 10%",
							percent_completed < .2 ~ "10% - 20%",
							percent_completed < .3 ~ "20% - 30%",
							percent_completed < .4 ~ "30% - 40%",
							percent_completed < .5 ~ "40% - 50%",
							TRUE ~ "50%+") %>% 
		   	fct_relevel("0% - 10%", "10% - 20%", "20% - 30%", "30% - 40%", "40% - 50%", "50%+")) %>%
	arrange(desc(percent_completed)) %>%
	ggplot() +
	geom_sf(aes(fill = bins), size = .1) +
	scale_fill_brewer(palette = "YlGn", drop = FALSE, limits = c("0% - 10%", "10% - 20%", "20% - 30%", "30% - 40%", "40% - 50%", "50%+")) +
	theme_covidmn() +
	theme(axis.text.x = element_blank(),
		  axis.text.y = element_blank(),
		  legend.position = "right",
		  legend.key.height = unit(1.7, "cm"),
		  legend.key.width = unit(1, "cm")) +
	labs(title = "MN COVID-19 vaccination rate",
		 subtitle = "Share of residents 5 or older with up-to-date COVID vaccinations",
		 caption = caption, 
		 fill = "Share of residents 5+")
fix_ratio(p) %>% image_write(here("images/vax-map-5plus.png"))
