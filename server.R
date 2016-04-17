library(shiny)
library(sn)

step = 0.01
x = seq(-20, 20, by=0.01)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
   shape = reactive(input$shape)
   location = reactive(input$location)
   scale = reactive(input$scale)
   
   sdensity = function(x) {
      dsn(x, xi=location(), omega=scale(), alpha=shape())
   }
   
   svariance = function() {
      delta <- shape() / sqrt(1 + shape()^2)
      scale()^2 * (1 - 2*delta^2/pi)
   }
   
   sampleVariance = function() {
      round(sum((x - xmean())^2*sdensity(x)*step), 3)
   }
   
   squantile = function(p) {
      qsn(p, xi=location(), omega=scale(), alpha=shape())
   }
   
   xmean = reactive({
      delta <- shape() / sqrt(1 + shape()^2)
      location() + scale()*sqrt(2/pi)*delta
   })
   
   sampleMean = reactive({
      round(sum(x*sdensity(x))/sum(sdensity(x)), 3)
   })
   
   output$normPlot <- renderPlot({
      if (!is.numeric(shape())) return()
      
      y = sdensity(x)
      plot(x, y, type = "l", xlab="x", ylab="y", lwd=2, col="green", xlim=c(-6, 6))
      title(main = "Distribution")
      ps = c(.025, .16, .84, .9975)
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
      if (!is.numeric(shape())) return()
      sprintf("Mean: %.3f", xmean())
   })
   
   output$median <- renderText({
      if (!is.numeric(shape())) return()
      sprintf("Median: %.3f", squantile(.5))
   })
   
   output$variance <- renderText({
      if (!is.numeric(shape())) return()
      sprintf("Variance: %.3f", svariance())
   })
   
   output$input_controls = renderUI({
      input$resetButton
      div(id="actual_input_controls",
          sliderInput( "shape", "Shape: ", min = -10, max = 10, value = 0, step = 1),
          sliderInput( "location", "Location: ", min = -3, max = 3, value = 0, step = 0.5),
          numericInput("scale", "Scale: ", 1, min = 0.5, max = 3, step = 0.5))
   })
})
