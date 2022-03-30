# Minnesota COVID-19 data

This repository contains data and graphs about Minnesota's COVID-19 outbreak, along with code to generate it. 

Data here is released under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license](https://creativecommons.org/licenses/by-nc-sa/4.0/). That means you are free to use the data for any noncommercial purposes, provided you give reasonable credit to MPR News, and maintain this license on any alterations you make to the material. Code here is available under the [MIT License](https://opensource.org/licenses/MIT).

## Start here

See [a dashboard](https://mpr-news.github.io/covid-data/dashboard.html) with current data and charts tracking Minnesota's COVID outbreak

## Dive deeper

- [Learn how each of the below datasets is structured](https://github.com/MPR-News/covid-data/blob/master/file-structure.md)

Download raw data showing Minnesota's COVID-19 statistics from the start of the pandemic:
- [Daily data by *actual* date](https://github.com/MPR-News/covid-data/blob/master/data/covid_data_actual.csv) (the date an event such as a test, hospitalization or death actually occurred)
- [Daily data by *report* date](https://github.com/MPR-News/covid-data/blob/master/data/covid_data_report.csv) (the date the Minnesota Department of Health reported data to the public)
- [Seven-day rolling averages by *actual* date](https://github.com/MPR-News/covid-data/blob/master/data/covid_trends_actual.csv)
- [Seven-day rolling averages by *report* date](https://github.com/MPR-News/covid-data/blob/master/data/covid_trends_report_short.csv)

Download data showing Minnesota's vaccination rates from early 2021:
- [Total doses administered, by type](https://github.com/MPR-News/covid-data/blob/master/data/vaccine-data/total-doses.csv)
- [Number of people vaccinated, by age](https://github.com/MPR-News/covid-data/blob/master/data/vaccine-data/vaccine-1dose-age.csv)
- [Number of people vaccinated, by gender](https://github.com/MPR-News/covid-data/blob/master/data/vaccine-data/vaccine-1dose-gender.csv)
- [Number of people vaccinated, by county](https://github.com/MPR-News/covid-data/blob/master/data/vaccine-data/vaccine-1dose-county.csv) (note: this file is large)
- [Percent of age groups vaccinated, by county](https://github.com/MPR-News/covid-data/blob/master/data/vaccine-data/vaccine-1dose-age-county.csv)

Download data showing cases (by report date) by county (these files are large):
- [Data in a long form](https://github.com/MPR-News/covid-data/blob/master/data/combined_county_data.csv) (with one row per county per day)
- [Data in a wide form](https://github.com/MPR-News/covid-data/blob/master/data/combined_county_data_wide.csv) (with one row per county and one column per day)

Download data showing how Minnesota's actual-date COVID-19 stats have evolved with each day's report from the Minnesota Department of Health (these files are large):
- [Cases](https://github.com/MPR-News/covid-data/blob/master/data/cases_sample_date.csv)
- [Cases that are confirmed reinfections](https://github.com/MPR-News/covid-data/blob/master/data/reinfections.csv)
- [Tests](https://github.com/MPR-News/covid-data/blob/master/data/tests_table.csv)
- [Hospitalizations](https://github.com/MPR-News/covid-data/blob/master/data/hospitalizations.csv)
- [Deaths](https://github.com/MPR-News/covid-data/blob/master/data/death_date_table.csv)

Download other data:
- [Data on Minnesota's hospital capacity](https://github.com/MPR-News/covid-data/blob/master/data/hospital_capacity.csv)
- [Cases by age group by report date](https://github.com/MPR-News/covid-data/blob/master/data/demographics/age_table.csv)
- [Cases by racial or ethnic group by report date](https://github.com/MPR-News/covid-data/blob/master/data/demographics/race_table.csv)

## For programmers

This repository is currently maintained by [David H. Montgomery](https://github.com/dhmontgomery). Pull requests from the community are welcome.

The data and charts here are primarily obtained and generated via code in the [R programming language](https://www.r-project.org). Scripts and RMarkdown files are located in the R folder.

`generate-graphs.Rmd` is the primary file for generating this data each day. It links to separate scripts that scrape data off the Minnesota Department of Health website and produce graphs. 
