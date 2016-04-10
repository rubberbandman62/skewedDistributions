library(shiny)

shinyUI(fluidPage(
  
   # Application title
   titlePanel("Normal Distributions"),
   
   column(12, 
          helpText("This page lets you vary the shape of a skewed normal distribution.",
                   "The case of a standard normal distribution is also included when skewness and location are 0 and scale is 1.",
                   "You can play around with the parameters and see the shape of the curve change.",
                   "At any time you can return to the standard normal case by pressing reset.")
   ),
  
   sidebarLayout(
      sidebarPanel(
         # This function creates a HTML DIV block which is initially replaced with the
         # actual input controls by the server function.
         # After pressing the reset button below, the input controls are reset to
         # their initial values (actually the are completely replaced).
         uiOutput("input_controls"),
         hr(),
         actionButton("resetButton", "Reset")
      ),
       
      mainPanel(
         plotOutput("normPlot"),
         textOutput("mean"),
         textOutput("median")
      )
   )
))
