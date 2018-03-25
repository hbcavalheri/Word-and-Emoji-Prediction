library(tidyverse)
library(tidytext)
library(stringr)
library(rvest)
library(Unicode)
library(tm)
library(emo)
library(syuzhet)

# loading n-grams

us1 <- read.csv("us.word1.csv", sep = ",", as.is = TRUE)
us2 <- read.csv("us.word2.csv", sep = ",", as.is = TRUE)
us3 <- read.csv("us.word3.csv", sep = ",", as.is = TRUE)
us4 <- read.csv("us.word4.csv", sep = ",", as.is = TRUE)

# function to predict next word

pred3 <- function(x) {
    if(length(x) == 1) {
        wd <- us2 %>% 
            dplyr::filter(word1 == x[length(x)]) 
        pred <- wd$word2[1:3]
    } else if(length(x) == 2) {
        wd <- us3 %>% 
            dplyr::filter(word1 == x[length(x)-1] & 
                              word2 == x[length(x)]) 
        pred <- wd$word3[1:3]
    } else if (length(x) == 3) {
        wd <- us4 %>% 
            dplyr::filter(word1 == x[length(x)-2] & 
                              word2 == x[length(x)-1] & 
                              word3 == x[length(x)]) 
        pred <- wd$word4[1:3]
    } 
    return(pred)
}

# function to properly read user input

predword <- function(x){
    x <- tolower(x)
    x1 <- str_detect(x, " $")
    x <- str_trim(x, side = "both")
    if(x1 == TRUE) {
        x <- unlist(strsplit(x, " "))
        if(length(x) >= 3) {
            x <- x[(length(x) - 2): length(x)]
        } else if(length(x) == 2 | length(x) == 1) {
            x 
        } else if(length(x) == 0) {
            x <-  NULL
        }
        oi <- pred3(x)
        if(is.na(oi[1])) {
            if(length(x) > 1) {
                while(is.na(oi[1]) & length(x) > 1) {
                    x <- x[-1]
                    oi <- pred3(x) }
                if(is.na(oi[1])) {
                    oi <-  NULL
                } else {
                    oi
                }
                
            } else {
                oi <- NULL
            }
        } else {
            oi
        }
        
    } else {
        oi <- NULL
    }
    return(oi)
    }

# emoji data

emojis.sent <- read.csv("emojis_sent.csv", sep = ",", as.is = TRUE)
emojis1 <- emo::jis %>% 
    select(runes, emoji, name, group, subgroup, keywords) %>% 
    mutate(unicode = paste("U+", runes, sep = ""))
emojis_merged <- emojis1 %>%
    inner_join(emojis.sent, by = "unicode") %>% 
    select(-runes, -char, -description, -block)

# dataset cointaining the keywords for each emoji

keywd <- read.csv("keywd.csv", sep = ",", as.is = TRUE)

# function to predict emoji

emoj <- function(x) {
    x <- unlist(strsplit(x, " "))
    x <- tolower(x)
    x.stop <- x[length(x)] %>% 
        as.tibble() %>% 
        `colnames<-` (c("word")) %>% 
        anti_join(stop_words) %>% 
        mutate(length = str_length(word)) %>% 
        inner_join(keywd, by = "word")
    
    if(nrow(x.stop) == 0) {
        x.stop1 <- x[length(x)] %>% 
            as.tibble() %>% 
            `colnames<-` (c("word")) %>% 
            anti_join(stop_words) %>% 
            mutate(length = str_length(word)) %>% 
            filter(length >= 3) %>% 
            mutate(substring = substr(word, start = 1, stop = 3))
        if(nrow(x.stop1) == 0) {
            mat.sub <- NULL
        } else {
            mat.sub <- str_which(us1$word1, 
                                 paste("^", x.stop1$substring, sep = ""))
            mat.sub <- us1$word1[mat.sub]
        }
        
    } else {
        mat.sub <- x.stop$word
    }
    
    emo.desc <- keywd %>% 
        filter(word %in% mat.sub) %>% 
        inner_join(emojis_merged, by = "unicode") %>% 
        as.tibble() %>% 
        arrange(desc(occurrences)) %>% 
        distinct(emoji)
    if(nrow(emo.desc) == 0) {
        return(NULL)
    } else if(nrow(emo.desc) == 1) {
        return(emo.desc[1,1])
    } else if (nrow(emo.desc) > 1) {
        return(emo.desc[1:2,1])
    }
}

