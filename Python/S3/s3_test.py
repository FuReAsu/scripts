import boto3
import cv2
import os

#s3 connection 
s3 = boto3.client(
    's3',
    endpoint_url='http://s3.intmm.net', #s3 storage endpoint
    aws_access_key_id='MITFN8ROG0K6N4ID6YHD', #s3 access key
    aws_secret_access_key='5ulviVWQYSNafAoHjizwiEUXMOICMFp4AQFFzMqo', # s3 secret key
)

#set bucket name
bucket_name = 'image-bucket'

#get s3 object list
response = s3.list_objects_v2(Bucket=bucket_name)

#loop to get images and show them
for object in response.get('Contents',[]):
    #get the file name from object's key
    file_name=object['Key']
    
    #check if the file is an image
    if file_name.lower().endswith(('jpg','jpeg','png','gif','bmp')):
        #create the local file name 
        local_file=os.path.join('.',file_name)
        
        #download s3 object to local file
        s3.download_file(bucket_name, file_name, local_file)
        print(f'{file_name} downloaded')

        #use opencv to show the downloaded get
        img = cv2.imread(file_name)
        cv2.imshow('image',img)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

        #remove the image after it has been shown
        os.remove(file_name)
        print(f'{file_name} deleted')