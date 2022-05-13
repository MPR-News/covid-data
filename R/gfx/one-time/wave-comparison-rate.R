p <- covid_trends_actual %>%
	filter(cases_complete == TRUE) %>%
	mutate(wave = case_when(date >= as_date("2020-10-05") & date <= as_date("2020-12-28") ~ "Fall 2020",
							# date >= as_date("2020-03-28") & date <= as_date("2020-06-23") ~ "Spring 2020",
							date >= as_date("2021-03-08") & date <= as_date("2021-07-02") ~ "Spring 2021",
							# date >= as_date("2021-07-04") & date <= as_date("2021-10-04") ~ "Summer 2021",
							date >= as_date("2021-12-21") & date <= as_date("2022-03-1") ~ "Omicron",
							date >= as_date("2022-04-1") ~ "Spring 2022",
							TRUE ~ NA_character_) %>%
		   	as_factor()) %>%
	mutate(pct_chg = new_cases / lag(new_cases, 7) - 1) %>%
	filter(!is.na(wave)) %>%
	group_by(wave) %>%
	mutate(days_since_start = as.numeric(date - min(date)),
		   weeks_since_start = days_since_start / 7) %>%
	filter(days_since_start <= 55) %>%
	ggplot(aes(x = weeks_since_start, y = pct_chg, color = wave)) +
	geom_hline(yintercept = 0, linetype = 2) +
	# geom_vline(data = . %>% group_by(wave) %>% filter(index == max(index)), aes(xintercept = weeks_since_start, color = wave), linetype = 3) +
	geom_line(size = .5) +
	geom_line(data = . %>% filter(wave == "Spring 2022"), size = 1.5) +
	geom_text(data = . %>% group_by(wave) %>% filter(pct_chg == max(pct_chg)), aes(label = wave), hjust = 0, vjust = -.2, size = 6) +
	scale_color_manual(values = covidmn_colors) +
	scale_y_continuous(labels = signs_format(add_plusses = TRUE, format = scales::percent, accuracy = 1),
					   expand = expansion(mult = c(0, 0.05)), breaks = seq(-1, 1, .2), sec.axis = dup_axis()) +
	scale_x_continuous(breaks = seq(0, 20, 1), expand = expansion(mult = .02)) +
	theme_covidmn_line() +
	theme(axis.title.y = element_blank(),
		  axis.title.x = element_text(margin = margin(b = 5)),
		  legend.position = "none") +
	labs(title = "Percent increase in new cases by wave in MN",
		 subtitle = "Rate of change over prior week, where +0% means the metric is flat",
		 caption = caption,
		 x = "Weeks since start of wave")
fix_ratio(p) %>% image_write(here("images/wave-comparison-rate.png"))
