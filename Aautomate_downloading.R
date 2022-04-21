

# To automate the downloading, you would need to create an infinite while loop 
# that has the next structure:
  
# Code a function to retrieve your data
FUNCTION_TO_RETRIEVE_FB_DATA<-function(REGION){
  "Your functions"
  }

# Initialize a variable to count the files you have been saving:
COUNT=0

# Then pass the function into an infinite loop
while (1) { # This means that code will run forever, unless it reaches an 
            # error (check below)
  
  # Initialize the DataFrame where you will save your data
  DF=data.frame() 
  
  for(ER in REGION){ # Run it through your regions
    # The function “try” will try to run your function, if it reaches an error 
    # it will return “try-error”
    message<-try(DF<- FUNCTION_TO_RETRIEVE_FB_DATA(ER),silent = TRUE)
    # If there is an error, then wait. Normally the errors are because you reach
    # a limit at the API
    while(class(message)=="try-error"){ 
      Sys.sleep(1800) # Wait 1800 seconds an try again 
      message<-try(DF<- FUNCTION_TO_RETRIEVE_FB_DATA(ER),silent = TRUE)
    }
    # Now that you have retrieved the data from a region
    # you can save it in a csv file. Always save the data, otherwise you will 
    # lose it when the servers are down.
    If (dim(DF)[1]==0 ){ # If it is a new dataframe then you initialize a new csv
      write.table(DF,paste0(DIR_SAVE,"Name_file_",COUNT,".csv"),sep=",",
                  row.names = FALSE) 
    }else{ # If it is not new, then you just append the info into the previous csv
      write.csv(DF, paste0(DIR_SAVE,"Name_file_",COUNT,'.csv'), append = TRUE,
                row.names = FALSE,col.names = FALSE)
    }
  }
  COUNT=COUNT+1
}

#  For any question related with R, I would recommend you use https://stackoverflow.com/ .

