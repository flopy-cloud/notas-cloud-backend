# CI/CD funcionando correctamente
import json
import boto3
import uuid

dynamodb = boto3.resource('dynamodb')
tabla = dynamodb.Table('NotasCloud')

def lambda_handler(event, context):
    metodo = event.get('requestContext', {}).get('http', {}).get('method', 'GET')

    try:
        if metodo == 'POST':
            return crear_nota(event)
        elif metodo == 'GET':
            return listar_notas()
        elif metodo == 'DELETE':
            return borrar_nota(event)
        elif metodo == 'PUT':
            return editar_nota(event)
        elif metodo == 'OPTIONS':
            return respuesta(200, {})
        else:
            return respuesta(400, {'error': 'Metodo no soportado'})
    except Exception as e:
        return respuesta(500, {'error': 'Error interno', 'detalle': str(e)})


def obtener_body(event):
    if not event.get('body'):
        return None, respuesta(400, {'error': 'Falta el body de la peticion'})
    try:
        return json.loads(event['body']), None
    except json.JSONDecodeError:
        return None, respuesta(400, {'error': 'El body no es un JSON valido'})


def nota_existe(nota_id):
    resultado = tabla.get_item(Key={'NotaId': nota_id})
    return 'Item' in resultado


def crear_nota(event):
    body, error = obtener_body(event)
    if error:
        return error

    titulo = body.get('Titulo', '').strip()
    contenido = body.get('Contenido', '').strip()

    if not titulo:
        return respuesta(400, {'error': 'El titulo no puede estar vacio'})

    nota_id = str(uuid.uuid4())

    tabla.put_item(Item={
        'NotaId': nota_id,
        'Titulo': titulo,
        'Contenido': contenido
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

    if not nota_existe(nota_id):
        return respuesta(404, {'error': 'No existe una nota con ese id'})

    tabla.delete_item(Key={'NotaId': nota_id})

    return respuesta(200, {'mensaje': 'Nota eliminada', 'id': nota_id})


def editar_nota(event):
    params = event.get('queryStringParameters') or {}
    nota_id = params.get('id')

    if not nota_id:
        return respuesta(400, {'error': 'Falta el id de la nota'})

    if not nota_existe(nota_id):
        return respuesta(404, {'error': 'No existe una nota con ese id'})

    body, error = obtener_body(event)
    if error:
        return error

    titulo = body.get('titulo', '').strip()
    contenido = body.get('contenido', '').strip()

    if not titulo:
        return respuesta(400, {'error': 'El titulo no puede estar vacio'})

    tabla.update_item(
        Key={'NotaId': nota_id},
        UpdateExpression='SET Titulo = :t, Contenido = :c',
        ExpressionAttributeValues={
            ':t': titulo,
            ':c': contenido
        }
    )

    return respuesta(200, {'mensaje': 'Nota actualizada', 'id': nota_id})


def respuesta(codigo, cuerpo):
    return {
        'statusCode': codigo,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        },
        'body': json.dumps(cuerpo)
    }