# DOCDOC Application

This application was developped in the course of the 9th module of the Coursera Data Products certificate "Data Science" offered by Johns Hopkins University. It aims at displaying on a map healthcare providers for a selected procedure and given a ZIP Code. It also provides some price related data. 

All data comes from the Center from Medicaire and Medicaid Services (CMS) and pertains to the year 2013 only. Data is not completely tidied up yet. Moreover there are 20000+ ZIP Codes available. The total size of  available is 20000+ so you can try this app with selected ZIP Codes like 27517 or 20147.

Because of the size of the dataset (3GB) I am using a dropbox to store the data and shinyapps.io to store the front end (ui.R) and server calculations (server.R). This may slowdown the user interaction. Everytime you update a ZIP code you may experience a time-lagg of a couple seconds before the available procedures for that ZIP code appear.

The app works best with the Chrome browser. Experiments with Safari showed lower performance. We also experimented with a tablet as a browser and the markers did not display on the screen. 



