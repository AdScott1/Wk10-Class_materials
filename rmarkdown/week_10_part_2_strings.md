---
title: "Week 10 - Part II - Working with Strings"
author: "Jose Luis Rodriguez Gil"
date: "09/11/2020"
output: 
  html_document:
    number_sections: true
    keep_md: true
---









# Working with character strings

## Example 1 - Data from commercial laboratories

Unfortunately all the good practices we have learned about how to set up your data files, how to name variables, how *not to* log your dates, etc skip our control the moment we send samples to analyze to a commercial lab, or receive data from collaborators. In those cases it comes handy to know how to *fix* some of the issues **they** have created for us. This applies as well to *subpar* output files by some analytical equipment or logger.

Lets load some data of the kind that we could get from an analytical lab.

We would want to merge this results with our own log book  and site log to create a larger dataset to be used for analysis and visualization. 

Unfortunately, there are a few things that complicate this process:

- We need to join this table with our logbook using the *sample id*. Our sample IDs are of the form **0001**, but the lab's information management system added the *"External_sample_code_"* preface to my ID
- I want to keep the information related to which run the sample was processed in and on which date, but these two pieces of information are provided together in the *run* variable



```r
lab_data_original <- read_csv(here("data", "analytical_data.csv"))
```

```
## Parsed with column specification:
## cols(
##   lab_id = col_character(),
##   run = col_character(),
##   compound_a = col_character(),
##   compound_b = col_character()
## )
```

```r
print(lab_data_original)
```

```
## # A tibble: 100 x 4
##    lab_id                    run              compound_a compound_b
##    <chr>                     <chr>            <chr>      <chr>     
##  1 External_sample_code_0001 Run_1-20/03/2019 <10.0      61.036    
##  2 External_sample_code_0002 Run_1-20/03/2019 53.932     52.153    
##  3 External_sample_code_0003 Run_1-20/03/2019 18.131     46.935    
##  4 External_sample_code_0004 Run_1-20/03/2019 40.785     84.442    
##  5 External_sample_code_0005 Run_1-20/03/2019 27.876     <20.5     
##  6 External_sample_code_0006 Run_1-20/03/2019 15.819     169.253   
##  7 External_sample_code_0007 Run_1-20/03/2019 13.12      59.478    
##  8 External_sample_code_0008 Run_1-20/03/2019 <10.0      30.057    
##  9 External_sample_code_0009 Run_1-20/03/2019 <10.0      <20.5     
## 10 External_sample_code_0010 Run_1-20/03/2019 <10.0      36.951    
## # … with 90 more rows
```

What can we do??

