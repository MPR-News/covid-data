p <- cdc %>% 
	filter(date == max(date)) %>%
	select(onedose_all = administered_dose1_recip, complete_all = series_complete_yes, onedose_18 = administered_dose1_recip_18plus, complete_18 = series_complete_18plus, booster_all = additional_doses) %>%
	pivot_longer(everything(), names_sep = "_", names_to = c("name", "population")) %>%
	mutate(name = case_when(name == "onedose" ~ "At least one dose", 
							name == "booster" ~ "XBoosters",
							TRUE ~ "Completed vaccinations")) %>%
	mutate(pop_pct = value / 5639611,
		   adult_pct = value / 4336545) %>%
	filter(population == "all") %>%
	ggplot(aes(x = 1, y = value, fill = name)) +
	geom_col(width = 1, data = . %>% filter(name == "At least one dose")) +
	geom_col(width = 1, data = . %>% filter(name == "Completed vaccinations")) +
	geom_col(width = 1, data = . %>% filter(name == "XBoosters")) +
	geom_text(aes(label = percent(pop_pct, accuracy = .1), 
				  hjust = case_when(name == "At least one dose" ~ -.1, TRUE ~ 1.1),
				  color = case_when(name == "At least one dose" ~ "black", TRUE ~ "white")), size = 5.5) +
	scale_y_continuous(labels = comma_format(scale = .000001, suffix = "M", accuracy = 1), 
					   breaks = seq(0, 6000000, 1000000), name = "People",
					   sec.axis = sec_axis(trans = ~. / 5639662, labels = percent_format(accuracy = 1),
					   					breaks = seq(0, 1, .1),
					   					name = "Percent of total population")) +
	scale_color_identity() + 
	scale_fill_manual(values = covidmn_colors[c(2, 1, 3)]) +
	expand_limits(y = 5639662) +
	coord_flip() +
	theme_covidmn() +
	theme(axis.title.y = element_blank(),
		  axis.text.y = element_blank(),
		  axis.ticks.x = element_line(),
		  plot.subtitle = element_markdown(),
		  legend.position = "none",
		  axis.text.x.top = element_text(margin = margin(t = 12 * 0.9, b = 2))) +
	labs(title = "Total COVID-19 vaccinations to date",
		 subtitle = "Minnesotans with <span style='color:#56B4E9'>at least one dose</span>, <span style='color:#E69F00'>completed vaccinations</span> & <span style='color:#009E73'>boosters</span>",
		 caption = "Source: MPR News, CDC. Graph by David H. Montgomery")
fix_ratio(p, ratio = "short") %>% image_write(here("images/total-vaccinations-percent.png"))
