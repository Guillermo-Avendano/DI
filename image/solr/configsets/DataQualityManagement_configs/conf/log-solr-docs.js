function getTargetLogLevel() {
	//	logger.info('params: '+params);
//	logger.info('logLevel: '+params['logLevel']); // undefined
//	logger.info('logLevel params[0]: '+params[0]); // undefined
//	logger.info('params.logLevel: '+params.logLevel); // undefined
//	logger.info('params.length: '+params.length); // undefined
//	logger.info('logLevel: '+logLevel); // undefined
//	logger.info('typeof params: '+ (typeof params)); // params is an Object
//	logger.info('params.constructor: '+ params.constructor); // but its constructor is undefined
//	logger.info('Object.keys(params): '+Object.keys(params)); // this fails as params is not an Object! Strange!
//	logger.info('Object.getOwnPropertySymbols(params): '+Object.getOwnPropertySymbols(params)); // Object.getOwnPropertySymbols() does not exist as function in the Javascript implementation of Solr
//	logger.info('Object.getOwnPropertyNames(params): '+Object.getOwnPropertyNames(params)); // this fails as params is not an Object! Strange!
//	logger.info('Object.getOwnPropertyDescriptors(params): '+Object.getOwnPropertyDescriptors(params)); // Object.getOwnPropertyDescriptors() does not exist as function in the Javascript implementation of Solr
//	logger.info('Object.fromEntries(params): '+Object.fromEntries(params)); // Object.fromEntries() does not exist as function in the Javascript implementation of Solr
	
	
	var paramsAsString = params.toString();
	// CAUTION: params is NOT JSON format (separator is '=' in place of ':' and strings are not enclosed with '"')
	var parameters = parseParams(paramsAsString);
	var logLevel = parameters['logLevel'];
	//logger.info('logLevel: '+logLevel);
	
//	logger.info('logger.getLevel(): '+logger.getLevel()); // Logger.getLevel() is undefined
//	logger.info('Level.toLevel(logLevel): '+Level.toLevel(logLevel)); // Level class is undefined
	return logLevel;
}

function logDoc(logLevel, doc, prefix, suffix) {
	if (isLogLevelEnabled(logLevel)) {
		var fieldNames = doc.getFieldNames()
		var jDoc={};
		for (var namesIter = fieldNames.iterator(); namesIter.hasNext();) {
			var fieldName = namesIter.next();
			jDoc[fieldName] = []
			var fieldValues = doc.getFieldValues(fieldName)
			for (var valIter = fieldValues.iterator(); valIter.hasNext();) {
				fieldValue = valIter.next();
				jDoc[fieldName].push(String(fieldValue.toString()))
			}
		}
		log(logLevel, (prefix ? prefix :"") + JSON.stringify(jDoc) + (suffix ? suffix : ""));
	}
}

/////////////////////////////
// Utility functions
/////////////////////////////

/**
 * functions supported by provided Logger object are very limited (not all methods of org.apache.logging.log4j.Logger are implemented)
 */
function isLogLevelEnabled(logLevelAsString) {
	switch(logLevelAsString.toUpperCase()) {
		case 'ALL':
			return true;
		case 'TRACE':
			return logger.isTraceEnabled();
		case 'DEBUG':
			return logger.isDebugEnabled();
		case 'INFO':
			return logger.isInfoEnabled();
		case 'WARN':
			return logger.isWarnEnabled();
		case 'ERROR':
			return logger.isErrorEnabled();
		case 'FATAL':
			return logger.isFatalEnabled();
		case 'OFF':
		default:
			return false;
	}
}

/**
 * functions supported by provided Logger object are very limited (not all methods of org.apache.logging.log4j.Logger are implemented)
 */
function log(logLevelAsString, msg) {
	switch(logLevelAsString.toUpperCase()) {
		case 'ALL':
		case 'TRACE':
			return logger.trace(msg);
		case 'DEBUG':
			return logger.debug(msg);
		case 'INFO':
			return logger.info(msg);
		case 'WARN':
			return logger.warn(msg);
		case 'ERROR':
			return logger.error(msg);
		case 'FATAL':
			return logger.fatal(msg);
		default:
			return;
	}
}

