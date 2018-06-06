import boto3
import datetime
import re
import os

ec2 = boto3.client('ec2')
iam = boto3.client('iam')

backup_name = os.environ.get("backup_name")
default_retention = int(os.environ.get("default_retention"))

def ebs_backup(event, context):
    volumes = ec2.describe_volumes(
        Filters=[
            {'Name': 'tag:Backup', 'Values': [backup_name]},
            {'Name': 'attachment.status', 'Values': ['attached']},
        ]
    )
    print("Volumes:", volumes)

    now = datetime.datetime.now().strftime('%y%m%d%H%M')
    for volume in volumes['Volumes']:
        retention_days = default_retention
        volume_name = ''
        for tag in volume['Tags']:
            if tag['Key'] == 'Retention':
                retention_days = int(tag['Value'])
            if tag['Key'] == 'Name':
                volume_name = tag['Value']
        delete_date = datetime.date.today() + datetime.timedelta(days=retention_days)
        description = 'Backup of {} For {} Days'.format(volume['VolumeId'], retention_days)

        snapshot = ec2.create_snapshot(
            VolumeId=volume['VolumeId'],
            Description=description
        )
        ec2.create_tags(
            Resources=[
                snapshot['SnapshotId']
            ],
            Tags=[
                {'Key': 'Backup', 'Value': backup_name},
                {'Key': 'Name', 'Value': volume_name + ' ' + now},
                {'Key': 'DeleteOn', 'Value': delete_date.strftime('%Y-%m-%d')}
            ]
        )

def ebs_backup_delete(event, context):
    account_ids = list()
    try:
        iam.get_user()
    except Exception as e:
        # use the exception message to get the account ID the function executes under
        account_ids.append(re.search(r'(arn:aws:sts::)([0-9]+)', str(e)).groups()[1])

    delete_on = datetime.date.today().strftime('%Y-%m-%d')
    filters = [
        {'Name': 'tag:Backup', 'Values': [backup_name]},
        {'Name': 'tag:DeleteOn', 'Values': [delete_on]},
    ]
    snapshots = ec2.describe_snapshots(
        OwnerIds=account_ids,
        Filters=filters
    )

    for snapshot in snapshots['Snapshots']:
        print "Deleting snapshot %s" % snapshot['SnapshotId']
        ec2.delete_snapshot(SnapshotId=snapshot['SnapshotId'])
