-   <a href="#primer-paso" id="toc-primer-paso">Primer paso</a>
-   <a href="#api-paso-a-paso" id="toc-api-paso-a-paso">API Paso a Paso</a>
    -   <a href="#configuración-de-las-credenciales"
        id="toc-configuración-de-las-credenciales">Configuración de las
        credenciales</a>
    -   <a href="#lo-básico" id="toc-lo-básico">1. Lo Básico</a>
        -   <a href="#uso-de-la-interfaz-gráfica-de-usuario-de-facebook-marketing"
            id="toc-uso-de-la-interfaz-gráfica-de-usuario-de-facebook-marketing">Uso
            de la interfaz gráfica de usuario de Facebook Marketing</a>
        -   <a href="#utilizando-urls-básicos"
            id="toc-utilizando-urls-básicos">Utilizando URLs básicos</a>
    -   <a href="#descarga-de-datos-de-forma-programática"
        id="toc-descarga-de-datos-de-forma-programática">2. Descarga de datos de
        forma programática</a>
    -   <a href="#población-total-desglosada-por-edad-sexo-y-país"
        id="toc-población-total-desglosada-por-edad-sexo-y-país">3. Población
        total desglosada por edad, sexo y país</a>
    -   <a
        href="#población-total-que-coincide-con-determinadas-características-desglosada-por-edad-sexo-y-país"
        id="toc-población-total-que-coincide-con-determinadas-características-desglosada-por-edad-sexo-y-país">4.
        Población total que coincide con determinadas características desglosada
        por edad, sexo y país</a>
    -   <a href="#agregando-variables-que-no-están-en-la-lista"
        id="toc-agregando-variables-que-no-están-en-la-lista">Agregando
        variables que no están en la lista:</a>
    -   <a href="#variables-geográficas"
        id="toc-variables-geográficas">Variables geográficas</a>
        -   <a href="#de-país-a-región" id="toc-de-país-a-región">De país a
            región</a>

> Última actualización del código: 6 de Octubre del 2023.

<!--  https://bookdown.org/yihui/rmarkdown/html-document.html -->

Este tutorial es una adaptación del que di en 2019:
<https://github.com/SofiaG1l/Using_Facebook_API>

# Primer paso

Para generar el token necesitaremos habilitar la publicidad de Facebook
en tu cuenta de Facebook.

Para ello puedes seguir esta guía:
<https://github.com/SofiaG1l/Using_Facebook_API/blob/master/First_Step.pdf>

Una vez que tengas una cuenta de desarrollador, puedes utilizar los
siguientes enlaces para:

-   Acceder a tus aplicaciones: <https://developers.facebook.com/apps/>

-   Para monitorear cuándo caduca tu token:
    <https://developers.facebook.com/tools/debug/accesstoken>

# API Paso a Paso

    rm(list=ls())
    gc()

## Configuración de las credenciales

    token="<Your Token>"

    act="<Your Act>"

    version="vXX.X" # Cambia las Xs por tu versión y borra: <<>>

    Credentials=paste0('https://graph.facebook.com/',version,'/act_',act,'/delivery_estimate?access_token=',token,'&include_headers=false&method=get&optimization_goal=REACH&pretty=0&suppress_http_code=1')

## 1. Lo Básico

### Uso de la interfaz gráfica de usuario de Facebook Marketing

<https://github.com/SofiaG1l/Taller_COLMEX_API/blob/main/Facebook_API/FB_GUI_Audience.pdf>

### Utilizando URLs básicos

    # Primero vamos a intentar usar un navegador, reemplaza tus datos en la siguiente URL:

    # https://graph.facebook.com/<<vXX.X>>/act_<<ACT>>/delivery_estimate?access_token=<<TOKEN>>&include_headers=false&method=get&pretty=0&suppress_http_code=1&method=get&optimization_goal=REACH&pretty=0&suppress_http_code=1&targeting_spec={"geo_locations":{"countries":["MX"]},"genders":[1,2] ,"age_min":18, "age_max":65}

## 2. Descarga de datos de forma programática

Para descargar y transformar los datos a un data frame utilizaremos los
paquetes **httr**, **jsonlite** y **tidyverse**.

    require(httr)
    require(jsonlite)
    require(tidyverse)

## 3. Población total desglosada por edad, sexo y país

    # Vamos a configurar nuestras variables iniciales, se guardarán en R y luego las concatenaremos en una cadena.

    Age1=18
    Age2=65

    g="1,2" # 1:hombre and 2:mujer, pero si queremos descargar ambos géneros g="1,2"

    C='"MX"' # Código del País

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


    # (query_val<-url(query)%>%fromJSON)
    # La línea anterior en ocasiones no funciona. Depende de la versión de R.
    # Por éso hay que añadir: gsub('[\n\t ]','',query)
    (query_val<-url(gsub('[\n\t ]','',query))%>%fromJSON)

    t(query_val$data)

## 4. Población total que coincide con determinadas características desglosada por edad, sexo y país

El primer paso es conocer el nombre de todas las posibles variables que
podemos consultar. Hay tres clases diferentes:

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

Ahora vamos a preparar una consulta básica, para ello sólo tienes que
elegir una variable y guardar la siguiente información:

    ROW=1

    (TYPE=DF_CHARTICS$type[ROW])
    (ID=DF_CHARTICS$id[ROW])
    (NAME=DF_CHARTICS$name[ROW])

