p <- covid_trends_actual %>%
	mutate(icu_ratio = new_icu / new_hosp) %>%
	filter(date >= as_date("2020-04-01")) %>%
	ggplot(aes(x = date, y = icu_ratio)) +
	geom_line() +
	geom_hline(data = . %>% filter(date == max(date)), aes(yintercept = icu_ratio), linetype = 3) +
	geom_point(data = . %>% filter(date == max(date))) +
	scale_y_continuous(labels = percent_format(accuracy = 1), sec.axis = dup_axis(), expand = expansion(mult = c(0, 0.05))) +
	scale_x_date(date_labels = "%b\n%Y", date_breaks = "3 months", expand = expansion(mult = .02)) +
	expand_limits(y = 0) +
	theme_covidmn_line() +
	theme(axis.title = element_blank()) +
	labs(title = "Share of MN COVID-19 hospitalizations in ICU beds",
		 caption = caption)
fix_ratio(p) %>% image_write(here("images/hospital-admissions-icu-share.png"))
