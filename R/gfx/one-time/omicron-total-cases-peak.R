p <- covid_trends_actual %>%
	filter(date >= as_date("2021-12-26"), date <= as_date("2022-02-05")) %>%
	mutate(peak_fill = case_when(date <= as_date("2022-01-11") ~ "Before", TRUE ~ "After")) %>%
	ggplot(aes(x = date, y = new_cases)) +
	geom_area(fill = covidmn_colors[1]) +
	geom_area(aes(fill = peak_fill)) +
	geom_vline(xintercept = as_date("2022-01-11"), linetype = 2) +
	geom_text(data = . %>% filter(new_cases == max(new_cases)), aes(label = "Jan. 11 peak", hjust = -.05, vjust = -.1)) +
	annotate(geom = "text", x = as_date("2022-01-04"), y = 5000, label = "185.6K total cases", size = 6, color = "white") +
	annotate(geom = "text", x = as_date("2022-01-20"), y = 5000, label = "184.4K total cases", size = 6, color = "white") +
	scale_fill_manual(values = covidmn_colors) +
	scale_x_date(date_breaks = "4 days", date_labels = "%b\n%d", expand = expansion(mult = .02)) +
	scale_y_continuous(expand = expansion(mult = c(0, 0.05)),
					   labels = comma_format(scale = .001, suffix = "K"),
					   sec.axis = dup_axis()) +
	coord_cartesian(clip = "off") +
	theme_covidmn_line() +
	theme(legend.position = "none",
		  axis.title = element_blank()) +
	labs(title = "New daily cases in Minnesota's omicron wave",
		 caption = caption)
fix_ratio(p, ratio = "short") %>% image_write(here("images/omicron-total.png"))


# covid_data_actual %>% 
# 	filter(date >= as_date("2021-12-26"), date <= as_date("2022-02-05")) %>%
# 	mutate(peak_fill = case_when(date <= as_date("2022-01-11") ~ "Before", TRUE ~ "After")) %>%
# 	group_by(peak_fill) %>%
# 	mutate(cumsum_cases = cumsum(new_cases)) %>%
# 	select(date, day, new_cases, cumsum_cases, peak_fill) %>% 
# 	ggplot(aes(x = date, y = cumsum_cases)) +
# 	# geom_area(fill = covidmn_colors[1]) +
# 	geom_area(aes(fill = peak_fill)) +
# 	geom_vline(xintercept = as_date("2022-01-11"), linetype = 2) +
# 	geom_text(data = . %>% filter(new_cases == max(new_cases)), aes(label = "Jan. 11 peak", hjust = -.05, vjust = -.1))