Para segmentar poblaciones que coincidan con características específicas
utilizaremos el parámetro *flexible\_spec* de la API de Marketing de
Facebook, este parámetro es un objeto JSON. Para incorporarlo a nuestra
cadena inicial, guardaremos la cadena en la variable **CHARTICS**.

    CHARTICS<-paste0(',"flexible_spec":[{"',TYPE,'":[{"id":"',ID,'","name":"',NAME,'"}]}]')

    # A basic query including this parameter is:
      
    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,']',
                    CHARTICS,',
                    "geo_locations":{"countries":[',C,'],"location_types":["home"]},
                    "facebook_positions":["feed","instant_article","instream_video","marketplace"],
                    "device_platforms":["mobile","desktop"],
                    "publisher_platforms":["facebook","messenger"],
                    "messenger_positions":["messenger_home"]}')


    (query_val<-url(gsub('[\n\t ]','',query))%>%fromJSON)

    t(query_val$data)

> Dependiendo de la versión de la API, tal vez tengas que borrar la
> línea 185:

    "device_platforms":["mobile","desktop"],

En el caso de las características específicas, puedes hacer el siguiente
tipo de consultas:

-   una característica **y** otra\*:

<!-- -->

    '"flexible_spec":[{
                        "TYPE_1":[{"id":"ID_1","name":"NAME_1"}]
                      },
                      {
                        "TYPE_2":[{"id":"ID_2","name":"NAME_2"}]
                      }]'

-   -   una característica **o** otra\*:

<!-- -->

    '"flexible_spec":[{
        "TYPE_1":[{"id":"ID_1","name":"NAME_1"}],
        "TYPE_2":[{"id":"ID_2","name":"NAME_2"}]
      }]'

En el caso de OR necesitamos agrupar por TIPO. Mira el siguiente
ejemplo: *Gente que es viajera O le gusta el fútbol O el cine.*

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
                    "geo_locations":{"countries":[',C,'],"location_types":["home"]},
                    "facebook_positions":["feed","instant_article","instream_video","marketplace"],
                    "device_platforms":["mobile","desktop"],
                    "publisher_platforms":["facebook","messenger"],
                    "messenger_positions":["messenger_home"]}')

    # Retrieving:
    (queryAND_val<-url(gsub('[\n\t ]','',query))%>%fromJSON)

> Dependiendo de la versión de la API, tal vez tengas que borrar la
> línea:

    "device_platforms":["mobile","desktop"],

Puede encontrar un ejemplo más complejo en el
[código](https://github.com/SofiaG1l/OlderAdultsCloseSocialNetworks) de
mi publicación [Close Social Networks Among Older Adults: The Online and
Offline Perspectives](https://doi.org/10.1007/s11113-021-09682-3).

## Agregando variables que no están en la lista:

Supongamos que quieres descargar por [nivel
educativo](https://developers.facebook.com/docs/marketing-api/audiences/reference/advanced-targeting#education_and_workplace),
lo que debes hacer es agregar el nivel en la matriz **CHARTICS** como
una variable más.

    EDU='"education_statuses":["1","2"]'

    CHARTICS<-paste0(',"flexible_spec":[{',EDU,'},{"',TYPE,'":[{"id":"',ID,'","name":"',NAME,'"}]}]')

    # A basic query including this parameter is:
      
    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,']',
                    CHARTICS,',
                    "geo_locations":{"countries":[',C,'],"location_types":["home"]}}')


    query_val<-url(gsub('[\n\t ]','',query))%>%fromJSON

    t(query_val$data)

> Dependiendo de la versión de la API, tal vez tengas que borrar la
> línea:

    "device_platforms":["mobile","desktop"],

Si necesitas búsquedas por escuela o universidad entonces necesitarás
descargar los IDS:

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
                    "geo_locations":{"countries":[',C,'],"location_types":["home"]}}')


    query_val<-url(gsub('[\n\t ]','',query))%>%fromJSON

    t(query_val$data)

## Variables geográficas

Chequemos la documentación de Facebook sobre la búsqueda de ciudades:

<https://developers.facebook.com/docs/marketing-api/audiences/reference/targeting-search/#cities>

Como ejemplo, descargaremos los datos relativos a las ciudades de
México. En la documentación de Facebook encontrarás esto:

    ## Cities
    DF_GEO<-GET(
      
      paste0("https://graph.facebook.com/",version,"/search"),
      
      query=list(
        
        location_types='city',
        
        type='adgeolocation',
        
        q='Mexico',
        
        country_code='MX', # Puedes eliminar esto para que su consulta sea menos específica
        
        access_token=token,
        
        limit=100
        
      )) %>%content(as="text")%>%fromJSON%>%.[[1]]

    View(DF_GEO)

### De país a región

En el siguiente link puedes encontrar las variables referentes a
geo-localización:

<https://developers.facebook.com/docs/marketing-api/audiences/reference/basic-targeting#location>

Comencemos con regiones:

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

Para descargar los datos relativos a distintas cuidades sólo necesitas
incluirlos en la matriz:

    query <- paste0(Credentials,'&
    targeting_spec={"age_min":',Age1,',
                    "age_max":',Age2,',
                    "genders":[',g,'],
                    "geo_locations":{"regions": [{"key":"2518"},{"key":"2535"}]},
                    "publisher_platforms":["facebook","messenger"]}')

    (GEO_QUERY<-url(gsub('[\n\t ]','',query))%>%fromJSON)

Ahora descargaremos datos por ciudad:

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
