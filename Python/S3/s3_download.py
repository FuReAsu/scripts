import boto3
import os
import time
stop = 'n'

bucket_name = input("Bucket Name: ")

while stop == 'n':
    s3 = boto3.client('s3')
    response = s3.list_objects_v2(Bucket=bucket_name)
    i=0
    obj_list = []
    for object in response.get('Contents',[]):
        file_name = object['Key']
        print(f'{i}:{file_name}')
        obj_list.append(file_name)
        i +=1

    print("Enter 99999 for all")
    option = int(input("Enter the number of the file you want to download: "))

    if option == 99999:
        for obj in obj_list:
            local_file = os.path.join('.',obj)
            start = time.time()
            s3.download_file(bucket_name, obj, local_file)
            end = time.time()
            print(f'{obj} downloaded within {end-start} seconds')
    else:
        obj = obj_list[option]
        local_file = os.path.join('download',obj)
        start = time.time()
        s3.download_file(bucket_name, obj, local_file )
        end = time.time()
        print(f'{obj} downloaded within {end-start} seconds')
    obj_list.clear()
    stop = input('stop? y/n: ')
