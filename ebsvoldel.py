from datetime import datetime, timedelta, timezone
import boto3
ec2 = boto3.resource('ec2')
febsu={'name':'status','value': ['available']}
for each_vol in ec2.volumes.filter(Filter=febsu):
    print(each_vol.id, each_vol.state)
snapshots=ec2.volumes.filter(Filters=febsu)
print(volumes)
for each_vol in febsu:
    create_time=febsu.start_time
    delete_time=datetime.now(tz=timezone.utc) - timedelta(days=2)
    if delete_time > create_time:
        print('Volumes Creation time {}  and  Deletion time {}'.format(create_time, delete_time))
        febsu.delete()
        print('{} deleted'.format(volumes.each_vol.id))
    else:
        print('Your volume {} is not more than 2days old'.format(snapshot.snapshot_id))
