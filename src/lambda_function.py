import json
import boto3
import os
from datetime import datetime

localstack_host = os.environ.get('LOCALSTACK_HOSTNAME', 'localhost')
endpoint_url = f"http://{localstack_host}:4566"

s3_client = boto3.client('s3', endpoint_url=endpoint_url)
dynamodb = boto3.resource('dynamodb', endpoint_url=endpoint_url)
table = dynamodb.Table('Tb_Logs_DevOps')

def lambda_handler(event, context):
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        
        print(f"🔥 Processando e extraindo: {key}")

        # 1. Extração
        response = s3_client.get_object(Bucket=bucket, Key=key)
        conteudo = response['Body'].read().decode('utf-8')

        # 2. Persistência no DynamoDB
        table.put_item(
           Item={
                'LockID': key,
                'Timestamp': datetime.now().isoformat(),
                'Status': 'Processado',
                'MensagemExtraida': conteudo[:100]
            }
        )
        print(f"✅ Registro salvo no DynamoDB.")

        # 3. LIMPEZA (FinOps): Apaga o ficheiro do S3 após processar
        s3_client.delete_object(Bucket=bucket, Key=key)
        print(f"🗑️ Ficheiro {key} removido do S3 para economizar custos.")
        
    except Exception as e:
        print(f"❌ ERRO: {str(e)}")
        raise e

    return {'statusCode': 200}