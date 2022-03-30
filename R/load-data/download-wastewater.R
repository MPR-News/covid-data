wastewater <- read_csv("https://raw.githubusercontent.com/Metropolitan-Council/covid-poops/main/data/clean_load_data.csv", guess_max = 100000) %>%
	select(!contains("text")) %>%
	filter(!is.na(copies_day_person_M_mn)) %>%
	mutate(date = as_date(date))

wastewater_variants <- read_csv("https://github.com/Metropolitan-Council/covid-poops/raw/main/data/clean_variant_data.csv", guess_max = 100000) %>%
	select(!contains("text")) %>%
	mutate(date = as_date(date))

wastewater_variants_nominal <- read_csv("https://github.com/Metropolitan-Council/covid-poops/raw/main/data/copies_by_variant.csv", guess_max = 100000) %>%
	select(!contains("text")) %>%
	mutate(date = as_date(date))
