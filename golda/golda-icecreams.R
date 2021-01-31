library(rvest)
library(dplyr)
library(stringr)
library(ggmap)
library(tidyr)
library(purrr)
library(readr)
library(tibble)
library(writexl)

golda_link <- read_html("https://www.goldaglida.co.il/%D7%A1%D7%A0%D7%99%D7%A4%D7%99%D7%9D/")

golda_text <- golda_link %>% 
  html_nodes(".mapto") %>% 
  html_text() %>% 
  as_tibble() %>% 
  setNames("location") %>% 
  # relevant locations
  slice(1:79) %>% 
  mutate(location = str_remove(location, "כשר")) 

# Number of columns to use
golda_text$location %>% 
  str_count(pattern = "\\n")

# Get's you most of the way!
golda_df <- golda_text %>% 
separate(., col = location, into = c("empty", "city", "empty2", "address", "number", "number_extra", "new4"), sep = "\\n", fill= "right") %>% 
  na_if("") %>% 
  mutate(street = coalesce(address, number),
         number = ifelse(!str_detect(number, "^[0-9]"), number_extra, number),
         location = paste0(street, ", ", city)) %>%
  select(city, street, number, location)

# Get lat-long for addresses
# golda_geo <- mutate_geocode(golda_df, location)

# Then reverse geocode to cross-check:
# full_info <- golda_geo %>% 
#  mutate(google_address = map2_chr(lon, lat, ~revgeocode(c(.x, .y),  output = "address"))) 

# we'll save the excel file and clean any discrepancies manually (some lat-long):(
# writexl::write_xlsx(full_info, "golda_locations_w_English.xlsx")

# # save a Heberw version:
# golda_clean <- read_xlsx("golda_locations_w_English.xlsx") %>% 
#   select(city, street, number, lon, lat) %>% 
#   write_xlsx(golda_clean, "golda_lcations.csv")