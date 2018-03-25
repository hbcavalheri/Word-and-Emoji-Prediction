# raw data from Internet

us.blog <- readLines('en_US.blogs.txt')
us.news <- readLines('en_US.news.txt')
us.twi <- readLines('en_US.twitter.txt')

us.blog1 <- sample(us.blog, 8000)
us.news1 <- sample(us.news, 8000)
us.twi1 <- sample(us.twi, 8000)

us.words <- c(us.blog1, us.news1, us.twi1)
length(us.words)

# n-grams fuction

grams <- function(n){
    us.blog.test <- us.words %>%
        data_frame(line = 1:length(.)) %>% 
        `colnames<-` (c("text", "line")) %>% 
        unnest_tokens(gram, text, token = 'ngrams', n = n) %>% 
        count(gram, sort = TRUE) %>% 
        separate(gram, paste('word', 1:n, sep = ""), sep = " ") %>% 
        mutate_at(vars(-n), funs(tolower(.)))
    return(us.blog.test)
}

# saving n-grams datasets

us.word1 <- write.csv(grams(1), "us.word1.csv", row.names = FALSE)
us.word2 <- write.csv(grams(2), "us.word2.csv", row.names = FALSE)
us.word3 <- write.csv(grams(3), "us.word3.csv", row.names = FALSE)
us.word4 <- write.csv(grams(4), "us.word4.csv", row.names = FALSE)

# emoji data cointaning occurences

url <- "http://kt.ijs.si/data/Emoji_sentiment_ranking/index.html"
emojis_raw <- url %>%
    read_html() %>%
    html_table() %>%
    data.frame %>%
    select(-Image.twemoji., -Sentiment.bar.c.i..95..)
names(emojis_raw) <- c("char", "unicode", "occurrences", "position", "negative", "neutral", 
                       "positive", "sentiment_score", "description", "block")
emojis.sent <- emojis_raw %>%
    mutate(unicode = as.u_char(unicode)) %>%
    mutate(description = tolower(description)) 
head(emojis.sent)
emojis.sent$unicode <- as.character(emojis.sent$unicode)

write.csv(emojis.sent, "emojis_sent.csv")

# emoji data

emojis.sent <- read.csv("emojis_sent.csv", sep = ",", as.is = TRUE)
emojis1 <- emo::jis %>% 
    select(runes, emoji, name, group, subgroup, keywords) %>% 
    mutate(unicode = paste("U+", runes, sep = ""))
emojis_merged <- emojis1 %>%
    inner_join(emojis.sent, by = "unicode") %>% 
    select(-runes, -char, -description, -block)

# getting emojis description

keywd2 <- emojis_merged %>% 
    dplyr::group_by(unicode) %>% 
    dplyr::do(., data.frame(matrix(unlist(.$keywords), nrow=1))) %>% 
    as.data.frame() %>% 
    gather(unicode1, word, -unicode) %>% 
    select(-unicode1) %>% 
    anti_join(stop_words)
keywd1 <- emojis_merged %>% 
    select(unicode, name) %>% 
    mutate(word = name) %>% 
    select(unicode, word) %>% 
    dplyr::group_by(unicode) %>% 
    dplyr::do(., data.frame(matrix(unlist(strsplit(.$word, " ")), nrow=1))) %>% 
    as.tibble() %>%
    gather(unicode1, word, -unicode) %>% 
    select(-unicode1) %>% 
    anti_join(stop_words)
keywd <- bind_rows(keywd1, keywd2) %>% 
    filter(!is.na(word)) 
head(keywd)

write.csv(keywd, "keywd.csv")