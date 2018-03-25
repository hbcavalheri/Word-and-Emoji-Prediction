library(shiny)
library(shinyjs)
source("code.R")

shinyServer(function(session, input, output) {
    
    predwd <- reactive(predword(input$text))
    
    predemoj <- reactive(emoj(input$text))

    output$word1 <- renderUI({
            actionButton("action1", label = predwd()[1], width = '100px')
        })
    
    observe(shinyjs::toggle("word1", condition = !is.null(predwd()[1])))

    output$word2 <- renderUI({
            actionButton("action2", label = predwd()[2], width = '100px')
          })
    
    observe(shinyjs::toggle("word2", condition = !is.null(predwd()[2])))
    
    output$word3 <- renderUI({
        actionButton("action3", label = predwd()[3], width = '100px')
    })
    
    observe(shinyjs::toggle("word3", condition = !is.null(predwd()[3])))
    
    output$emoji1 <- renderUI({
            actionButton("action4", label = predemoj()[1,], width = '100px') 
    })
    
    observe(shinyjs::toggle("emoji1", condition = !is.null(predemoj()[1,1])))
    
    output$emoji2 <- renderUI({
        actionButton("action5", label = predemoj()[2,], width = '100px')
    }) 
    
    observe(shinyjs::toggle("emoji2", condition = !is.null(predemoj()[2,1])))

    
    observeEvent(input$action1, {
        new.text <- paste(input$text, predwd()[1], "", sep = " ")
        updateTextInput(session = session, "text", value = new.text)
    })
    
    observeEvent(input$action2, {
        new.text <- paste(input$text, predwd()[2], "", sep = " ")
        updateTextInput(session = session, "text", value = new.text)
    })
    
    observeEvent(input$action3, {
        new.text <- paste(input$text, predwd()[3], "", sep = " ")
        updateTextInput(session = session, "text", value = new.text)
    })
    
    observeEvent(input$action4, {
        new.text <- paste(input$text, predemoj()[1,1], "", sep = " ")
        updateTextInput(session = session, "text", value = "")
        output$emojitext <- renderText({ 
            new.text
        })
    })
    
    observeEvent(input$action5, {
        new.text <- paste(input$text, predemoj()[2,1], "", sep = " ")
        updateTextInput(session = session, "text", value = "")
        output$emojitext <- renderText({ 
            new.text
        })
    })
    
    })

