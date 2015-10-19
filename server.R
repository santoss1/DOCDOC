require(leaflet)
require(rjson) 
require(ggplot2)
require(ggmap)
require(RgoogleMaps)
require(plyr)
require(rdrop2)
require(BH)


shinyServer(
  

  function(input, output,session) {
    
    
    #========================================================================================#
    #                                  tabItem Search                                        #
    #========================================================================================#
    
    v <- reactiveValues(doPlot = FALSE)
    
    # Geolocate User IP address   
    IPtoLOC <- function(){
      UserIP<-fromJSON(readLines("http://api.hostip.info/get_json.php", warn=F))$ip
      url <- paste(c("http://www.telize.com/geoip", UserIP), collapse='')
      LOC <- fromJSON(readLines(url, warn=FALSE))
      return(LOC)
    }
    
    # Make user's ZIPCode available to ui.R
    ZIPCode<-IPtoLOC()$postal_code
    output$MyZIP<-renderText({paste0("Your IP shows a ZIP code at: ", ZIPCode)})
    
    # Checks status of Search button 'button0'
    observeEvent(input$button0, {
      # 0 will be coerced to FALSE
      # 1+ will be coerced to TRUE
      v$doPlot <- input$button0
    })
    
    observe({
      if(input$Recalc<1)
        return() #make it NULL initially
      ZIPCode <- isolate(input$NewZIP) #only update x each time the Recalc is pressed
      token <- readRDS("droptoken.rds")
      ZIPFile<-drop_read_csv(as.character(ZIPCode),sep="",dtoken=token)
      updateSelectizeInput(session, 'MedicalProcedure', server = T, 
                           choices=as.character(ZIPFile$hcpcs_description))
      
      output$map<-renderLeaflet({
        # While button0 is not pressed dont return anything
        if (v$doPlot == FALSE) return()
        
        # When button0 is pressed, get the Medical Procedure selected and reduce ZIPFile to the selection
        isolate({
          MedicalProcedure <- reactive({input$MedicalProcedure})
          ZIPFile<-ZIPFile[ZIPFile$hcpcs_description==input$MedicalProcedure,]
          
          # Gets geo coordinates for providers in user ZIP code vicinity
          ProviderLoc<-with(ZIPFile,
                            paste(nppes_provider_street1,nppes_provider_street2,
                                  nppes_provider_city,nppes_provider_state,nppes_provider_city))
          ProviderLoc<-gsub("NA","",ProviderLoc)
          ZIPFile$long<-as.numeric(unlist(geocode(ProviderLoc)[1]))
          ZIPFile$lat<-as.numeric(unlist(geocode(ProviderLoc)[2]))
          
          # Get user geolocalization 
          lon<-geocode(as.character(ZIPCode))$lon
          lat<-geocode(as.character(ZIPCode))$lat
          
          
          # Generate map centered on user ZIPCode
          getMap<-get_googlemap(center=c(lon=lon,lat=lat),source = "google",maptype = "roadmap")
          
          # Use leaflet on dataset to add providers and manage clusters of datapoints
          content <- paste(ZIPFile$nppes_provider_first_name,
                           " ",ZIPFile$nppes_provider_last_org_name,
                           " ", ZIPFile$nppes_provider_street1,
                           " ", ZIPFile$nppes_provider_street2,
                           " ", ZIPFile$nppes_provider_city)
          m=leaflet(ZIPFile[ZIPFile$ZIP==ZIPCode,]) %>% 
            addTiles() %>%
            addMarkers(popup=content,clusterOptions = markerClusterOptions())
          print(m)
        })
      })
      
      
      output$plot1<-renderPlot({
        # While button0 is not pressed dont return anything
        if (v$doPlot == FALSE) return()
        
        isolate({
          MedicalProcedure <- reactive({input$MedicalProcedure})
          ZIPFile<-ZIPFile[ZIPFile$hcpcs_description==input$MedicalProcedure,]
          qplot(y=ZIPFile$nppes_provider_last_org_name,x=ZIPFile$average_submitted_chrg_amt,xlab="USD",ylab="Providers")+ggtitle("Average by provider +/- standard deviation")+geom_errorbarh(aes(x=ZIPFile$average_submitted_chrg_amt, xmin=ZIPFile$average_submitted_chrg_amt-ZIPFile$stdev_submitted_chrg_amt, xmax=ZIPFile$average_submitted_chrg_amt+ZIPFile$stdev_submitted_chrg_amt), width=0.25)
        })
      })
      
      output$plot2<-renderPlot({
        # While button0 is not pressed dont return anything
        if (v$doPlot == FALSE) return()
        
        isolate({ 
          MedicalProcedure <- reactive({input$MedicalProcedure})
          ZIPFile<-ZIPFile[ZIPFile$hcpcs_description==input$MedicalProcedure,]
          qplot(y=ZIPFile$nppes_provider_last_org_name,x=ZIPFile$average_Medicare_allowed_amt,xlab="USD",ylab="Providers")+ggtitle("Average by provider +/- standard deviation")+geom_errorbarh(aes(x=ZIPFile$average_Medicare_allowed_amt, xmin=ZIPFile$average_Medicare_allowed_amt-ZIPFile$stdev_Medicare_allowed_amt, xmax=ZIPFile$average_Medicare_allowed_amt+ZIPFile$stdev_Medicare_allowed_amt), width=0.25)                
        })
      })
      
      output$plot3<-renderPlot({
        # While button0 is not pressed dont return anything
        if (v$doPlot == FALSE) return()
        
        isolate({ 
          MedicalProcedure <- reactive({input$MedicalProcedure})
          ZIPFile<-ZIPFile[ZIPFile$hcpcs_description==input$MedicalProcedure,]
          qplot(y=ZIPFile$nppes_provider_last_org_name,x=ZIPFile$average_Medicare_payment_amt,xlab="USD",ylab="Providers")+ggtitle("Average by provider +/- standard deviation")+geom_errorbarh(aes(x=ZIPFile$average_Medicare_payment_amt, xmin=ZIPFile$average_Medicare_payment_amt-ZIPFile$stdev_Medicare_payment_amt, xmax=ZIPFile$average_Medicare_payment_amt+ZIPFile$stdev_Medicare_payment_amt), width=0.25)                
        })
      })
      })
      
      
      
      #========================================================================================#
      #                                     DISCLAIMERS                                        #
      #========================================================================================#
      
      
      output$text1 <- renderText({'Copyright DOCDOC, 2015.'})
      output$text2 <- renderText({'DISCLAIMER - CPT codes, descriptions and other data only are copyright 1995 - 2014 American Medical Association.  All rights reserved. CPT is a registered trademark of the American Medical Association.'})
      output$text3 <- renderText({'DISCLAIMER - This App is not intended for commercial use. This app was developped in the course of Johns Hopkins University Data Science certificate offered through Coursera.'})

})
