require(shinydashboard)
require(shinyAce)
require(leaflet)

shinyUI(
  dashboardPage(
    
    
    # 1.- HEADER OF THE APP
    dashboardHeader(
      title=list(HTML('<img src="icon.png" width="10%" height="90%"/>'), "DOCDOC - Take charge!"),
      titleWidth = 400,
      
      dropdownMenu(type="notifications",
                  messageItem(
                     from =  tags$a(href = "http://rpubs.com/stephanesantos/118699","Documentation"),
                     message = "Customer oriented",
                     icon= icon("user"),
                     time = "2015-19-10"
                   ),
                   messageItem(
                     from = "Documentation",
                     message = "Technical",
                     icon = icon("coffee"),
                     time = "2015-16-10"
                   )
      )
    ),
      
    
    # 2.- SIDEBAR MENU
    dashboardSidebar(
      width = 250,
      sidebarMenu(
        menuItem("Search", tabName = "search", icon = icon("search")),
        menuItem("Share your feedback", icon = icon("thumbs-up"),
                HTML('<div style="text-align:center"><a href="mailto:stephane_santos@hotmail.com?subject=[ShyniApp-DOCDOC]%20-%20Feedback%20and%20suggestions">Mailto:</a></div>')),
        menuItem("About me", icon = icon("user"),list(
                HTML('<div style="text-align:center"><a href="http://www.linkedin.com/in/stephanesant">LinkedIn</a></div>'),
                br(),
                HTML('<div style="text-align:center"><a href="https://twitter.com/stephane27517">Twitter</a></div>')
                )),
        menuItem("Documentation", icon = icon("info"),
                 HTML('<div style="text-align:center"><a href="http://rpubs.com/stephanesantos/118699">UserDoc@Rpubs</a></div>'),
                 br(),
                 HTML('<div style="text-align:center"><a href="">Code@GitHub</a></div>')
                 ),
        menuItem("Contribute", icon = icon("dollar"),list(
                HTML('<div style="text-align:center"><a href="https://www.paypal.com/us/cgi-bin/webscr?cmd=_flow&SESSION=vZsfbOtbszlmS26JeQQjV5ydxkJAcIntWzJjjfPEIfCmPqxmZHwDMXe5Fqy&dispatch=5885d80a13c0db1f8e263663d3faee8d64ad11bbf4d2a5a1a0d303a50933f9b2">Paypal</a></div>')
                ))
      )),
    
    
    # 3.- BODY OF THE APP
    dashboardBody(

      tags$style(HTML('
      .content-wrapper,
      .right-side {
          background-color: #000000;  /#367fa9;
        }
    ')),
      
      
      
      # 3.1 Pages called by sidebar menu
      tabItems(
#======================================================================           
# 3.1.0 Search
#======================================================================   
        tabItem(tabName = "search",
                # 3.1.0.1 Search - Pathology selection
                fluidRow(
                  box(
                    title = "Step 1 - Enter a ZIP Code", width = NULL, solidHeader = TRUE, status = "warning",background="black",
                    tags$h4(textOutput("MyZIP")),
                    tags$style(type="text/css", "#MyZIP { vertical-align: middle;height: 20px; width: 100%; text-align:center; font-size: 20px; display: block;}"),
                    tags$h4(textInput("NewZIP","",value="Enter your 5-digit ZIP code here")),
                    tags$style(type="text/css", "#title { vertical-align: middle;height: 20px; width: 50%; text-align:center; font-size: 20px; display: block;}"),
                    actionButton(inputId="Recalc",label = "Update",icon = icon("repeat")),
                    tags$style(type='text/css', "#Recalc { vertical-align: middle; height: 50px; width: 50%; text-align:center;font-size: 20px;color:white;background-color:gray;display: inline-block;}")
                    
                  ), # end box
                  box(
                    title = "Step 2 - Select a Medical Procedure", width = NULL, solidHeader = TRUE, status = "warning", background="black",
                    selectizeInput('MedicalProcedure', label = "", 
                                   choices=NULL, multiple = F,
                                   options = list(placeholder = paste0("Select from available procedures in your vicinity")),
                                   width="100%")
                  ) # end box
                ), # end fluidRow
                fluidRow(
                  title = "Step 3 - Click on the search button", width = NULL, solidHeader = TRUE, status = "warning", background="black",
                  actionButton(inputId="button0",label = "Search",icon = icon("search")),
                  tags$style(type='text/css', "#button0 { vertical-align: middle; height: 50px; width: 100%; font-size: 25px;color:white;background-color:gray;display: block;}"),
                  br()
                ), # end fluidRow
                fluidRow(
                  box(
                    title = "Map with providers - scroll down for graphs", width = NULL, solidHeader = TRUE, status = "success",
                    leafletOutput("map",width="100%",height="640px")
                  ), # end box
                  box(
                    title = "Amount charged by the providers to Medicare", width = NULL, solidHeader = TRUE, status = "success",
                    plotOutput("plot1")
                  ), # end box
                  box(
                    title = "Ceiling price from Medicare", width = NULL, solidHeader = TRUE, status = "success",
                    plotOutput("plot2")
                  ) # end box
                ), # end FluidRow
                fluidRow(
                  box(
                  title = "Amount actually paid by Medicare to the provider", width = NULL, solidHeader = TRUE, status = "success",
                  plotOutput("plot3")
                  ) # end box
                ), # end fluidRow
                fluidRow(
                  # Copyright disclaimer    
                  textOutput("text2"),
                  textOutput("text3"),
                  textOutput("text1")
                ) # end fluidRow
        ), # end tabItem search
#======================================================================   
# 3.1.1 Contribute
#======================================================================  
        tabItem(tabName = "contribute",
            fluidRow(
                box(
                  tags$h2(id='title',"I'd like to support this work:"),
                  br(),
                  tags$style(type="text/css", "#title { vertical-align: middle;height: 30px; width: 100%; text-align:center; font-size: 25px; display: block;}"),
                  tags$form(id="paypal",
                      action = "https://www.paypal.com/cgi-bin/webscr",
                      method = "post",
                      tags$input(type="hidden",name="cmd",value="_s-xclick"),
                      tags$input(type="hidden",name="encrypted",value="-----BEGIN PKCS7-----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-----END PKCS7-----
                                       "),
                      tags$input(type="image",src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif",border="0",name="submit",alt="PayPal - The safer, easier way to pay online!"),
                      tags$img(alt="",border="0",src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif",width="1",height="1"),
                      tags$style(type="text/css", "#paypal { vertical-align: middle;text-align:center}"),
                      br(),br()
                  ) # end tags form
                ) # end box
            ) # end fluidRow
       ) # end tabItem Contribute
#======================================================================   
# Placeholder
#======================================================================  
#        tabItem(tabName = "Placeholdern"
#        ) # end tabItem Placeholder      
      ) # end tabItems
    ) # end DashboardBody
  ) # end DashboardPage
) # end ShinyUI
