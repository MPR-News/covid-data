if(!exists("cases_age")) {source(here("R/load-data/download-cases.R"))}

p <- cases_age %>%
	filter(age_group == "65+") %>%
	mutate(yday = yday(mmwr_enddate),
		   year = year(mmwr_enddate) %>% as.character(),
		   display_date = paste0("2020-", yday) %>% as.Date(format = "%Y-%j")) %>%
	filter(mmwr_enddate < max(mmwr_enddate)) %>%
	ggplot(aes(x = display_date, y = new_cases_percap, color = year)) +
	geom_line(size = 1.5) + 
	geom_text_repel(data = . %>% group_by(year) %>% filter(mmwr_enddate == max(mmwr_enddate)),
			  aes(label = year), hjust = -.1, size = 6, direction = "y", fontface = "bold") +
	scale_x_date(expand = expansion(mult = c(0.01, 0.1)), date_labels = "%b", 
				 breaks = seq(as_date("2020-01-01"), as_date("2021-1-1"), by = "month")) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.02)), limits = c(0, NA),
					   sec.axis = dup_axis(), labels = comma_format(accuracy = 1)) +
	coord_cartesian(clip = "off") +
	theme_covidmn() +
	theme(axis.title = element_blank(),
		  axis.ticks.x = element_line(),
		  axis.title.y.right = element_blank(),
		  legend.position = "none") +
	labs(title = "New COVID-19 cases per capita among seniors 65+",
		 subtitle = "Confirmed cases per 100,000 last week in Minnesota",
		 caption = caption)
fix_ratio(p, ratio = "rect") %>% image_write(here("images/new-cases-age-65.png"))
