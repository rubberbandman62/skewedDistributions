library(shiny)
library(sn)

x = seq(-20, 20, by=0.01)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
   skewness = reactive(input$skewness)
   location = reactive(input$location)
   scale = reactive(input$scale)
   
   sdensity = function(x) {
      dsn(x, xi=location(), omega=scale(), alpha=skewness())
   }
   
   squantile = function(p) {
      qsn(p, xi=location(), omega=scale(), alpha=skewness())
   }
   
   xmean = reactive({
      round(sum(x*sdensity(x))/sum(sdensity(x)), 3)
   })
   
   output$normPlot <- renderPlot({
      if (!is.numeric(skewness())) return()
      
      y = sdensity(x)
      plot(x, y, type = "l", xlab="x", ylab="y", lwd=2, col="green", xlim=c(-6, 6))
      title(main = "Distribution")
      ps = c(.025, .16, .84, .975)
      qs = squantile(ps)
      for (q in qs) {
         lines(c(q, q), c(0, sdensity(q)), lty=2, col="blue")
      }
      xmed = squantile(.5)
      ymed = sdensity(xmed)
      lines(c(xmed, xmed), c(0, ymed), lwd=2, lty=2, col="red")
      
      xmean = xmean()
      ymean = sdensity(xmean)
      lines(c(xmean, xmean), c(0, ymean), lwd=1, lty=1, col="black")
      
      legend("topright", 
             c("Mean", "Median", "Other Quantiles"),
             lty=c(1,2,2), 
             lwd=c(1, 2, 1),
             col=c("black", "red", "blue"))    
      })
   
   output$mean <- renderText({
      if (!is.numeric(skewness())) return()
      sprintf("Mean: %.3f", xmean(), squantile(.5))
   })
   
   output$median <- renderText({
      if (!is.numeric(skewness())) return()
      sprintf("Median: %.3f", squantile(.5))
   })
   
   output$input_controls = renderUI({
      input$resetButton
      div(id="actual_input_controls",
          sliderInput( "skewness", "Skewness: ", min = -10, max = 10, value = 0, step = 1),
          sliderInput( "location", "Location: ", min = -3, max = 3, value = 0, step = 0.5),
          numericInput("scale", "Scale: ", 1, min = 0.5, max = 3, step = 0.5))
   })
})
