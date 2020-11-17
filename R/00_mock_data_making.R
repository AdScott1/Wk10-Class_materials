###########################################
#####   Creation of some mock data   ######
###########################################

library(tidyverse)

# Mock data ---------------------------------------------------------------

lod_data <- tibble(lab_id = str_c("External_sample_code", str_pad(seq(1,100), width = 4, side = "left", pad = 0), sep = "_"),
                   run = str_c("Run_", rep(c(1,2,3,4), each = 25), "-" , rep(c("20/03/2019", "25/03/2019"), each = 50), sep = ""),
                   compound_a = rnorm(100, 24, 20) %>% round(digits = 3),                         # 100 concentrations, normally distributed around 24 with an SD of 20
                   compound_b = rnorm(100, 50, 50) %>% round(digits = 3)) %>%                     # 100 concentrations, normally distributed around 50 with an SD of 50
  mutate(compound_a = ifelse(compound_a < 10, "<10.0", compound_a),
         compound_b = ifelse(compound_b < 20.5, "<20.5", compound_b))       # no we use ifelse() to give all samples below the LOD an "<LOD" value

write_csv(lod_data, "data/analytical_data.csv")
