# Structure for CSV files on this repository

This page is currently incomplete, but will eventually contain guides to understanding all the CSV files in this repository.

## [`covid_data_actual.csv`](https://github.com/MPR-News/covid-data/blob/master/data/covid_data_actual.csv) (daily data by *actual* date)

This dataset compiles COVID-19 metrics based on the actual date an event — such as COVID test, hospital admission, or death — as of the most recent report from the Minnesota Department of Health. 

Each row represents one day of data. The columns are:

- `date`: The date various events took place, formatted in the [ISO 8601 standard](https://en.wikipedia.org/wiki/ISO_8601): `YYYY-MM-DD` 
- `day`: The day of the week of the given `date`, unabbreviated
- `new_cases`: The number of new positive COVID-19 tests taking place on the given `date`
- `new_tests`: The number of total (positive and negative) COVID-19 tests taking place on the given `date`
- `new_icu`: The number of new admissions of COVID-19 patients to intensive care unit (ICU) hospital beds on the given `date`
- `new_nonicu`: The number of new admissions of COVID-19 patients to non-intensive care hospital beds on the given `date`
- `new_hosp`: The number of new admissions of COVID-19 patients on the given `date`, regardless of bed type. This equals `new_icu + new_nonicu`
- `new_deaths`: The number of COVID-19 deaths on the given `date`
- `positivity`: The positivity rate, or positive cases as a share of total cases, for all tests taking place on the given `date`
- `cases_complete`: If `FALSE`, the data is less than one week old, and a significant share of cases (and most other events) taking place that day may not have been reported yet. If `TRUE`, then in normal circumstances most case data has been reported (though dumps of old, backlogged data are not uncommon). Hospitalization data also includes a lag time, and the one-week lag for cases can be a helpful proxy for whether hospitalization data is mostly complete. 
- `deaths_complete`: If `FALSE`, the data is less than 21 days old, and a significant share of deaths taking place that day may not have been reported yet. 

## [`covid_trends_actual.csv`](https://github.com/MPR-News/covid-data/blob/master/data/covid_trends_actual.csv) (seven-day rolling averages by *actual* date)

This dataset is structured identially to `covid_data_actual.csv`, but each row represents the average of the seven days of data leading up to and including the given `date`. 

In most cases this dataset is more useful for understanding what is going on with COVID-19, because daily data is subject to day-of-week effects. For example, COVID-19 tests are more likely to occur on Mondays, and less likely to occur on weekends, so it could be easy to misread the day-over-day jump from a Sunday to a Monday as representing a spike. This dataset accounts for those day-of-week effects.

## [`covid_data_report.csv`](https://github.com/MPR-News/covid-data/blob/master/data/covid_data_report.csv) (daily data by *report* date)

This dataset compiles COVID-19 metrics based on the date that the Minnesota Department of Health (MDH) reported it as part of its [Situation Update for COVID-19](https://www.health.state.mn.us/diseases/coronavirus/situation.html) page. MDH reported this data almost every day from the start of the pandemic through July 2021; at that point it shifted to reports on weekdays. Days with no report are omitted. Some data does not exist for the entire run of the dataset, such as vaccinations.

For data from earlier in the pandemic, the actual-date data in [`covid_data_actual.csv`](https://github.com/MPR-News/covid-data/blob/master/data/covid_data_actual.csv) will be more reliable. However, data by report date can be useful for understanding current trends. Also, some data is currently only available by report date, including vaccinations.

Each row represents data from one day's report. Days with no reports are missing. The columns are:

- `date`: The date MDH reported the data, formatted in the [ISO 8601 standard](https://en.wikipedia.org/wiki/ISO_8601): `YYYY-MM-DD` 
- `day`: The day of the week of the given `date`, unabbreviated
- `new_cases`: The number of newly reported positive tests as of the given report `date`
- `new_antigen_cases`: The number of newly reported cases from antigen tests as of the given report `date`. (The number of newly reported cases from PCR tests can be calculated by `new_cases - new_antigen_cases`)
- `new_tests`: The number of newly reported total tests (positive and negative) as of the given report `date`
- `new_antigen_tests`: The number of newly reported total antigen tests (positive and negative) as of the given report `date`. (The number of newly reported PCR tests can be calculated by `new_tests - new_antigen_tests`)
- `positivity`: The daily positivity rate, or number of new cases reported on the given report `date` as a share of new tests reported that day
- `new_hosp`: The number of newly reported COVID-19 hospital admissions, regardless of bed type, as of the given report `date`
- `new_icu`: The number of newly reported COVID-19 hospital admissions to intensive care unit (ICU) beds as of the given report `date`. (The number of admissions to non-ICU beds can be calculated by `new_hosp - new_icu`)
- `new_deaths`: The number of newly reported COVID-19 deaths as of the given report `date`
- `new_ltc_deaths`: The number of newly reported COVID-19 deaths among residents of long-term care facilities as of the given report `date`
- `new_recovered`: The number of newly reported people with COVID-19 who MDH says no longer need to isolate. The use of "recovered" as a variable name here is a shorthand and does not imply anything about whether individuals are still suffering symptoms from COVID or "long COVID"
- `new_vax_doses`: The number of newly reported COVID-19 vaccine doses as of the given report `date`, regardless of how many doses the recipient has received
- `new_vax_onedose`: The number of newly reported Minnesotans who have received at least one dose of a COVID-19 vaccine, as of the given report `date`
- `new_vax_complete`: The number of newly reported Minnesotans who are "fully vaccinated," defined as one dose of the Johnson & Johnson vaccine or two doses of the Pfizer or Moderna vaccines, as of the given report `date`
- `new_vax_boosted`: The number of newly reported Minnesotans who have received a "booster" shot as of the given report `date`
- `active_cases`: The estimated number of Minnesotans with active COVID-19 infections as of the given report `date`. Calculated by taking the number of total cases minus the number of total people who no longer need to isolate and the number who have died of COVID-19

## [`covid_trends_report.csv`](https://github.com/MPR-News/covid-data/blob/master/data/covid_trends_report.csv) (seven-day rolling averages by *report* date)

This dataset compiles the report-date data from [`covid_data_report.csv`](https://github.com/MPR-News/covid-data/blob/master/data/covid_data_report.csv), but as rolling seven-day averages. 

Because not every day in the time period has data, calculating rolling averages for this is more complex than for the actual-date data. Programmers can view the source code to do this in [`process-data.R`](https://github.com/MPR-News/covid-data/blob/master/R/load-data/process-data.R). In short, the method is to sum up all the data reported within seven calendar days of a given report, dividing by the number of days of data in that period.

Each row represents the average over the seven calendar days up to and including the given date. Each column represents:

- `date`: The date MDH reported the data, formatted in the [ISO 8601 standard](https://en.wikipedia.org/wiki/ISO_8601): `YYYY-MM-DD` 
- `day`: The day of the week of the given `date`, unabbreviated
- `new_cases`: The average number of new COVID-19 cases reported over the seven days up to and including the given `date`
- `new_tests`: The average number of new COVID-19 tests reported over the seven days up to and including the given `date`
- `new_deaths`: The average number of new COVID-19 deaths reported over the seven days up to and including the given `date`
- `new_ltc_deaths`: The average number of new COVID-19 deaths reported among residents of long-term care facilities over the seven days up to and including the given `date`
- `new_hosp`: The average number of new COVID-19 hospital admissions, regardless of bed type, reported over the seven days up to and including the given `date`
- `positivity`: The average positivity rate, or the percent of positive tests among all tests reported over the seven days up to and including the given `date`. Note that this is calculated by summing up all the cases and tests and dividing, not taking the average of each individual day's daily positivity rate
- `positivity_pcr`: The average positivity rate for PCR tests only reported over the seven days up to and including the given `date`
- `active_cases`: The average number of active cases over the seven days up to and including the given `date`
- `new_vax_doses`: The average number of newly reported COVID-19 vaccine doses administered over the seven days up to and including the given `date`
- `new_vax_onedose`: The average number of newly reported people with at least one dose of a COVID-19 vaccine over the seven days up to and including the given `date`
- `new_vax_complete`: The average number of newly reported people with complete series of COVID-19 vaccines (defined as one shot of Johnson & Johnson or two shots of Pfizer or Moderna) over the seven days up to and including the given `date`
- `new_vax_boosted`: The average number of newly reported people with COVID-19 booster shots over the seven days up to and including the given `date`
- `new_antigen_cases`: The average number of new COVID-19 cases resulting from antigen tests over the seven days up to and including the given `date`
- `new_antigen_tests`: The average number of new COVID-19 antigen tests over the seven days up to and including the given `date

## [`covid_totals_report.csv`](https://github.com/MPR-News/covid-data/blob/master/data/covid_totals_report.csv) (cumulative totals by report date)

Each row represents data from one day's report. Days with no reports are missing. The columns are:

- `date`: The date MDH reported the data, formatted in the [ISO 8601 standard](https://en.wikipedia.org/wiki/ISO_8601): `YYYY-MM-DD` 
- `day`: The day of the week of the given `date`, unabbreviated
- `cases_removed`: This is *not* a cumulative figure, but represents the number of COVID-19 cases removed from the data that `date`. It is included here because this is vital for converting total case counts into daily values
- `total_tests`: The cumulative number of COVID-19 tests reported as of the given `date`
- `total_antigen_tests`: The cumulative number of antigen COVID-19 tests reported as of the given `date`. (PCR tests can be calculated by `total_tests - total_antigen_tests`)
- `total_positives_reinfections`: The cumulative number of positive tests reported as of the given `date`, including people who have tested positive more than once
- `total_antigen_positives`: The cumulative number of positive antigen tests reported as of the given `date`
- `total_positives`: The cumulative number of Minnesotans who have tested positive as of the given report `date`. People who tested positive multiple times are only counted once in this column
- `total_recovered`: The cumulative number of Minnesotans who tested positive for COVID-19 but no longer need to isolate. The use of "recovered" as a variable name here is a shorthand and does not imply anything about whether individuals are still suffering symptoms from COVID or "long COVID"
- `total_deaths`: The cumulative number of Minnesotans who have died from COVID-19 as of the given report `date`
- `total_ltc_deaths`: The cumulative number of Minnesotans who have died from COVID-19 while living in a long-term care facility as of the given report `date`
- `total_hosp`: The cumulative number of Minnesotans who have been hospitalized with COVID-19 (all bed types), as of the given report `date`
- `total_icu`: The cumulative number of Minnesotans who have been hospitalized in intensive-care beds as of the given report `date`
- `total_vax_onedose`: The cumulative number of Minnesotans who have received at least one dose of a COVID-19 vaccine as of the given report `date`
- `total_vax_complete`: The cumulative number of Minnesotans who are "fully vaccinated," defined as one dose of the Johnson & Johnson vaccine or two doses of the Pfizer or Moderna vaccines, as of the given report `date`
- `total_vax_boosted`: The cumulative number of Minnesotans who have received a "booster" shot as of the given report `date`
- `total_vax_doses`: The cumulative number of COVID-19 vaccine doses administered as of the given report `date`
- `key_events`: An incomplete list of notable events in the COVID-19 pandemic on particular days

## [`vaccine-1dose-age.csv`](https://github.com/MPR-News/covid-data/blob/master/data/vaccine-data/vaccine-1dose-age.csv) (vaccinated people by age)

Each row represents vaccine counts for one age group on one report date. The columns are:

- `age`: The age group, in years
- `people_onedose`: The number of people of that age with at least one dose as of the given date
- `people_complete`: The number of people of that age who are completely vaccinated as of the given date
- `people_boosted`: The number of people of that age who are boosted as of the given date
- `filed_date`: The date the vaccination information was submitted to MDH.
- `report_date`: The date that MDH published the data online

## [`vaccine-1dose-gender.csv`](https://github.com/MPR-News/covid-data/blob/master/data/vaccine-data/vaccine-1dose-gender.csv) (vaccinated people by gender)

Each row represents vaccine counts for one age group on one report date. The columns are:

- `gender`: The gender
- `people_onedose`: The number of people of that gender with at least one dose as of the given date
- `people_complete`: The number of people of that gender who are completely vaccinated as of the given date
- `people_boosted`: The number of people of that gender who are boosted as of the given date
- `filed_date`: The date the vaccination information was submitted to MDH.
- `report_date`: The date that MDH published the data online

## [`vaccine-1dose-county.csv`](https://github.com/MPR-News/covid-data/blob/master/data/vaccine-data/vaccine-1dose-county.csv) (vaccinated people by gender)

Each row represents vaccine counts for one age group on one report date. The columns are:

- `county`: The Minnesota county (in all-caps for joining purposes)
- `people_onedose`: The number of people living in that county with at least one dose as of the given date
- `people_complete`: The number of people living in that county who are completely vaccinated as of the given date
- `people_boosted`: The number of people living in that county who are boosted as of the given date
- `filed_date`: The date the vaccination information was submitted to MDH.
- `report_date`: The date that MDH published the data online

## [`vaccine-1dose-county.csv`](https://github.com/MPR-News/covid-data/blob/master/data/vaccine-data/vaccine-1dose-age-county.csv) (the percent of people vaccinated in each county by age group)

Each row represents vaccine percentages for one age group in one county on one report date. The columns are:

- `county`: The Minnesota county (in all-caps for joining purposes)
- `percent_onedose`: The number of people living in that county with at least one dose as of the given date
- `percent_complete`: The number of people living in that county who are completely vaccinated as of the given date
- `percent_boosted`: The number of people living in that county who are boosted as of the given date
- `age`: Age groups. The options are: "5+", "12+", "16+", "50-64", "65+", "Total population"
- `filed_date`: The date the vaccination information was submitted to MDH.
- `report_date`: The date that MDH published the data online

## ['combined_county_data.csv'](https://github.com/MPR-News/covid-data/blob/master/data/combined_county_data.csv) (cases by county, long format)

Each row represents the cumulative number of cases and deaths reported in a Minnesota county on a given date. The columns are: 

- `date`: The date the data was reported by MDH
- `geoid`: The unique five-digit FIPs code for the given county, where the first two digits represents the state ("27" for Minnesota) and the final three the county
- `county`: The name of the given county
- `region`: Which region of the state MPR classified the county in
- `pop`: The population of the given county, as of the 2015-19 five-year American Community Survey estimates. (This outdated population figure is used for continuity with MDH estimates, since they use this estimate.)
- `cases`: The cumulative number of cases reported in the given county as of the given date
- `deaths`: The cumulative number of deaths reported in the given county as of the given date

## ['combined_county_data_wide.csv'](https://github.com/MPR-News/covid-data/blob/master/data/combined_county_data_wide.csv) (cases by county, wide format)

Each row is a Minnesota county. The columns are: 

- `geoid`: The unique five-digit FIPs code for the given county, where the first two digits represents the state ("27" for Minnesota) and the final three the county
- `county`: The name of the given county
- `region`: Which region of the state MPR classified the county in
- `pop`: The population of the given county, as of the 2015-19 five-year American Community Survey estimates. (This outdated population figure is used for continuity with MDH estimates, since they use this estimate.)
- `casesYYYMMDD`: One column for the cumulative number of cases reported as of each day in the given county, with `YYYYMMDD` representing dates in the [ISO 8601 standard](https://en.wikipedia.org/wiki/ISO_8601)
- `deathsYYYYMMDD`: One column for the cumulative number of deaths reported as of each day in the given county, with `YYYYMMDD` representing dates in the [ISO 8601 standard](https://en.wikipedia.org/wiki/ISO_8601)

## [`cases_sample_date.csv`](https://github.com/MPR-News/covid-data/blob/master/data/cases_sample_date.csv) (cases by sample date for each report date)

Each day since May 15, 2020, the Minnesota Department of Health has published a table with the number of cases by sample date for every date up to that point. MPR has collected and compiled each of those reports. By comparing them, one can see, for each given *report date*, what the *actual date* those cases came from was. 

For example, as of Wednesday March 30, 2022, tests conducted on Saturday, March 26 had resulted in 194 cases. Of those 194 cases, 81 were reported on March 30, and 113 were reported the day before on March 29. 

Each row represents a combination of sample date and report date. The columns are: 

- `date`: The sample date — the actual date on which people were tested for COVID-19
- `new_cases`: The number of *new* cases from that `date`'s tests, as of the given `report_date`.
- `total_cases`: The cumulative number of cases from tests conducted as of that `date`, as of the given `report_date`
- `report_date`: The date the data was reported by MDH
- `newly_reported_cases`: For a given sample `date`'s new cases, how many were newly reported on the given `report_date`
- `new_cases_confirmed`: The number of new cases from PCR tests conducted on the given `date`, as of the given `report_date`
- `total_cases_confirmed`: The cumulative number of cases from PCR tests conducted as of that `date`, as of the given `report_date`
- `new_cases_probable`: The number of new cases from antigen tests conducted on the given `date`, as of the given `report_date`
- `total_cases_probable`: The cumulative number of cases from antigen tests conducted as of that `date`, as of the given `report_date`