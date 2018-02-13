library(shiny)
library(readr)
library(shinydashboard)
library(leaflet)
library(magrittr)
library(ggplot2)
library(ggmap)
library(UScensus2000cdp)
kc = read_csv("kc_house_data.csv")
kc$yr_renovated = ifelse(kc$yr_renovated > 0, 1, 0)
kc$yr_renovated = as.factor(kc$yr_renovated)

#convert the built year to be years
kc$years = 2017 - kc$yr_built

#delete the id, date and zipcode column
kc = kc[, -c(1:2, 13, 17)]
kc = kc[, -12]

#check the box plot of sqrt_living vs sqrt_living15, sqrt_lot and sqrt_lot15
boxplot(kc[, c(4, 15)])
boxplot(kc[, c(5, 16)])

#delete the sqrt_living and sqrt_lot
kc = kc[, -c(4:5)]

body <- dashboardBody(
    fluidRow(
        tabBox(
            title = "House Sales in King County, USA",
            # The id lets us use input$tabset1 on the server to find the current tab
            id = "tabset1", height = 495, width = 800,
            tabPanel("Map", box(width = 495,
                                # App title ----
                                titlePanel("Filters"),
                                
                                # Sidebar layout with input and output definitions ----
                                sidebarLayout(
                                    
                                    # Sidebar to demonstrate various slider options ----
                                    sidebarPanel(
                                        # Input: Simple integer interval ----
                                        sliderInput("Bedrooms", "Number of bedrooms:", min = 0, max = 10, value = c(1,2)),
                                        
                                        # Input: Decimal interval with step value ----
                                        sliderInput("Bathrooms", "Number of bathrooms:", min = 0, max = 8, value = c(1,2), step = 0.25),
                                        sliderInput("Floors", "Number of floors:", min = 1, max = 3.5, value = c(1,2), step = 0.5),
                                        sliderInput("Sqft_living", "Squarefeet of livingroom in 2015:", min = 600, max = 6200, value = c(600,1500), step = 100),
                                        sliderInput("Waterfront", "Whether has a view to a waterfront:",min=0,max=1,value = 0),
                                        
                                        # Input: Specification of range within an interval ----
                                        sliderInput("Years", "Years of house since built:", min = 1, max = 120, value = c(1,30)),
                                        sliderInput("Prices", "Price:", min = 78000, max = 6885000, value = c(80000, 2000000))
                                        
                                    ),
                                    
                                    # Main panel for displaying outputs ----
                                    mainPanel(
                                        leafletOutput("mymap")
                                    )
                                )                           
            )),
            tabPanel("ScatterPlot", box(width = 495,
                                        ###
                                        # App title ----
                                        titlePanel("Filters"),
                                        
                                        # Sidebar layout with input and output definitions ----
                                        sidebarLayout(
                                            
                                            # Sidebar to demonstrate various slider options ----
                                            sidebarPanel(
                                                
                                                selectInput('xcol', 'X Variable', names(kc)),
                                                selectInput('ycol', 'Y Variable', names(kc),

                                                            selected = names(kc)[[2]]),
                                                # Input: Simple integer interval ----
                                                sliderInput("Bedrooms1", "Number of bedrooms:", min = 0, max = 10, value = c(1,2)),
                                                
                                                # Input: Decimal interval with step value ----
                                                sliderInput("Bathrooms1", "Number of bathrooms:", min = 0, max = 8, value = c(1,2), step = 0.25),
                                                sliderInput("Floors1", "Number of floors:", min = 1, max = 3.5, value = c(1,2), step = 0.5),
                                                sliderInput("Sqft_living1", "Squarefeet of livingroom in 2015:", min = 600, max = 6200, value = c(600,1500), step = 100),
                                                
                                                # Input: Specification of range within an interval ----
                                                sliderInput("Years1", "Years of house since built:", min = 1, max = 120, value = c(1,30)),
                                                sliderInput("Prices1", "Price:", min = 78000, max = 6885000, value = c(80000, 2000000))
                                                
                                                
                                            ),
                                            
                                            # Main panel for displaying outputs ----
                                            mainPanel(
                                                
                                                # Output: Table summarizing the data selected ----
                                                
                                                plotOutput('plot1'),
                                                DT::dataTableOutput("table")
                                                
                                            )
                                        )
                                        ###
            )
            ),
            tabPanel("Finding 2", box(width = 495,
                                      ###
                                      # App title ----
                                      titlePanel("Filters"),
                                      
                                      # Sidebar layout with input and output definitions ----
                                      sidebarLayout(
                                          
                                          # Sidebar to demonstrate various slider options ----
                                          sidebarPanel(
                                              
                                              # Input: Simple integer interval ----
                                              sliderInput("Interaction", "Whether has a view to a waterfront:",min=0,max=1,value = 0,step = 1)),
                                          # Main panel for displaying outputs ----
                                          mainPanel(
                                              # Output: Table summarizing the data selected ----
                                              plotOutput('interactionplot'),
                                              "Having a view to a waterfront increases the effect of living room area on house price."
                                          )
                                          
                                      )
                                      ###
            )
            ),
            tabPanel("Finding 3", box(
                                      plotOutput('expensivehousemap'),
                                      textInput("string",label="",value = "Expensive houses are more likely to be located in the northern part of Seattle city or by the sea.", width = "100%")
            )
            )
            
        )
    )
)
ui = dashboardPage(
    dashboardHeader(title = "User Interface"),
    dashboardSidebar(),
    body
)
server = function(input, output) {
    
    # The currently selected tab from the first box
    output$tabset1Selected <- renderText({
        input$tabset1
    })
    mapData <- reactive({
        data <- kc
        data <- data[data$bedrooms >= input$Bedrooms[1],]
        data <- data[data$bedrooms <= input$Bedrooms[2],]
        data <- data[data$bathrooms >= input$Bathrooms[1],]
        data <- data[data$bathrooms <= input$Bathrooms[2],]
        data <- data[data$floors >= input$Floors[1],]
        data <- data[data$floors <= input$Floors[2],]
        data <- data[data$sqft_living15 >= input$Sqft_living[1],]
        data <- data[data$sqft_living15 <= input$Sqft_living[2],]
        data <- data[data$waterfront == input$Waterfront,]
        data <- data[data$years >= input$Years[1],]
        data <- data[data$years <= input$Years[2],]
        data <- data[data$price >= input$Prices[1],]
        data <- data[data$price <= input$Prices[2],]
        data[, c(1, 11, 12)]
    })
    
    output$mymap <- renderLeaflet({
        map=leaflet() %>% addTiles() %>% addMarkers(lng=mapData()$long, lat=mapData()$lat, popup=as.character(mapData()$price))
        map  
    })
    ###
    # Filter data based on selections
    output$table <- DT::renderDataTable(DT::datatable({
        data <- kc
        data <- data[data$bedrooms >= input$Bedrooms1[1],]
        data <- data[data$bedrooms <= input$Bedrooms1[2],]
        data <- data[data$bathrooms >= input$Bathrooms1[1],]
        data <- data[data$bathrooms <= input$Bathrooms1[2],]
        data <- data[data$floors >= input$Floors1[1],]
        data <- data[data$floors <= input$Floors1[2],]
        data <- data[data$sqft_living15 >= input$Sqft_living1[1],]
        data <- data[data$sqft_living15 <= input$Sqft_living1[2],]
        data <- data[data$years >= input$Years1[1],]
        data <- data[data$years <= input$Years1[2],]
        data <- data[data$price >= input$Prices1[1],]
        data <- data[data$price <= input$Prices1[2],]
        data
    }))
    
    # Combine the selected variables into a new data frame
    selectedData <- reactive({
        data <- kc
        data <- data[data$bedrooms >= input$Bedrooms1[1],]
        data <- data[data$bedrooms <= input$Bedrooms1[2],]
        data <- data[data$bathrooms >= input$Bathrooms1[1],]
        data <- data[data$bathrooms <= input$Bathrooms1[2],]
        data <- data[data$floors >= input$Floors1[1],]
        data <- data[data$floors <= input$Floors1[2],]
        data <- data[data$sqft_living15 >= input$Sqft_living1[1],]
        data <- data[data$sqft_living15 <= input$Sqft_living1[2],]
        data <- data[data$years >= input$Years1[1],]
        data <- data[data$years <= input$Years1[2],]
        data <- data[data$price >= input$Prices1[1],]
        data <- data[data$price <= input$Prices1[2],]
        data[, c(input$xcol, input$ycol)]
    })
    
    output$plot1 <- renderPlot({
        g <- ggplot(selectedData(), aes(x = selectedData()[, 1], y = selectedData()[, 2])) + geom_point(col = "dodgerblue") 
        print(g)
    })
    ###
    interactionData <- reactive({
        data <- kc
        data <- data[data$waterfront == input$Interaction,]
        data[, c(1, 13)]
    })
    
    output$interactionplot <- renderPlot({
        plot(interactionData()$sqft_living15,
             interactionData()$price/1000,pch = 10, cex = 1, col = "dodgerblue",
             xlab = "Living Room Area (Square Feet)", 
             ylab = "Price (Thousands)",
             xlim = c(0,4000),
             ylim = c(0,2000))
        abline(lm(interactionData()$price/1000~interactionData()$sqft_living15))
    })
    
    output$expensivehousemap <- renderPlot({
        data("washington.cdp")
        seamap = subset(washington.cdp, washington.cdp$name == 'Seattle')
        seamap = SpatialPolygons(seamap@polygons, seamap@plotOrder, 
                                 proj4string = CRS(proj4string(seamap)))
        data <- kc
        cos = as.matrix(data[, c(11:12)])
        hse = as.data.frame(data[, -c(11:12)])
        hs.pts = SpatialPointsDataFrame(cos, hse, proj4string = CRS(proj4string(seamap)))
        millions = subset(hs.pts, price > 1000000)
        g <- ggplot(seamap, aes(x = long, y = lat, group = group))
        g <- g + geom_polygon(fill = 'lightblue')
        millions.df <- as.data.frame(millions@coords)
        g <- g + geom_point(data = millions.df, aes(x = long, y = lat), col = "dodgerblue", inherit.aes = FALSE)
        g + coord_map() + ggtitle('Seattle Homes Over $1M') + xlim(-122.45, -122.22) + ylim(47.48, 47.74)
    })
    
}
shinyApp(ui,server)
