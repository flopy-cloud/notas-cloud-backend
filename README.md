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

## Tecnologías

- Python 3.12
- AWS Lambda
- AWS API Gateway (HTTP API)
- AWS DynamoDB

## Frontend

El frontend de este proyecto está en [notas-frontend](https://github.com/flopy-cloud/notas-frontend)