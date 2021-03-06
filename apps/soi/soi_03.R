library(shiny)
library(ggplot2)
library(lubridate)
library(dplyr)
load("soi.Rdata")

soi <- soi %>%
  mutate(
    date = ymd(paste0(date, "01")),
    year = year(date),
    month = month(date),
    date_for_plot = year + (month / 12)
  )

# Define UI for application that plots features of movies ---------------------
ui <- fluidPage(
  fluidRow(
    plotOutput("plot", 
               click = clickOpts(id = "plot_click"),
               brush = brushOpts(id = "plot_brush"),
               dblclick = dblclickOpts(id = "plot_dblclick"),
               hover = hoverOpts("plot_hover")
    )    
  ),
  fluidRow(
    column(width = 3,
           h4("Points near click"),
           verbatimTextOutput("click_info")
    ),
    column(width = 3,
           h4("Brushed points"),
           verbatimTextOutput("brush_info")
    ),
    column(width = 3,
           h4("Double-clicked points"),
           verbatimTextOutput("dblclick_info")
    ),
    column(width = 3,
           h4("Hovered points"),
           verbatimTextOutput("hover_info")
    )
  )
)

# Define server function required to create the scatterplot -------------------
server <- function(input, output) {
  output$plot <- renderPlot({
    ggplot(data = soi, aes(x = date_for_plot, y = value)) +
      geom_point(size = 0.8) +
      geom_line(lwd = 0.3) +
      theme_bw() +
      geom_hline(yintercept = 0, color = "orange", lty = 2) +
      labs(title = "Southern Oscillation Index (SOI)",
           y = "SOI", x = "Date")
  })
  
  observeEvent(input$plot_click,
               output$click_info <- renderPrint({
                 nearPoints(soi, input$plot_click) %>%
                   mutate(month = month(month, label = TRUE)) %>%
                   rename(SOI = value) %>%
                   select(month, year, SOI)
               })
  )
  
  observeEvent(input$plot_brush,
               output$brush_info <- renderPrint({
                 brushedPoints(soi, input$plot_brush) %>%
                   mutate(month = month(month, label = TRUE)) %>%
                   rename(SOI = value) %>%
                   select(month, year, SOI)
               })
  )
  
  observeEvent(input$plot_dblclick,
               output$dblclick_info <- renderPrint({
                 nearPoints(soi, input$plot_dblclick) %>%
                   mutate(month = month(month, label = TRUE)) %>%
                   rename(SOI = value) %>%
                   select(month, year, SOI)
               })
  )
  
  observeEvent(input$plot_hover,
               output$hover_info <- renderPrint({
                 nearPoints(soi, input$plot_hover) %>%
                   mutate(month = month(month, label = TRUE)) %>%
                   rename(SOI = value) %>%
                   select(month, year, SOI)
               })
  )
  
}

# Run the application ---------------------------------------------------------
shinyApp(ui = ui, server = server)
