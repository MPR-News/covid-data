if(!exists("breakthroughs_weighted_age_adults")) {breakthroughs_weighted_age_adults <- read_csv(here("data/breakthroughs/breakthroughs-weighted-age-adults.csv"))}

p <- breakthroughs_weighted_age_adults %>%
	filter(metric_type == "count", metric != "pop") %>%
	group_by(week_start, metric, vax_status) %>%
	summarize(value = sum(value)) %>%
	group_by(metric, vax_status) %>%
	mutate(value_3week = rollmeanr(value, 3, fill = "extend")) %>%
	group_by(week_start, metric) %>%
	mutate(pct = 1 - value_3week / sum(value_3week)) %>%
	filter(vax_status == "unvaxxed") %>%
	ggplot(aes(x = week_start, y = pct, color = metric)) +
	geom_line(size = 1.5) +
	scale_y_continuous(labels = percent_format(accuracy = 1),
					   expand = expansion(mult = c(0, 0.05)), sec.axis = dup_axis()) +
	scale_x_date(date_labels = "%b", date_breaks = "1 month") +
	scale_color_manual(values = covidmn_colors[c(2, 1, 3)]) +
	expand_limits(y = 0) +
	theme_covidmn() +
	theme(axis.ticks.x = element_line(),
		  axis.title = element_blank(),
		  legend.position = "none",
		  plot.subtitle = element_markdown(lineheight = 1.1)) +
	labs(title = "Rising share of COVID breakthroughs in MN",
		 subtitle = "Share of <span style='color:#56B4E9'>cases</span>, <span style='color:#E69F00'>deaths</span> and <span style='color:#009E73'>hospitalizations</span> that are breakthroughs,<br> among Minnesotans 18 years old or older",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/breakthrough-share.png"))
