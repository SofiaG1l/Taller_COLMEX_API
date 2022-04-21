-   [Uso de la API de Twitter](#uso-de-la-api-de-twitter)
    -   [API de Twitter: Primeros pasos](#api-de-twitter-primeros-pasos)
    -   [Ejemplos básicos](#ejemplos-básicos)
        -   [Información por el nombre del
            usuario](#información-por-el-nombre-del-usuario)
        -   [Info by User ID](#info-by-user-id)
    -   [Aumentando la dificultad](#aumentando-la-dificultad)
        -   [Tweets públicos por ID de
            Tweet](#tweets-públicos-por-id-de-tweet)
        -   [Tweets públicos por parámetros de
            tweets](#tweets-públicos-por-parámetros-de-tweets)

Uso de la API de Twitter
========================

¡Hola! ¡Bienvenido a este tutorial!

Aquí aprenderás a utilizar la API de Twitter siguiendo los códigos
*curl* en bruto de las páginas web de los desarrolladores de Twitter.

Para ello necesitarás lo siguiente:

1.  El primer paso es obtener tus tokens. Para ello, tienes que entrar
    en la siguiente página web y registrarte para obtener una cuenta de
    desarrollador:

<a href="https://developer.twitter.com/en/docs/twitter-api/getting-started/getting-access-to-the-twitter-api" class="uri">https://developer.twitter.com/en/docs/twitter-api/getting-started/getting-access-to-the-twitter-api</a>

1.  Instala R y Rstudio en tu ordenador.

2.  Instale los paquetes:

-   httr
-   jsonlite
-   tidyverse

Una vez que tengas tu token, podemos empezar a descargar datos.

API de Twitter: Primeros pasos
------------------------------

Este tutorial está parcialmente inspirado en la guía del usuario de
Twitter:
<a href="https://developer.twitter.com/en/docs/tutorials/getting-started-with-r-and-v2-of-the-twitter-api" class="uri">https://developer.twitter.com/en/docs/tutorials/getting-started-with-r-and-v2-of-the-twitter-api</a>

1.  Abra las bibliotecas de R:

<!-- -->

    rm(list=ls())
    gc()

    require(httr)
    require(jsonlite)
    require(tidyverse)

1.  Guarda tu ficha en el entorno:

<!-- -->

    # Configurar la variable de entorno
    TOKEN="<Your Bearer Token>"

Para todos estos ejemplos, utilizaremos el Token del Portador. Por lo
tanto, guardaremos ese token en una variable de la siguiente manera:

    headers <- c(`Authorization` = sprintf('Bearer %s', TOKEN))

Ejemplos básicos
----------------

Puedes hacer muchas cosas con tu cuenta de desarrollador de Twitter.
Puedes consultar en el siguiente enlace todas las funcionalidades que
tiene Twitter:

<a href="https://developer.twitter.com/en/docs/api-reference-index" class="uri">https://developer.twitter.com/en/docs/api-reference-index</a>

Empecemos con algo fácil. Para el siguiente ejemplo no necesitas una
cuenta de desarrollador aprobada. Esto se debe a que, sólo está
accediendo a la información básica de los usuarios públicos, es decir,
sus perfiles.

### Información por el nombre del usuario

Veamos un ejemplo básico:

    USER="Twitter"

    response <-
      GET(
        paste0('https://api.twitter.com/2/users/by?usernames=', USER),
        add_headers(.headers = headers),
        query = list(
          user.fields = 'description,created_at,public_metrics'
          ))%>%content(as = "text")

    print(response)

### Info by User ID

    USER_ID='783214'

    response <-
      GET(
        url = paste0('https://api.twitter.com/2/users/', USER_ID),
        add_headers(.headers = headers),
        query = list(
          user.fields = 'description,created_at,public_metrics'
          ))%>%content(as = "text")

    print(response)

Aumentando la dificultad
------------------------

### Tweets públicos por ID de Tweet

Ahora vamos a traducir el ejemplo de Twitter que está aquí:

<a href="https://developer.twitter.com/en/docs/twitter-api/data-dictionary/object-model/tweet" class="uri">https://developer.twitter.com/en/docs/twitter-api/data-dictionary/object-model/tweet</a>

    Tweet_ID='1212092628029698048'

    response <-
      GET(
        
        paste0('https://api.twitter.com/2/tweets?ids=', Tweet_ID),
        
        add_headers(.headers = headers),
        
        query = list(
          tweet.fields="attachments,author_id,context_annotations,created_at,entities,geo,id,in_reply_to_user_id,lang,possibly_sensitive,public_metrics,referenced_tweets,source,text,withheld",
          expansions="referenced_tweets.id"
        
          ))%>%content(as = "text")

    print(response)

We need to transform the answer into something a dataframe. For this we
will use the package tidyverse together with jsonlite.

    TWEET<-response%>%fromJSON%>%.[[1]]

    TWEET$text

    TWEET$public_metrics

### Tweets públicos por parámetros de tweets

Cuando se descargan los tweets siempre es importante ser precavido. No
querrás dejar accidentalmente la API funcionando sin control. Si lo
haces, entonces puedes quedarte sin tus consultas mensuales. Así que ten
cuidado.

Ahora, aprenderemos a utilizar los parámetros de la API de Twitter en
general:

<a href="https://developer.twitter.com/en/docs/tutorials/building-high-quality-filters" class="uri">https://developer.twitter.com/en/docs/tutorials/building-high-quality-filters</a>

Y seguiremos las siguientes sugerencias:

<a href="https://twitterdev.github.io/do_more_with_twitter_data/finding_the_right_data.html" class="uri">https://twitterdev.github.io/do_more_with_twitter_data/finding_the_right_data.html</a>

Bien, pero ¿cómo introduzco los parámetros?

Empezaremos por descargar los tweets que coincidan con nuestros
parámetros de los últimos siete días. Para ello, seguiremos el siguiente
ejemplo:

<a href="https://developer.twitter.com/en/docs/twitter-api/tweets/search/api-reference/get-tweets-search-recent" class="uri">https://developer.twitter.com/en/docs/twitter-api/tweets/search/api-reference/get-tweets-search-recent</a>

Traducido:

    response <- GET(
      'https://api.twitter.com/2/tweets/search/recent',
      add_headers(.headers=headers),
      query = list(
        query = 'cat',
        expansions='geo.place_id',
        place.fields='country_code',
        max_results=10
      ))%>%
      content(as = "text")

    print(response)

    # response%>%fromJSON()

    TWEET<-response%>%fromJSON%>%.[[1]]

Otros parámetros están limitados al tipo de acceso que se tiene a la
API. Esta es la lista de parámetros y su disponibilidad:

<a href="https://developer.twitter.com/en/docs/twitter-api/tweets/search/integrate/build-a-query#list" class="uri">https://developer.twitter.com/en/docs/twitter-api/tweets/search/integrate/build-a-query#list</a>

    response <- GET(
      'https://api.twitter.com/2/tweets/search/recent', 
      add_headers(.headers=headers),
      query = list(
        query= 'happy place_country:GB',
        max_results=10
      ))%>%content(as = "text")

    print(response)
