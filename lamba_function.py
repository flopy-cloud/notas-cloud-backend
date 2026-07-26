import json
import boto3
import uuid

dynamodb = boto3.resource('dynamodb')
tabla = dynamodb.Table('NotasCloud')

def lambda_handler(event, context):
    metodo = event.get('httpMethod', 'GET')
    
    if metodo == 'POST':
        return crear_nota(event)
    elif metodo == 'GET':
        return listar_notas()
    elif metodo == 'DELETE':
        return borrar_nota(event)
    else:
        return respuesta(400, {'error': 'Metodo no soportado'})


def crear_nota(event):
    body = json.loads(event['body'])
    nota_id = str(uuid.uuid4())
    
    tabla.put_item(Item={
        'NotaId': nota_id,
        'Titulo': body.get('titulo', ''),
        'Contenido': body.get('contenido', '')
    })
    
    return respuesta(201, {'mensaje': 'Nota creada', 'id': nota_id})


def listar_notas():
    resultado = tabla.scan()
    return respuesta(200, resultado.get('Items', []))


def borrar_nota(event):
    params = event.get('queryStringParameters') or {}
    nota_id = params.get('id')
    
    if not nota_id:
        return respuesta(400, {'error': 'Falta el id de la nota'})
    
    tabla.delete_item(Key={'NotaId': nota_id})
    
    return respuesta(200, {'mensaje': 'Nota eliminada', 'id': nota_id})  


def respuesta(codigo, cuerpo):
    return {
        'statusCode': codigo,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps(cuerpo)
    }