/**
 * CAUTION: implementation is NOT robust as it will neither manage arrays nor values that are themselves objects (or arrays)
 */
function parseParams(paramsAsString) {
	var params = {};
	if (paramsAsString.trim().startsWith('{') && paramsAsString.trim().endsWith('}')) {
		paramsAsString = paramsAsString.trim().substring(1, paramsAsString.length-1);
	}
	var paramElements = paramsAsString.split(',');
	for (var i = 0; i < paramElements.length; i++) {
		var keyValue = parseKeyValue(paramElements[i]);
		params[keyValue.key] = keyValue.value;
	}
	return params;
}

/**
 * CAUTION: implementation is NOT robust as it will neither manage arrays nor values that are themselves objects (or arrays)
 */
function parseKeyValue(keyValueAsString) {
	var keyValue = {};
	var index = keyValueAsString.indexOf('=');
	keyValue['key'] = index>=0 ? keyValueAsString.substring(0, index) : keyValueAsString;
	keyValue['value'] = index>=0 && index<keyValueAsString.length ? keyValueAsString.substring(index+1, keyValueAsString.length) : null;
	if (keyValue['value'].trim().startsWith('{') && keyValue['value'].trim().endsWith('}')) {
		keyValue['value'] = parseParams(keyValue['value'].trim());
	}
	return keyValue;
}

/////////////////////////////
// Standard functions that all processors of updateRequestProcessorChain must implement (see https://solr.apache.org/docs/6_6_0/solr-core/org/apache/solr/update/processor/UpdateRequestProcessor.html)
/////////////////////////////
var header = "UPDATE CHAIN - ";
function processAdd(cmd) {
	doc = cmd.solrDoc;  // org.apache.solr.common.SolrInputDocument
	commitWithin = cmd.commitWithin;
	isLastDocInBatch = cmd.isLastDocInBatch;
	overwrite  = cmd.overwrite;
	pollQueueTime = cmd.pollQueueTime;
	prevVersion = cmd.prevVersion;
	updateTerm  = cmd.updateTerm;
	var logLevel = getTargetLogLevel();
	logDoc(logLevel, doc, header+"Adding doc:\n", "\n"+"isLastDocInBatch="+isLastDocInBatch+", commitWithin="+commitWithin+", overwrite="+overwrite+", pollQueueTime="+pollQueueTime+", prevVersion="+prevVersion+", updateTerm="+updateTerm);
}
function processDelete(cmd) {
	commitWithin = cmd.commitWithin;
	id = cmd.id;
	indexedId  = cmd.indexedId;
	query  = cmd.query;
	var logLevel = getTargetLogLevel();
	log(logLevel, header+"Deleting doc - "+"id="+id+", indexedId="+indexedId+", commitWithin="+commitWithin+", query="+query);
}
function processMergeIndexes(cmd) {
	readers = cmd.readers;
	var readersAsString = '{';
	for (var i=0; i<readers.length; i++) {
		readersAsString += readers.get(i);
		if (i+1<readers.length) {
			readersAsString += ', '
		}
	}
	readersAsString += '}';
	var logLevel = getTargetLogLevel();
	log(logLevel, header+"Merging indexes - "+"readers=");
}
function processCommit(cmd) {
	expungeDeletes  = cmd.expungeDeletes;
	maxOptimizeSegments = cmd.maxOptimizeSegments;
	openSearcher  = cmd.openSearcher;
	optimize = cmd.optimize;
	prepareCommit = cmd.prepareCommit;
	softCommit = cmd.softCommit;
	waitSearcher = cmd.waitSearcher;
	var logLevel = getTargetLogLevel();
	log(logLevel, header+"Committing - "+"expungeDeletes="+expungeDeletes+", maxOptimizeSegments="+maxOptimizeSegments+", openSearcher="+openSearcher+", optimize="+optimize+", prepareCommit="+prepareCommit+", softCommit="+softCommit+", waitSearcher="+waitSearcher);
}
function processRollback(cmd) {
	var logLevel = getTargetLogLevel();
	log(logLevel, header+"Rollbacking");
}
function finish() {
	var logLevel = getTargetLogLevel();
	log(logLevel, header+"Finished");
}