Well, thankfully the *Tidyverse* comes equiped with the `{stringr}` package (loads automatically with `{tydiverse}`), which has a bunch of tools to work with strings. You can find more about it on the package [site](https://stringr.tidyverse.org/), or on the [cheat sheet](https://github.com/rstudio/cheatsheets/blob/master/strings.pdf). For this package, i highly recomend you keep the cheat sheet handy, especially the second page. I have to go check this thing up, minimum once a week.

The package itself and the tools are not difficult, the problem is that in order to work with strings we need to be familiar with **Regular Expressions (regex)** which in my opinion are the most evil thing one has to deal with as a data scientist.

You can find more on working with strings and regex in [Chapter 14](https://r4ds.had.co.nz/strings.html) of *R for Data Science*

### Extracting our sample ID

Let's start with the ID. We need to extract our ID (e.g. *0001*) from the `lab_id` colum. 

For that we are going to `mutate()` the dataset to create a `sample_id` variable. For that we are going to use the `{stringr}` function `str_extract()`


```r
lab_data <- lab_data_original %>% 
  mutate(sample_id = str_extract(lab_id, "(?<=External_sample_code_)[:digit:]+")) %>% 
  select(sample_id, everything())

print(lab_data)
```

```
## # A tibble: 100 x 5
##    sample_id lab_id                    run              compound_a compound_b
##    <chr>     <chr>                     <chr>            <chr>      <chr>     
##  1 0001      External_sample_code_0001 Run_1-20/03/2019 <10.0      61.036    
##  2 0002      External_sample_code_0002 Run_1-20/03/2019 53.932     52.153    
##  3 0003      External_sample_code_0003 Run_1-20/03/2019 18.131     46.935    
##  4 0004      External_sample_code_0004 Run_1-20/03/2019 40.785     84.442    
##  5 0005      External_sample_code_0005 Run_1-20/03/2019 27.876     <20.5     
##  6 0006      External_sample_code_0006 Run_1-20/03/2019 15.819     169.253   
##  7 0007      External_sample_code_0007 Run_1-20/03/2019 13.12      59.478    
##  8 0008      External_sample_code_0008 Run_1-20/03/2019 <10.0      30.057    
##  9 0009      External_sample_code_0009 Run_1-20/03/2019 <10.0      <20.5     
## 10 0010      External_sample_code_0010 Run_1-20/03/2019 <10.0      36.951    
## # … with 90 more rows
```

Let's look at it in detail.

- The `(?<=External_sample_code_)` is asking to find a section of the string that **is preceded by** *"External_sample_code_"*
- The `[:digit:]` part is asking specifically for numbers
- The `+` is saying that we want to get back one or more elements

Another way of doing it:



```r
lab_data_original %>% 
  mutate(sample_id = str_extract(lab_id, "[:digit:]+")) %>% 
    select(sample_id, everything())
```

```
## # A tibble: 100 x 5
##    sample_id lab_id                    run              compound_a compound_b
##    <chr>     <chr>                     <chr>            <chr>      <chr>     
##  1 0001      External_sample_code_0001 Run_1-20/03/2019 <10.0      61.036    
##  2 0002      External_sample_code_0002 Run_1-20/03/2019 53.932     52.153    
##  3 0003      External_sample_code_0003 Run_1-20/03/2019 18.131     46.935    
##  4 0004      External_sample_code_0004 Run_1-20/03/2019 40.785     84.442    
##  5 0005      External_sample_code_0005 Run_1-20/03/2019 27.876     <20.5     
##  6 0006      External_sample_code_0006 Run_1-20/03/2019 15.819     169.253   
##  7 0007      External_sample_code_0007 Run_1-20/03/2019 13.12      59.478    
##  8 0008      External_sample_code_0008 Run_1-20/03/2019 <10.0      30.057    
##  9 0009      External_sample_code_0009 Run_1-20/03/2019 <10.0      <20.5     
## 10 0010      External_sample_code_0010 Run_1-20/03/2019 <10.0      36.951    
## # … with 90 more rows
```

Let's look at it in detail.

- The `[:digit:]` part is asking specifically for numbers
- The `+` is saying that we want to get back one or more elements

In this case this works because our sample ID is the only digit  select(sample_id, everything())
   s there, but if there are other characters, we need to be more precise, hence the previous aproach.


### Splitting the run and analysis_date info


```r
lab_data %>% 
  mutate(run_date = str_extract(run, "(?<=-)[:graph:]*")) %>%
  mutate(run = str_extract(run, "[:graph:]*(?=-)"))
```

```
## # A tibble: 100 x 6
##    sample_id lab_id                    run   compound_a compound_b run_date  
##    <chr>     <chr>                     <chr> <chr>      <chr>      <chr>     
##  1 0001      External_sample_code_0001 Run_1 <10.0      61.036     20/03/2019
##  2 0002      External_sample_code_0002 Run_1 53.932     52.153     20/03/2019
##  3 0003      External_sample_code_0003 Run_1 18.131     46.935     20/03/2019
##  4 0004      External_sample_code_0004 Run_1 40.785     84.442     20/03/2019
##  5 0005      External_sample_code_0005 Run_1 27.876     <20.5      20/03/2019
##  6 0006      External_sample_code_0006 Run_1 15.819     169.253    20/03/2019
##  7 0007      External_sample_code_0007 Run_1 13.12      59.478     20/03/2019
##  8 0008      External_sample_code_0008 Run_1 <10.0      30.057     20/03/2019
##  9 0009      External_sample_code_0009 Run_1 <10.0      <20.5      20/03/2019
## 10 0010      External_sample_code_0010 Run_1 <10.0      36.951     20/03/2019
## # … with 90 more rows
```

For the step of creating a new `run_date` variable:

- The `(?<=-)` is asking to find a section of the string that **is preceded by** *"-"*
- The `[:graph:]` part is asking for any character (numbers, letters, symbols). We need to be more general, because we want to include the decimal period
- The `*` is saying that we want to get back zero or more elements


For the step of overwritting the `run` variable:

- The `[:graph:]` part is asking for any character (numbers, letters, symbols). We need to be more general, because we want to include the decimal period
- The `*` is saying that we want to get back zero or more elements
- The `(?=-)` is asking that all that was listed before needs to be followed by *"-"*

As you can see... This whole thing requires some creativity.... but understanding some basics helps.

## Very common scenario - dealing with samples below a limit of detection

### Aproach I - change the <LODs for zeros

One aproach that can be followed is to change the samples below the Limit od Detection (LOD) for a zero:


```r
lab_data %>% 
  pivot_longer(cols = c(compound_a, compound_b), 
               names_to = "compound", 
               values_to = "concentration") %>% 
  mutate(concentration = str_replace(concentration, "^<[:graph:]*", "0")) %>% 
  mutate(concentration = as.numeric(concentration))
```

```
## # A tibble: 200 x 5
##    sample_id lab_id                    run              compound   concentration
##    <chr>     <chr>                     <chr>            <chr>              <dbl>
##  1 0001      External_sample_code_0001 Run_1-20/03/2019 compound_a           0  
##  2 0001      External_sample_code_0001 Run_1-20/03/2019 compound_b          61.0
##  3 0002      External_sample_code_0002 Run_1-20/03/2019 compound_a          53.9
##  4 0002      External_sample_code_0002 Run_1-20/03/2019 compound_b          52.2
##  5 0003      External_sample_code_0003 Run_1-20/03/2019 compound_a          18.1
##  6 0003      External_sample_code_0003 Run_1-20/03/2019 compound_b          46.9
##  7 0004      External_sample_code_0004 Run_1-20/03/2019 compound_a          40.8
##  8 0004      External_sample_code_0004 Run_1-20/03/2019 compound_b          84.4
##  9 0005      External_sample_code_0005 Run_1-20/03/2019 compound_a          27.9
## 10 0005      External_sample_code_0005 Run_1-20/03/2019 compound_b           0  
## # … with 190 more rows
```

`str_replace()` is quite handy for this, it looks for whatever pattern you tell it, and changes it for whatever you say.

in detail:

- The `^<` is asking to find a section of the string that **starts** with *"<"*. We use *"starts with"* insetad of *"is preceded by"* because we are replacing the string, so we need to get rid of the "<" as well. With *"starts with"* that start is included in the string.
- The `[:graph:]` part is asking for any character (numbers, letters, symbols). We need to be more general, because we want to include the decimal period
- The `*` is saying that we want to get back zero or more elements

Because there were "<" in the original data, the column was loaded as text, so the last step is to turn it into a numeric variable.


### Aproach II - Change <LODs to LOD/2

Another common substitution approach is to change the samples below the LOD for a value of 1/2 the LOD. This approach assumes that all those samples would have their own normal distribution with a min of 0 and a max of the LOD, so the mean should be LOD/2.

The ideal case scenario would be for you to have a separate table of LODs. So you could join this with your results table and have a complete LOD column that we can use to make our calculations. Most times, this is not the case, so the most convenient approach would be to extract the info contained in those "<XX" samples to create an LOD column, which then we will use to mutate the concentration column with a LOD/2 value


```r
lab_data %>% 
  pivot_longer(cols = c(compound_a, compound_b), 
               names_to = "compound", 
               values_to = "concentration") %>% 
  mutate(lod = str_extract(concentration, "(?<=<)[:graph:]*")) %>%    # extract the LOD value sinto their own column
  mutate(lod = as.numeric(lod)) %>%  # we need to calculate the LOD/2, so we need it to be a number
  mutate(concentration = str_replace(concentration, "^<[:graph:]*", as.character(lod/2))) %>%  # same as before but now we replace with LOD/2. Additional "problem", because here we are working with strings, if we try to give it a number, it doesnt like it, so we need to soround that LOD/2 by that "as.character()"
  mutate(concentration = as.numeric(concentration)) # Now it can all be converted to numbers again!
```

```
## # A tibble: 200 x 6
##    sample_id lab_id                 run            compound  concentration   lod
##    <chr>     <chr>                  <chr>          <chr>             <dbl> <dbl>
##  1 0001      External_sample_code_… Run_1-20/03/2… compound…           5    10  
##  2 0001      External_sample_code_… Run_1-20/03/2… compound…          61.0  NA  
##  3 0002      External_sample_code_… Run_1-20/03/2… compound…          53.9  NA  
##  4 0002      External_sample_code_… Run_1-20/03/2… compound…          52.2  NA  
##  5 0003      External_sample_code_… Run_1-20/03/2… compound…          18.1  NA  
##  6 0003      External_sample_code_… Run_1-20/03/2… compound…          46.9  NA  
##  7 0004      External_sample_code_… Run_1-20/03/2… compound…          40.8  NA  
##  8 0004      External_sample_code_… Run_1-20/03/2… compound…          84.4  NA  
##  9 0005      External_sample_code_… Run_1-20/03/2… compound…          27.9  NA  
## 10 0005      External_sample_code_… Run_1-20/03/2… compound…          10.2  20.5
## # … with 190 more rows
```


For the step of creating a new `lod` variable:

- The `(?<=<)` is asking to find a section of the string that **is preceded by** *<"*
- The `[:graph:]` part is asking for any character (numbers, letters, symbols). We need to be more general, because we want to include the decimal period
- The `*` is saying that we want to get back zero or more elements


For the step of changing the concentration values to LOD/2 fo rthe no-detects:

- The `^<` is asking to find a section of the string that **starts** with *"<"*. We use *"starts with"* insetad of *"is preceded by"* because we are replacing the string, so we need to get rid of the "<" as well. With *"starts with"* that start is included in the string.
- The `[:graph:]` part is asking for any character (numbers, letters, symbols). We need to be more general, because we want to include the decimal period
- The `*` is saying that we want to get back zero or more elements

**NOTE**: There are many other ways of dealing with no detects whcich dont involve arbitrary substitution, but this is not a stats class. I do highly recommend exploring statistical approaches able to handle censored data. For a neat application see this [paper](https://www.sciencedirect.com/science/article/abs/pii/S0048969717320648) (by yours truly, of course!)


## Another useful example - Formating after `pivot_longer()`

For very good reasons, column names nee dto adhere to the [Tydiverse Style Guide](https://style.tidyverse.org/) (i.e. no spaces, all lower case, etc). However, that means that every time we use `pivor_longer()` we end up with very *unfriendly* values for our paremeters, compounds, etc. Now that they are not column names and that they will most likely be used in figures or tables, we can format these to look *nicer*.


```r
lab_data %>% 
  pivot_longer(cols = c(compound_a, compound_b), 
               names_to = "compound", 
               values_to = "concentration") %>% 
  mutate(compound = str_replace(compound, "_", " ")) %>%  # We replace the underscore for a space
  mutate(compound = str_to_title(compound)) # We apply a title format (capitalize each word)
```

```
## # A tibble: 200 x 5
##    sample_id lab_id                    run              compound   concentration
##    <chr>     <chr>                     <chr>            <chr>      <chr>        
##  1 0001      External_sample_code_0001 Run_1-20/03/2019 Compound A <10.0        
##  2 0001      External_sample_code_0001 Run_1-20/03/2019 Compound B 61.036       
##  3 0002      External_sample_code_0002 Run_1-20/03/2019 Compound A 53.932       
##  4 0002      External_sample_code_0002 Run_1-20/03/2019 Compound B 52.153       
##  5 0003      External_sample_code_0003 Run_1-20/03/2019 Compound A 18.131       
##  6 0003      External_sample_code_0003 Run_1-20/03/2019 Compound B 46.935       
##  7 0004      External_sample_code_0004 Run_1-20/03/2019 Compound A 40.785       
##  8 0004      External_sample_code_0004 Run_1-20/03/2019 Compound B 84.442       
##  9 0005      External_sample_code_0005 Run_1-20/03/2019 Compound A 27.876       
## 10 0005      External_sample_code_0005 Run_1-20/03/2019 Compound B <20.5        
## # … with 190 more rows
```


## Conditional replacing with `case_when()` - Not speciffic to strings

This is a bit of a preview of a future class, but it is handy here. Imagine you want to change the names of the compounds. You want to specify that "Compound A" is actually "Naphthalene" and that "Compound B" is actually "Benzene". There are many ways of doing this, but one of the simplest and quickest is the `case_when()` function.

Let's continue from the code of the previous step:


```r
lab_data %>% 
  pivot_longer(cols = c(compound_a, compound_b), 
               names_to = "compound", 
               values_to = "concentration") %>% 
  mutate(compound = str_replace(compound, "_", " ")) %>%  # We replace the underscore for a space
  mutate(compound = str_to_title(compound)) %>%  # We apply a title format (capitalize each word)
  mutate(compound = case_when(
    compound == "Compound A" ~ "Naphthalene",
    compound == "Compound B" ~ "Benzene"
  ))
```

```
## # A tibble: 200 x 5
##    sample_id lab_id                    run              compound   concentration
##    <chr>     <chr>                     <chr>            <chr>      <chr>        
##  1 0001      External_sample_code_0001 Run_1-20/03/2019 Naphthale… <10.0        
##  2 0001      External_sample_code_0001 Run_1-20/03/2019 Benzene    61.036       
##  3 0002      External_sample_code_0002 Run_1-20/03/2019 Naphthale… 53.932       
##  4 0002      External_sample_code_0002 Run_1-20/03/2019 Benzene    52.153       
##  5 0003      External_sample_code_0003 Run_1-20/03/2019 Naphthale… 18.131       
##  6 0003      External_sample_code_0003 Run_1-20/03/2019 Benzene    46.935       
##  7 0004      External_sample_code_0004 Run_1-20/03/2019 Naphthale… 40.785       
##  8 0004      External_sample_code_0004 Run_1-20/03/2019 Benzene    84.442       
##  9 0005      External_sample_code_0005 Run_1-20/03/2019 Naphthale… 27.876       
## 10 0005      External_sample_code_0005 Run_1-20/03/2019 Benzene    <20.5        
## # … with 190 more rows
```

