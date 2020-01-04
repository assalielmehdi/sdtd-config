##importing libraries
##Incase libraries in not installed you can use ‘pip install influxdb’, ‘pip install Cassandra-driver’ and so.
from cassandra.cluster import Cluster
from cassandra import ConsistencyLevel
from cassandra.query import SimpleStatement
import datetime
import time
import requests
import json
from influxdb import InfluxDBClient
import rfc3339
import time

#put the IP of cassandra host if it is not localhost
cluster = Cluster(['my-cassandra'])
#replace dummy_database with your Keyspace Name
session = cluster.connect('sdtd')

client = InfluxDBClient(host='my-influxdb', port=8086, database='sdtd')
client.create_database('sdtd')
while 1:
	query = "SELECT country, count(*) FROM twitter GROUP BY country"
	rows = session.execute(query)
	client.delete_series("sdtd","twitter")
	for row in rows:
	    json_body = [ { "measurement": "twitter", "fields": { "country": row.country, "count": row.count, } }]
		client.write_points(json_body)
	time.sleep(5)
