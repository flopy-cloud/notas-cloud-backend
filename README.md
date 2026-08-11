# Notas Cloud - Backend

Backend serverless para una app de notas, usando AWS Lambda y DynamoDB.

## Arquitectura

- API Gateway: recibe las peticiones HTTP
- AWS Lambda: procesa la logica (crear y listar notas)
- DynamoDB: almacena las notas

## Funciones

- POST -> crea una nota nueva
- GET -> lista todas las notas

## Debugging destacado

Durante el desarrollo detecté y resolví un bug donde el Lambda no distinguía correctamente el método HTTP recibido: al usar una API Gateway de tipo HTTP API (en vez de REST API), el método no llega en event['httpMethod'] sino en event['requestContext']['http']['method']. Esto hacía que todas las peticiones cayeran por default en la rama de "listar notas", incluso los POST. También agregué el manejo del método OPTIONS, necesario para pasar el preflight de CORS que hace el navegador antes de un POST.

Al agregar las funciones de editar (PUT) y borrar (DELETE), me encontré con un segundo problema de CORS, esta vez con dos causas superpuestas:

1. La función respuesta() de la Lambda no incluía los headers de CORS (Access-Control-Allow-Origin, Access-Control-Allow-Methods, Access-Control-Allow-Headers) en ninguna respuesta.
2. La configuración de CORS del API Gateway (independiente del código de la Lambda) solo permitía los métodos GET, POST y OPTIONS, bloqueando el preflight de DELETE y PUT antes de que la petición llegara siquiera a la Lambda.

Fue necesario corregir ambas capas: agregar los headers de CORS en la función respuesta() del backend, y actualizar la configuración de CORS del API Gateway para incluir PUT y DELETE en AllowMethods. Este caso mostró que en HTTP API el CORS se maneja en dos niveles distintos e independientes, y que un error 403/CORS en el navegador puede tener origen en cualquiera de los dos.

## Tecnologías

- Python 3.12
- AWS Lambda
- AWS API Gateway (HTTP API)
- AWS DynamoDB

## Frontend

El frontend de este proyecto está en [notas-frontend](https://github.com/flopy-cloud/notas-frontend)