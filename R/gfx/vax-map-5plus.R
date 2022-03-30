p <- county_map %>%
	transmute(county = str_to_upper(NAME)) %>%
	left_join(vaccine_1x_age_county %>% 
			  	filter(report_date == max(report_date, na.rm = TRUE), 
			  		   age == "5+"), 
			  by = c("county")) %>%
	mutate(bins = case_when(percent_onedose < .4 ~ "30% - 40%",
							percent_onedose < .5 ~ "40% - 50%",
							percent_onedose < .6 ~ "50% - 60%",
							percent_onedose < .7 ~ "60% - 70%",
							percent_onedose < .8 ~ "70% - 80%",
							percent_onedose < .9 ~ "80% - 90%",
							TRUE ~ "90% - 100%") %>% 
		   	fct_relevel("30% - 40%", "40% - 50%", "50% - 60%", "60% - 70%", "70% - 80%", "80% - 90%", "90% - 100%")) %>%
	arrange(desc(percent_onedose)) %>%
	ggplot() +
	geom_sf(aes(fill = bins), size = .1) +
	scale_fill_brewer(palette = "YlGn") +
	theme_covidmn() +
	theme(axis.text.x = element_blank(),
		  axis.text.y = element_blank(),
		  legend.position = "right",
		  legend.key.height = unit(2, "cm"),
		  legend.key.width = unit(1, "cm")) +
	labs(title = "MN COVID-19 vaccination rate",
		 subtitle = "Share of residents 5 or older with at least one vaccine dose",
		 caption = caption, 
		 fill = "Share of residents 5+")
fix_ratio(p) %>% image_write(here("images/vax-map-5plus.png"))
