const express = require('express')
const app = express()
const port = 9145
const METRIC_PREFIX = "aerospike_client"
const CLUSTER_NAME = "aerospike_cluster"
const NAMESPACE = "test"
const IP = "MY_IP"

var counts = {
	"write_timeouts":0,
	"write_errors":0,
	"read_timeouts":0,
	"read_errors":0
}

app.get('/metrics', (request, response) => {
	response.send(output())
})

app.listen(port, (err) => {
	if (err) {
		return console.log('something bad happened', err)
	}

	console.log(`server is listening on ${port}`)

})

var readline = require('readline');
var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

rl.on('line', parseLine)

// Line looks like this for writes only - 2020-05-10 06:17:13.460 write(count=566360 tps=5256 timeouts=0 errors=0)
// So doesn't work - note extra count field
function parseLine(line){
	line_elements=line.split(" ")
	if((line_elements.length > 2) && line_elements[2].startsWith("write")){
		counts["write_timeouts"] += parseInt(line_elements[3].split("=")[1])
		counts["write_errors"] += parseInt(line_elements[4].split("=")[1])
	}
	if((line_elements.length > 5) && line_elements[5].startsWith("read")){
		counts["read_timeouts"] += parseInt(line_elements[6].split("=")[1])
		counts["read_errors"] += parseInt(line_elements[7].split("=")[1])
	}
}

function output(){
	var messages = []
	for(var key in counts){
		messages.push(metricOutputFormatted(key.split("_")[0],key.split("_")[1],counts[key]))
	}
	return messages.join("\n")
}

function metricOutputFormatted(readOrWrite,countType,count){
	var metric = [METRIC_PREFIX,readOrWrite,countType].join("_") 
	var descriptiveHash = {"cluster_name":CLUSTER_NAME,"ns":NAMESPACE,"service":IP}
	var messages = [
		["# HELP",METRIC_PREFIX,readOrWrite,countType].join(" "),
		"# TYPE "+ metric + " counter",
		metric+descriptiveHashToString(descriptiveHash) +" "+count]
	return messages.join("\n")
}

function descriptiveHashToString(descriptiveHash){
	var elements = []
	for(var key in descriptiveHash){
		elements.push([key,quoteWrap(descriptiveHash[key])].join("="))
	}
	return "{"+elements.join(",")+"}"
}

function quoteWrap(string){
	return '"'+string+'"'
}
