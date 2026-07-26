# Notas Cloud - Backend

Backend serverless para una app de notas, usando AWS Lambda y DynamoDB.

## Arquitectura

- API Gateway: recibe las peticiones HTTP
- AWS Lambda: procesa la logica (crear y listar notas)
- DynamoDB: almacena las notas

## Funciones

- POST -> crea una nota nueva
- GET -> lista todas las notas