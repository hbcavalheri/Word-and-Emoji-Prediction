library(shiny)
library(shinythemes)
library(shinyjs)

 shinyUI(fluidPage(theme = shinytheme("superhero"),
     titlePanel("Word and Emoji Prediction"),
     shinyjs::useShinyjs(),
     navbarPage("Data Science Project",
                tabPanel("Prediction",
                         p("1. Write in the text input box below;",
                           align = "center"),
                         p("2. Type space after the last word to get the predictions;",
                           align = "center"),
                         p("3. Click on the prediction output to complete your text;",
                           align = "center"),
                         p("4. If you click on an emoji the sentence will appear in the bottom and text input will be erased.",
                           align = "center"),
                         
                         tags$div(align = "center", 
                                  textInput("text", label = h3("Text input"), 
                                            value = ""), width = '100%'),
                                  fluidRow(column(1, offset = 3, uiOutput("word1")),
                                           column(1, offset = 1, uiOutput("word2")),
                                           column(1, offset = 1, uiOutput("word3"))),
                                  fluidRow(column(2, offset = 4, uiOutput("emoji1")),
                                           column(2, uiOutput("emoji2"))),
                                  fluidRow(column(4, offset = 1, textOutput("emojitext")))
                                ), 
                tabPanel("About",
                         h4("Word Prediction"),
                         p("This application is the capstone project of the Data Science
                           specialization from Coursera in cooperation with SwiftKey."),
                         p("The main goal of this application is to predict the next word based on 
                           user's input. In order to build the prediction application three data sets were provided.
                           The data sets were compiled from blogs, twitter and news from Internet."),
                         p("When combined together, the datasets require a lot of computational
                           power to be used and it would not be feasible for our application. 
                           Then, I randomly selected 10000 lines from each dataset."),
                         p("With the new dataset I created different csv files containing different
                           n-grams (see function 'grams' on Github). N-grams are a sequence of n words."),
                         p("The prediction was performed by using Markov chain, which assumes that the
                           probability of the next word depends on the previous words. In this app you find
                           the code for the Markov chain in the functions: 'pred3' and 'predword' on Github."),
                         tags$br(),
                         h4('Emoji Prediction'),
                         p("In addition to predict words I included emoji prediction. First,
                           I used the data from [1] to get the occurence of each emoji on twitter.
                           Next, I got the emoji dataset from the R package 'emo', which contains a larger variety of emojis."),
                         p("With these two datasets combined I built the function 'emoj' (Github) to 
                           predict the emoji that would be associated to the last word provided by the user."),
                         tags$br(),
                         a('http://kt.ijs.si/data/Emoji_sentiment_ranking/about.html'),
                         p("[1] P. Kralj Novak, J. Smailovic, B. Sluban, I. Mozetic,
                            Sentiment of Emojis, PLoS ONE 10(12): e0144296, doi:10.1371/journal.pone.0144296, 2015."),
                         tags$br(),
                         a("https://github.com/hbcavalheri/Word-and-Emoji-Prediction/tree/master"),
                         p("Application built by Hamanda Badona Cavalheri")
                         
                )
                
     )
     )
 )
