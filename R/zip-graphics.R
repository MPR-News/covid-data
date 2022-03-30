zip::zipr("current_charts.zip", 
		  dir(here("images"), full.names = TRUE),
		  root = here(),
		  include_directories = FALSE
)