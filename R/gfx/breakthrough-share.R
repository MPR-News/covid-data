if(!exists("breakthroughs")) {breakthroughs <- read_csv(here("data/breakthroughs/breakthroughs.csv"))}

p <- breakthroughs %>%
	group_by(week_start, metric) %>%
	mutate(pct = number / sum(number)) %>%
	filter(vax == "Fully vaccinated") %>%
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
		 subtitle = "Share of <span style='color:#56B4E9'>cases</span>, <span style='color:#E69F00'>deaths</span> and <span style='color:#009E73'>hospitalizations</span> that are breakthroughs,<br> among cases 12 years old or older",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/breakthrough-share.png"))
