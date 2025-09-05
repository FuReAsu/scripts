import logging
import boto3
from botocore.exceptions import ClientError
stop = 'n'
bucket_name = input('Bucket Name: ')
expiration = input('Expires in seconds: ')

while stop == 'n':
    s3 = boto3.client(
    's3',
    endpoint_url='http://s3.intmm.net', 
    aws_access_key_id='9BF8OK9MR4PC9OAM4F68', 
    aws_secret_access_key='fLkKd1lywrO3WhERcQxx6O1E2ASrnetIsuujZf6r', 
)
    response = s3.list_objects_v2(Bucket=bucket_name)
    i=0
    obj_list = []
    for object in response.get('Contents',[]):
        file_name = object['Key']
        print(f'{i}:{file_name}')
        obj_list.append(file_name)
        i +=1

    print("Enter 99999 for all")
    option = int(input("Enter the number of the file you want to generate pre-signed-url: "))

    if option == 99999:
        
        for obj in obj_list:
            try:
                response = s3.generate_presigned_url('get_object',Params={'Bucket': bucket_name, 'Key': obj}, ExpiresIn=expiration)
            except ClientError as e:
                logging.error(e)
            print(f'\n {response} \n')
    else:
        obj = obj_list[option]
        try:
                response = s3.generate_presigned_url('get_object',Params={'Bucket': bucket_name, 'Key': obj}, ExpiresIn=expiration)
        except ClientError as e:
                logging.error(e)
        print(f'\n {response} \n')

    obj_list.clear()
    stop = input('stop? y/n: ')