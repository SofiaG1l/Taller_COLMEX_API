
# Code written by Sofia Gil-Clavel
# Date: April 2022
# Last Update: October 2023

# To automate the downloading, you would need to create an infinite while loop 
# that has the next structure:
  
# Code a function to retrieve your data
# Here I applied it to one of the code examples in:
# https://github.com/SofiaG1l/Taller_COLMEX_API/tree/main/Facebook_API
FUNCTION_TO_RETRIEVE_FB_DATA<-function(C){ # C='"MX"' # Código del País
  Age1=18
  Age2=65
  
  g="1,2" # 1:hombre and 2:mujer, pero si queremos descargar ambos géneros g="1,2"
  
  # Los parámetros que utilizaremos están en formato JSON(https://www.w3schools.com/js/js_json_intro.asp), pero los
  # manejaremos en R a través de una cadena:
  #   
  # * age_min: es un valor
  # * age_max: es un valor
  # * genders: es un valor
  # * geo_locations: es un objeto JSON donde *país* es una matriz
  
  query <- paste0(Credentials,'&
                targeting_spec={
                "age_min":',Age1,',
                "age_max":',Age2,',
                "genders":[',g,'],
                "geo_locations":{"countries":[',C,'],"location_types":["home"]}}')
  
  query_val<-url(gsub('[\n\t ]','',query))%>%fromJSON
  query_val=as.data.frame(query_val$data)[,-1]
  
  query_val$LOCATION=str_remove_all(C,"\"")
  query_val$GENDER=ifelse(g=="1","Male",ifelse(g=="2","Female","Both"))
  
  TIME=Sys.time()
  TIME=stringi::stri_split_fixed(TIME," ")
  
  query_val$DAY=TIME[[1]][1]
  query_val$HOUR=TIME[[1]][2]
  
  return(query_val)
  
  }

# Initialize a variable to count the files you have been saving:
COUNT=0
REGION=c('"MX"','"NL"','"DE"')
Direc1="..."

# Then pass the function into an infinite loop
while (1) {
  
  DF=data.frame()
  
  for(ce in REGION){
    print(ce)
    if(dim(DF)[1]==0){
      message<-try(DF<-FUNCTION_TO_RETRIEVE_FB_DATA(ce),silent = TRUE)
      while(class(message)=="try-error"){
        Sys.sleep(1800)
        message<-try(DF<-FUNCTION_TO_RETRIEVE_FB_DATA(ce),silent = TRUE)
      }
      write.table(DF,paste0(Direc1,'FB_Loc_Type_',COUNT,'.txt'),sep=",",row.names = FALSE)
    }else{
      message<-try(DF<-FUNCTION_TO_RETRIEVE_FB_DATA(ce),silent = TRUE)
      while(class(message)=="try-error"){
        Sys.sleep(1800)
        message<-try(DF<-FUNCTION_TO_RETRIEVE_FB_DATA(ce),silent = TRUE)
      }
      write.table(DF,paste0(Direc1,'FB_Loc_Type_',COUNT,'.txt'),sep=",",append = TRUE,row.names = FALSE,col.names = FALSE)
    }
  }
  
  COUNT=COUNT+1  
  
}

#  For any question related with R, I would recommend you use https://stackoverflow.com/ .

