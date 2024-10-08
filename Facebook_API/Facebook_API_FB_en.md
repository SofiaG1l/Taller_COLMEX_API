-   [First step](#first-step)
-   [API Step by Step](#api-step-by-step)
    -   [Credential Settings](#credential-settings)
    -   [The basics](#the-basics)
        -   [Using the Facebook Marketing Graphic User
            Interface](#using-the-facebook-marketing-graphic-user-interface)
        -   [1.Using Basic URLs](#using-basic-urls)
        -   [2.Download data
            programmatically](#download-data-programmatically)
        -   [3.Total population disaggregated by age, sex and
            country](#total-population-disaggregated-by-age-sex-and-country)
        -   [4.Total population matching certain characteristics broken
            down by age, sex and
            country](#total-population-matching-certain-characteristics-broken-down-by-age-sex-and-country)
    -   [More Sofisticated Queries](#more-sofisticated-queries)
        -   [Adding variables that are not in the
            lists](#adding-variables-that-are-not-in-the-lists)
        -   [Geographic variables](#geographic-variables)

<!--  https://bookdown.org/yihui/rmarkdown/html-document.html -->

This tutorial is an adaptation of the one I gave in 2019:
<https://github.com/SofiaG1l/Using_Facebook_API>

**If you find the tutorial useful, then please do not forget to cite my
Facebook articles:**

-   Gil-Clavel, Sofia, and Emilio Zagheni. “Demographic Differentials in
    Facebook Usage around the World.” Proceedings of the International
    AAAI Conference on Web and Social Media 13 (2019): 647–50.

-   Gil-Clavel, Sofia, Emilio Zagheni, and Valeria Bordone. “Close
    Social Networks Among Older Adults: The Online and Offline
    Perspectives.” Population Research and Policy Review, October
    26, 2021. <https://doi.org/10.1007/s11113-021-09682-3>.

# First step

To generate the token we will need to enable Facebook advertising on
your Facebook account.

To do this you can follow this guide, just remember you want to open a
*Marketing App*:
<https://github.com/SofiaG1l/Using_Facebook_API/blob/master/First_Step.pdf>

Once you have a developer account, you can use the following links to:

-   Access your applications: <https://developers.facebook.com/apps/>

-   To monitor when your token expires:
    <https://developers.facebook.com/tools/debug/accesstoken>

# API Step by Step

    # Cleaning the R Environment
    rm(list=ls())

    # Cleaning the Computer Memory
    gc()

## Credential Settings

    token="<Your Token>" # Change the "Your Token" with your token and delete the: <>

    act="<Your Act>" # Change the "Your Act" with your Creation Act and delete the: <>

    version="<vXX.X>" # Change the Xs for your version and delete the: <>

    Credentials=paste0('https://graph.facebook.com/',version,'/act_',act,'/delivery_estimate?access_token=',token,'&include_headers=false&method=get&optimization_goal=REACH&pretty=0&suppress_http_code=1')

## The basics

### Using the Facebook Marketing Graphic User Interface

In the next pdf, I explain how to access the Graphic User Interface of
the Facebook Marketing Manager. In it, I check the number of Facebook
users that are German and older than 17 years old. As you can see, the
Facebook Marketing Manager returns the “Estimated audience size” of
Facebook users in Germany that are older than 17 years old, which in
April 21st 2022 was between 40.4 million and 47.6 million.

<https://github.com/SofiaG1l/Taller_COLMEX_API/blob/main/Facebook_API/FB_GUI_Audience.pdf>

### 1.Using Basic URLs

First, we will try to use a browser. I would recommend you to use
Mozilla, as it displays the result in a nicer manner than Google Chrome.

What you need to do with the following link is to replace your
credentials where necessary and then copy the full link into your
browser.

    # https://graph.facebook.com/<<vXX.X>>/act_<<ACT>>/delivery_estimate?access_token=<<TOKEN>>&include_headers=false&method=get&pretty=0&suppress_http_code=1&method=get&optimization_goal=REACH&pretty=0&suppress_http_code=1&targeting_spec={"geo_locations":{"countries":["MX"]},"genders":[1,2] ,"age_min":18, "age_max":65}

This should return/display a type of data called JSON. In it you will
see the next variables:

-   daily\_outcomes\_curve
-   estimate\_dau
-   estimate\_mau\_lower\_bound
-   estimate\_mau\_upper\_bound
-   estimate\_ready

You can learn more about them here:
<https://developers.facebook.com/docs/marketing-api/audiences/reference/estimated-daily-results/>

### 2.Download data programmatically

To download and transform the data to a data frame we will use the
packages **httr**, **jsonlite** y **tidyverse**. If you have not
installed them in R, then first you would need to use the function
*install.packages(“name”)* replacing **name** by the name of the
package.

    require(httr)
    require(jsonlite)
    require(tidyverse)

### 3.Total population disaggregated by age, sex and country

The parameters we use are in JSON format. You can learn more about that
format in the next
[linnk](https://www.w3schools.com/js/js_json_intro.asp). We will handle
the format in R using strings.

-   age\_min: integer value
-   age\_max: integer value
-   genders: integer value
-   geo\_locations: JSON object where *country* is a matrix

<!-- -->

    Age1=18
    Age2=65

    g="1,2" # 1:male and 2:female, and both is: g="1,2"

    C='"MX"' # The ISO-2 code of the country

    query <- paste0(Credentials,'&
                    targeting_spec={
                    "age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,'],
                    "geo_locations":{"countries":[',C,']}}')

    # REMOVE: ,"location_types":["home"]

    (query_val<-url(gsub('[\n\t ]','',query))%>%fromJSON)

    t(query_val$data)

### 4.Total population matching certain characteristics broken down by age, sex and country

The first step is to know the name of all the possible variables that we
can query. There are three different classes that you can call by
changing the parameter *class*:

-   demographics
-   interests
-   behaviors

<!-- -->

    DF_CHARTICS<-GET(
      
      paste0("https://graph.facebook.com/",version,"/search"),
      
      query=list(
        
        type='adTargetingCategory',
        
        class='demographics',
        
        access_token=token,
        
        limit=2000
        
      )) %>%content(as="text")%>%fromJSON%>%.[[1]]

    View(DF_CHARTICS)

Now we are going to prepare a basic query, for this you just have to
choose a variable and save the following information:

    ROW=1

    (TYPE=DF_CHARTICS$type[ROW])
    (ID=DF_CHARTICS$id[ROW])
    (NAME=DF_CHARTICS$name[ROW])

To segment populations that match specific characteristics we will use
the *flexible\_spec* parameter of the Facebook Marketing API, this
parameter is a JSON object. To incorporate it into our initial string,
we’ll store the string in the variable **CHARTICS**.

    CHARTICS<-paste0(',"flexible_spec":[{"',TYPE,'":[{"id":"',ID,'","name":"',NAME,'"}]}]')

    # A basic query including this parameter is:
      
    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,']',
                    CHARTICS,',
                    "geo_locations":{"countries":[',C,']},
                    "facebook_positions":["feed","instant_article","instream_video","marketplace"],
                    "device_platforms":["mobile","desktop"],
                    "publisher_platforms":["facebook","messenger"],
                    "messenger_positions":["messenger_home"]}')

    # REMOVE: ,"location_types":["home"]

    (query_val<-url(gsub('[\n\t ]','',query))%>%fromJSON)

    t(query_val$data)

In the case of specific characteristics, you can make the following
types of queries:
<https://developers.facebook.com/docs/marketing-api/audiences/reference/advanced-targeting#broadcategories>

Here is how to translate the examples in the link to R:

-   one characteristic **and** another:

<!-- -->

    '"flexible_spec":[{
                        "TYPE_1":[{"id":"ID_1","name":"NAME_1"}]
                      },
                      {
                        "TYPE_2":[{"id":"ID_2","name":"NAME_2"}]
                      }]'

-   one feature **or** another:

<!-- -->

    '"flexible_spec":[{
        "TYPE_1":[{"id":"ID_1","name":"NAME_1"}],
        "TYPE_2":[{"id":"ID_2","name":"NAME_2"}]
      }]'

In the case of OR we need to group by TYPE. Check the following example:
*People who are travelers OR like soccer OR movies*

    '"flexible_spec": [{ 
        "behaviors": [
              {"id":6002714895372,"name":"All travelers"}
            ], 
        "interests": [ 
              {"id":6003107902433,"name":"Association football (Soccer)"}, 
              {"id":6003139266461,"name":"Movies"} 
            ] 
      }]'

More info here:
<https://developers.facebook.com/docs/marketing-api/audiences/reference/advanced-targeting#broadcategories>

    ROW=which(DF_CHARTICS$name=="Away from hometown")

    (TYPE_1=DF_CHARTICS$type[ROW])
    (ID_1=DF_CHARTICS$id[ROW])
    (NAME_1=DF_CHARTICS$name[ROW])

    ROW=which(DF_CHARTICS$name=="Friends of people with birthdays in a month")

    (TYPE_2=DF_CHARTICS$type[ROW])
    (ID_2=DF_CHARTICS$id[ROW])
    (NAME_2=DF_CHARTICS$name[ROW])

    # Preparing string of characteristics:
    CHARTICS<-paste0(',"flexible_spec":[{"',TYPE_1,'":[{"id":"',ID_1,'","name":"',NAME_1,'"}]},
                     {"',TYPE_2,'":[{"id":"',ID_2,'","name":"',NAME_2,'"}]}]')

    # Preparing query:
    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,']',
                    CHARTICS,',
                    "geo_locations":{"countries":[',C,']}}')

    # REMOVE: ,"location_types":["home"]

    # Retrieving:
    queryAND_val<-url(gsub('[\n\t ]','',query))%>%fromJSON

You can find a more complex example in the
[code](https://github.com/SofiaG1l/OlderAdultsCloseSocialNetworks) of my
article publication: [Close Social Networks Among Older Adults: The
Online and Offline
Perspectives](https://doi.org/10.1007/s11113-021-09682-3).

## More Sofisticated Queries

### Adding variables that are not in the lists

Suppose you want to download by [educational
level](https://developers.facebook.com/docs/marketing-api/audiences/reference/advanced-targeting#education_and_workplace),
what you need to do is add the level in the **CHARTICS** array as one
more variable.

    EDU='"education_statuses":["1","2"]'

    CHARTICS<-paste0(',"flexible_spec":[{',EDU,'},{"',TYPE,'":[{"id":"',ID,'","name":"',NAME,'"}]}]')

    # A basic query including this parameter is:
      
    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,']',
                    CHARTICS,',
                    "geo_locations":{"countries":[',C,']}}')

    query_val<-url(gsub('[\n\t ]','',query))%>%fromJSON

    t(query_val$data)

If you need to search by school or university then you will need to
download the IDS. You can download them here:

<https://developers.facebook.com/docs/marketing-api/audiences/reference/targeting-search#demo>

    DF_CHARTICS<-GET(
      
      paste0("https://graph.facebook.com/",version,"/search"),
      
      query=list(
        
        type='adeducationschool',
        
        q='UNAM',
        
        access_token=token,
        
        limit=2000
        
      )) %>%content(as="text")%>%fromJSON%>%.[[1]]

    View(DF_CHARTICS)

    EDU='"education_schools":[{id:125299054202386}]'

    CHARTICS<-paste0(',"flexible_spec":[{',EDU,'},{"',TYPE,'":[{"id":"',ID,'","name":"',NAME,'"}]}]')

    # A basic query including this parameter is:
      
    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,']',
                    CHARTICS,',
                    "geo_locations":{"countries":[',C,']}}')

    query_val<-url(gsub('[\n\t ]','',query))%>%fromJSON

    t(query_val$data)

### Geographic variables

Let’s check Facebook’s documentation on city search:

<https://developers.facebook.com/docs/marketing-api/audiences/reference/targeting-search/#cities>

As an example, we will download the data related to the cities of
Mexico. In the Facebook documentation you will find this:

    ## Cities
    DF_GEO<-GET(
      
      paste0("https://graph.facebook.com/",version,"/search"),
      
      query=list(
        
        location_types='city',
        
        type='adgeolocation',
        
        q='Mexico',
        
        country_code='MX', # You can delete this parameter to create an open search
        
        access_token=token,
        
        limit=100
        
      )) %>%content(as="text")%>%fromJSON%>%.[[1]]

    View(DF_GEO)

#### From country to region

In the following link you can find the variables referring to
geo-location:

<https://developers.facebook.com/docs/marketing-api/audiences/reference/basic-targeting#location>

Let’s start with regions:

    ## Cities
    DF_GEO<-GET(
      
      paste0("https://graph.facebook.com/",version,"/search"),
      
      query=list(
        
        location_types='region',
        
        type='adgeolocation',
        
        q='Mexico',
        
        country_code='MX', # You can remove this to make your query less specific
        
        access_token=token,
        
        limit=100
        
      )) %>%content(as="text")%>%fromJSON%>%.[[1]]

    View(DF_GEO)

    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,'],
                    "geo_locations":{"regions": [{"key":"2518"}]},
                    "publisher_platforms":["facebook","messenger"]}')

    (GEO_QUERY<-url(gsub('[\n\t ]','',query))%>%fromJSON)

To download the data related to different cities you only need to
include them in the matrix:

    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,'],
                    "geo_locations":{"regions": [{"key":"2518"},{"key":"2535"}]},
                    "publisher_platforms":["facebook","messenger"]}')

    (GEO_QUERY<-url(gsub('[\n\t ]','',query))%>%fromJSON)

Now we will download data by city:

    ## Cities
    DF_GEO<-GET(
      
      paste0("https://graph.facebook.com/",version,"/search"),
      
      query=list(
        
        location_types='city',
        
        type='adgeolocation',
        
        q='Guadalajara',
        
        country_code='MX', # You can remove this to make your query less specific
        
        access_token=token,
        
        limit=100
        
      )) %>%content(as="text")%>%fromJSON%>%.[[1]]

    View(DF_GEO)

    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,'],
                    "geo_locations":{
                      "cities":[{"distance_unit":"mile","key":"2673660","name":"Mexico City","region":"Distrito Federal","region_id":"2513","country":"MX","radius":25}]
                    },
                    "publisher_platforms":["facebook","messenger"]}')

    (GEO_QUERY<-url(gsub('[\n\t ]','',query))%>%fromJSON)

    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,'],
                    "geo_locations":{"cities": [{"key":"1522110", "radius":25, "distance_unit":"mile"}]},
                    "publisher_platforms":["facebook","messenger"]}')

    (GEO_QUERY<-url(gsub('[\n\t ]','',query))%>%fromJSON)
