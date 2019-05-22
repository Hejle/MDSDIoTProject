/*
 * generated by Xtext 2.16.0
 */
package xtext.generator

import java.util.ArrayList
import java.util.HashMap
import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import xtext.pycom.Actuator
import xtext.pycom.Board
import xtext.pycom.ComparisonExp
import xtext.pycom.Condition
import xtext.pycom.ConditionalAction
import xtext.pycom.Connection
import xtext.pycom.ExpMember
import xtext.pycom.FunctionCall
import xtext.pycom.ModuleType
import xtext.pycom.Sensor
import xtext.pycom.Server

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class PycomGenerator extends AbstractGenerator {
	
	//var externalFilesMap = new HashMap<String, URL>();
	//var moduleMap = new HashMap<String, String>();
	
	/*if(externalFilesMap.containsKey(k)) {
				try {
					var url = externalFilesMap.get(k)
					var filename = Paths.get(url.toURI.getPath()).getFileName().toString()
					fsa.generateFile(filename, new BufferedInputStream(url.openStream()))
				} catch (IOException e) {
					//Handle Download Exception Errors :)
					e.printStackTrace()
				}
			} */
	
	var HashMap<String, String> importcode
	var HashMap<String, String> codeMap
	
	var HashMap<String, String> logicmap
	var HashMap<String, String> functionmap
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		
		for (board : resource.allContents.toIterable.filter(typeof(Board))) {
			fsa.generateFile(board.name + ".py", generatePycomFiles(board, resource, fsa))			
		}
				
		for (server : resource.allContents.toIterable.filter(typeof(Server))) {
			fsa.generateFile(server.name + ".js", generateServerFiles(server, resource))			
		} 			
	}
	
	def genDepth(int depth) {
		return stringMultiply("\t", depth)
	}
	
	def stringMultiply(String s, int n){
    	var sb = new StringBuilder()
    	for(var i = 0; i < n; i++) {
       		sb.append(s);
    	}
    	return sb.toString();
	}
	
	def oppositeOP(String op) {
		if(op.equals("<")) {
			return ">"
		}
		if(op.equals(">")) {
			return "<"
		}
		if(op.equals("<=")) {
			return ">"
		}
		if(op.equals(">=")) {
			return "<"
		}
		if(op.equals("==")) {
			return "!="
		}
		if(op.equals("!=")) {
			return "=="
		}	
	}
	
	def operatorToPython(String op) {
		if(op.equals("||")) {
			return "or"
		}
		if(op.equals("&&")) {
			return "and"
		}
		return op
	}
	
	//def populateHashmap() {
	//	externalFilesMap.put("Temperature", new URL("https://raw.githubusercontent.com/pycom/pycom-libraries/master/pysense/lib/SI7006A20.py"))
	//	moduleMap.put("Temperature", "SI7006A20")
	//}
	
	//  ��
	// EzCopy
	// Single Line Generate Comment �/* Comment goes here */�
	// Debug Code
	// JOptionPane.showMessageDialog( null , "Message", "Title" , JOptionPane.INFORMATION_MESSAGE)
	
	def generatePycomFiles(Board b, Resource r, IFileSystemAccess2 fsa) {
		generatePycom(b, r)
		'''
		import pycom
		import urequests
		import machine
		import time 
		#New code
		�generatePycomImports(b, r, fsa)�
		�generateImports(b, r)�
		isRunning = True
		pycom.heartbeat(False)
			
		�generatePycomCode(b, r)�
			
		�genFunctions(b, r)�
		while(isRunning):
			�generateFunctions(b, r)�
		#CODE GENERATION END
		'''
	}
	
	def generatePycomImports(Board b, Resource r, IFileSystemAccess2 fsa) { 
		val sb = new StringBuilder();
		importcode.forEach[k, v| {
			sb.append(v + "\n")
		}]
		return sb.toString
	}
	
	def generatePycomCode(Board b, Resource r) { 
		val sb = new StringBuilder();
		sb.append("\n")
		codeMap.forEach[k, v| {
			sb.append(v + "\n")
		}]
		return sb.toString
	}
	
	def generateLogic(Board board, Resource resource) {
		val sb = new StringBuilder();
		sb.append("\n")
		logicmap.forEach[k, v| {
			sb.append(v + "\n")
		}]
		return sb.toString
	}
	
	def genFunctions(Board board, Resource resource) {
		val sb = new StringBuilder();
		sb.append("\n")
		functionmap.forEach[k, v| {
			sb.append(v + "\n")
		}]
		return sb.toString
	}
	
	def generatePycom(Board b, Resource r) {
		importcode = new HashMap<String, String>();
		codeMap = new HashMap<String, String>();
		logicmap = new HashMap<String, String>();
		functionmap = new HashMap<String, String>();
		generatePycomActuator(b, r)
		generatePycomSensor(b, r)
		//generateFunctions(b, r)
	}
	
	def generateFunctions(Board board, Resource resource) {
		val sb = new StringBuilder();
		for (exp : board.exps) {
			if(exp instanceof ConditionalAction) {
				sb.append(genInternalConditionalAction(exp, board, resource, 0))
			} else if (exp instanceof FunctionCall) {
				sb.append(genInternalFunction(exp))
			}
			sb.append("\n")	
		}
		for (server : resource.allContents.toIterable.filter(typeof(Server))) {
			for (condaction : server.exps) {
				genConditionalAction(board, resource, condaction, server)
			} 				
		} 	
		val stringBuilder = new StringBuilder();
		stringBuilder.append("\n")
		logicmap.forEach[k, v| {
			stringBuilder.append(v + "\n")
		}]
		stringBuilder.append("\n")
		sb.append(stringBuilder.toString)
		return sb.toString()	
	}
	
	def String genInternalConditionalAction(ConditionalAction action, Board board, Resource resource, int depth) {
		var exp = genPycomCondition(action.condition)
		var s = '''
		�genDepth(depth)�if �exp�:
		�genInternalConditionBody(action, board, resource, depth+1)�
		'''
		return s
	}
	
	def String genPycomCondition(Condition condition) {
		var sb = new StringBuilder()
		if (condition.logicEx.boolVal !== null) {
			sb.append(condition.logicEx.boolVal.value)
		} else {
			var compa = condition.logicEx.compExp				
			sb.append(getLeftCompExp(compa) + " " + compa.op + " " + getRightCompExp(compa))
		}
		if(condition.nestedCondition !== null) {
			sb.append(" ")
			sb.append(operatorToPython(condition.operator))
			sb.append(" ")
			return sb.append(genPycomCondition(condition.nestedCondition)).toString
		} else {
			return sb.toString
		}
	}
	
	def genInternalConditionBody(ConditionalAction action, Board board, Resource resource, int depth) {
		var sb = new StringBuilder()
		for (exp : action.expMembers) {
			if(exp instanceof ConditionalAction) {
				sb.append(genInternalConditionalAction(exp, board, resource, depth))
			} else if(exp instanceof FunctionCall) {
				sb.append(genDepth(depth) + genInternalFunction(exp))
			}
			sb.append("\n")
		}
		return sb.toString
	}
	
	def getLeftCompExp(ComparisonExp exp) {
		if(exp.left.outputfunction !== null) {
			return genInternalFunction(exp.left.outputfunction)
		} else {
			return exp.left.outputValue.toString
		}
	}
	
	def getRightCompExp(ComparisonExp exp) {
		if(exp.right.outputfunction !== null) {
			return genInternalFunction(exp.right.outputfunction)
		} else {
			return exp.right.outputValue.toString
		}
	}
	
	
	def genInternalFunction(FunctionCall call) {
		var sb = new StringBuilder()
		for	(param : call.parameters) {
			if (param.name !== null && !param.name.isEmpty) {
				sb.append(param.name + ', ')
			} else {
				sb.append(param.value + ', ')
			}
		}
		if(sb.toString !== null && !sb.toString.empty) {
			var str = sb.toString.substring(0, sb.length - 2)
			return '''�call.function.name�(�str�)'''
		}
		return '''�call.function.name�()'''
	}
	
	def void genConditionalAction(Board board, Resource resource, ConditionalAction conAction, Server server) {
		genCondition(board, resource, conAction.condition, server)
		for (exp : conAction.expMembers) {
			if(exp instanceof ConditionalAction) {
				genConditionalAction(board, resource, exp, server)
			} else if(exp instanceof FunctionCall) {
				genFunction(board, resource, exp, server)
			}
		}
	}
	
	def void genCondition(Board board, Resource resource, Condition condition, Server server) {
		
		 if(condition.nestedCondition !== null) {
			genCondition(board, resource, condition.nestedCondition, server)
		}
		if(condition.logicEx.compExp.left.outputfunction !== null) {
			if (condition.logicEx.compExp.left.outputfunction.board.equals(board)) {
				var func = condition.logicEx.compExp.left.outputfunction
				var op = condition.logicEx.compExp.op
				if(condition.logicEx.compExp.right.outputfunction === null) {
					var thresholdvalue = condition.logicEx.compExp.right.outputValue
					generateThresholdFunction(board, resource, func, thresholdvalue, op, server)
				} else if (condition.logicEx.compExp.right.outputfunction.board.equals(board)) {
					var thresholdfunc = condition.logicEx.compExp.right.outputfunction
					generateDoubleFunction(board, resource, func, thresholdfunc, op, server)
				}
			}
		}
		if(condition.logicEx.compExp.right.outputfunction !== null) {
			if (condition.logicEx.compExp.right.outputfunction.board.equals(board)) {
				var func = condition.logicEx.compExp.right.outputfunction
				var op = condition.logicEx.compExp.op
				if(condition.logicEx.compExp.left.outputfunction === null) {
					var thresholdvalue = condition.logicEx.compExp.left.outputValue
					generateThresholdFunction(board, resource, func, thresholdvalue, op, server)
				} else if (condition.logicEx.compExp.left.outputfunction.board.equals(board)) {
					var thresholdfunc = condition.logicEx.compExp.left.outputfunction
					generateDoubleFunction(board, resource, func, thresholdfunc, op, server)
				}
			}
		}
		
	}
	
	def getServerAddress(Connection conn) {
		var String adress
		if(!conn.host.ipAdr.isNullOrEmpty) {
			adress = conn.host.ipAdr
		} else if ((!conn.host.website.isNullOrEmpty)) {
			adress = conn.host.website
		} else {
			adress = "#Undefined Address"
		}
		adress = adress + ":" + conn.portnumber
		return adress
	}
	
	def getPostAddress(Board board, FunctionCall function) {
		return '''/�board.name�/�function.function.name�/float/{}'''
	}
	
	def generateThresholdFunction(Board board, Resource resource, FunctionCall function, int i, String op, Server server) {	
		
		var postaddress = getPostAddress(board, function)
		var functioncall = genInternalFunction(function)
		var threshold = '''
		passedTreshold = False
		�function.function.name�Threshold = �i�
		�function.function.name�Value = �functioncall�
		if (�function.function.name�Value �op� �function.function.name�Threshold and not passedTreshold):
			passedTreshold = not passedTreshold
			sendurl = "�getServerAddress(server.conn)��postaddress�".format(�function.function.name�Value)
			res = urequests.post(sendurl)   
			print("Res code: ", res.status_code)
			print("Res: ", res.reason)
		if (�function.function.name�Value �oppositeOP(op)� �function.function.name�Threshold and passedTreshold):
			passedTreshold = not passedTreshold
			sendurl = "�getServerAddress(server.conn)��postaddress�".format(�function.function.name�Value)
			res = urequests.post(sendurl)   
			print("Res code: ", res.status_code)
			print("Res: ", res.reason)
		'''				
		
		logicmap.put(function.function.name, threshold)
	}
	
	def generateDoubleFunction(Board board, Resource resource, FunctionCall function, FunctionCall function2, String op, Server server) {
		var postaddress = getPostAddress(board, function)
		var transmitcode = '''
		�function.function.name�Value = �function.function.name�()
		�function2.function.name�Value = �function2.function.name�()
		if (�function.function.name�Value �op� �function2.function.name�Value):
			sendurl = "�getServerAddress(server.conn)��postaddress�".format(True)
			res = urequests.post(sendurl)   
			print("Res code: ", res.status_code)
			print("Res: ", res.reason)
		if (�function.function.name�Value �oppositeOP(op)� �function2.function.name�Value):
			sendurl = "�getServerAddress(server.conn)��postaddress�".format(false)
			res = urequests.post(sendurl)   
			print("Res code: ", res.status_code)
			print("Res: ", res.reason)
		'''

		logicmap.put(function.function.name, transmitcode)
	}
	
	def genFunction(Board board, Resource resource, FunctionCall functioncall, Server server) {
		if(functioncall.board.equals(board)) {
			var address = getServerAddress(server.conn)
			var String sendUrl = '''sendurl = "�address�/�board.name�/�functioncall.function.name�/turnOn'''
			var getCode='''
			�sendUrl�
			urequests.get(sendurl) 
			    response = res.text
			    print('sending')
			    print("Res code: ", res.status_code)
			    print("Response: " + response)
			    �functioncall.function.name�(response)
			'''
			logicmap.put(functioncall.function.name, getCode)
		}
	}
	
	def generatePycomActuator(Board b, Resource r) {
		for (actuator : b.hardware.boardMembers.filter(typeof(Actuator))) {
			for (actuatortype : actuator.actuatorTypes.filter(typeof(ModuleType))) {
				if (!importcode.containsKey(actuatortype.typeName)) {
					var import = generateModuleImport(b, r, actuatortype)
					var code = generateModuleCode(b, r, actuatortype)
					if(import !== null) {
						importcode.put(actuatortype.typeName.name, import)
					}
					if (code !== null) {
						codeMap.put(actuatortype.name, code)
					}
				}
			}
		}
	}
	
	def generatePycomSensor(Board b, Resource r) {
		for (sensor : b.hardware.boardMembers.filter(typeof(Sensor))) {
			for (sensortype : sensor.sensorTypes.filter(typeof(ModuleType))) {
				if (!importcode.containsKey(sensortype.typeName)) {
					var import = generateModuleImport(b, r, sensortype)
					var code = generateModuleCode(b, r, sensortype)
					if(import !== null) {
						importcode.put(sensortype.typeName.name, import)
					}
					if (code !== null) {
						codeMap.put(sensortype.name, code)
					}
				}
			}
		}
	}
	
	def generateImports(Board b, Resource r) {
		var sb = new StringBuilder()
		for (imp : b.hardware.imports) {
			for (impfiles : imp.importfiles) {
				sb.append('''from �impfiles.name� import �impfiles.name�''')
				sb.append("\n")
			}
		}
	}
	
	def String generateModuleCode(Board board, Resource resource, ModuleType type) {
		if(type.filename !== null && !type.filename.name.empty) {
			return '''�type.name� = �type.filename.name�()'''
		} else {
			return null
		}
	}
	
	def String generateModuleImport(Board b, Resource r, ModuleType type) {			
		if(type.filename !== null && !type.filename.name.empty) {
			return '''from �type.filename.name� import �type.filename.name� '''	
		}
		return null;		
	}

	def generatePycomWifiCode(Board b, Resource r) {
		'''
			#***WIFI SETUP***
			wlan = WLAN(mode=WLAN.STA)
			nets = wlan.scan()
			ssidname = #***YOUR SSID***
			password = #***YOUR PASSWORD***
			
			if wlan.isconnected() == False:
			    for net in nets:
			        print(net.ssid)
			        if net.ssid == ssidname:
			            wlan.connect(net.ssid, auth=(net.sec, password), timeout=5000)
			            break
			
			while not wlan.isconnected():
			    machine.idle()
			print ('wlan connection succeeded!')
			print (wlan.ifconfig())
			
			#***WIFI SETUP END***
			
		'''
	}
	
	def GenerateServerHeader(Server s)
	{
		'''
		var express = require('express');
		var app = express();
		var bodyParser = require('body-parser');
		app.use(bodyParser.json());
		
		// Host: �if (s.conn.host.ipAdr === null) s.conn.host.website else s.conn.host.ipAdr �
		
		app.listen(�s.conn.portnumber�, () => 
		{
		    console.log('Started on port �s.conn.portnumber�');
		});
		
		app.get("/", function(req, res)
		{		     
		    res.send("Default get route");
		    console.log("Default get route");
		});		
						
		'''
	}
	
	def generateServerFiles(Server s, Resource r) 
	{					
		var stringBuilder = new StringBuilder;		
		stringBuilder.append(GenerateServerHeader(s))			
		stringBuilder.append(GenerateGlobalVariables(s))
		GeneratePostRoutes(stringBuilder, r, s)
		
		var counter = 0;
		for(ConditionalAction conditionalAction : s.exps)
		{
			var type = conditionalAction.type;			
			GenerateIfFunctions(stringBuilder, conditionalAction, r, type, s, counter)
			counter++;	
		}
		
		return stringBuilder.toString;
	}
	
	var HashMap<String, String>  globalVariables
	var HashMap<String, String>  variableNamesForPostAndGetRoutes
	
	def GenerateGlobalVariables(Server s) {
		val sb = new StringBuilder()
		globalVariables = new HashMap<String, String>
		variableNamesForPostAndGetRoutes = new HashMap<String, String>
		for (exp : s.exps) 
		{
			generateVariableConditionalAction(s, exp)
		}
		globalVariables.forEach[k, v| {
			sb.append(v)
		}]
		
		sb.append("\n")
		return sb.toString
	}
	
	def void generateVariableConditionalAction(Server server, ConditionalAction action) {
		generateVariableFromCondition(action.condition)
		for(exp : action.expMembers) {
			if(exp instanceof ConditionalAction) 
			{
				generateVariableConditionalAction(server, exp)
			} 
			else if(exp instanceof FunctionCall) 
			{
				generateVariableFunction(exp)
			}
		}
	}
	
	def void generateVariableFunction(FunctionCall exp) {
		/* TODO
		var String varname;
			if(exp instanceof ModuleFunction) {
				if(exp.moduleType instanceof ActuatorType) {
					varname = exp.board.name + "_" + exp.moduleType.typeName + "_" + exp.moduleType.name + "_" + exp.functionName.name + "_" + "boolean"
				} else if (exp.moduleType instanceof SensorType) {
					varname = exp.board.name + "_" + exp.moduleType.typeName + "_" + exp.moduleType.name + "_" + exp.functionName.name + "_" + "float"
				} else {
					varname = exp.board.name + "_" + exp.moduleType.typeName + "_" + exp.moduleType.name + "_" + exp.functionName.name + "_" + "unknown"
				}
					
			} else {
				varname = exp.board.name + "_" + exp.functionName.name
			}
			if(!globalVariables.containsKey(varname)) {
				globalVariables.put(varname, varname + " = undefined" + "\n")
				if(exp instanceof ModuleFunction) {
					if (exp.moduleType instanceof SensorType) {
						variableNamesForPostAndGetRoutes.put(varname,"SensorFunction")
					} else if (exp.moduleType instanceof ActuatorType) {
						variableNamesForPostAndGetRoutes.put(varname,"ActuatorFunction")
					} else {
						variableNamesForPostAndGetRoutes.put(varname,"UnknownFunction")
					}
				} else {
					variableNamesForPostAndGetRoutes.put(varname,"Function")
				}
				
			}	
			*/													
	}
	
	def void generateVariableFromCondition(Condition condition) {
		if(condition.nestedCondition !== null) {
			generateVariableFromCondition(condition.nestedCondition)
		}
		if(condition.logicEx.compExp.left.outputfunction !== null) {
			generateVariableFunction(condition.logicEx.compExp.left.outputfunction)
		}
		if(condition.logicEx.compExp.right.outputfunction !== null) {
			generateVariableFunction(condition.logicEx.compExp.right.outputfunction)
		}
	}		
	
	def GeneratePostRoutes(StringBuilder stringBuilder, Resource r, Server s)
	{			
		variableNamesForPostAndGetRoutes.forEach[k, v| {
			if(v.equals("SensorFunction"))
			{
				var numberList = new ArrayList<String>
				for(var i = 0; i < s.exps.filter(typeof(ConditionalAction)).size; i++)
				{
					numberList.add(i.toString)
				}
				
				var String urlSnippet = k.replace("_", "/");
				stringBuilder.append(						
					'''							
					app.post('/�urlSnippet�/:value', function(req, res)
						{    					    
						    �k� = req.params.value; 
						    �FOR number : numberList�							    	
						    	ServerFunction�number�();
						    �ENDFOR�
						    								    
					    	res.send("Message received: " + �k�);
					    	console.log("Message received: " + �k�)    								    
						});	
															
					'''				
					)				
			}
			else if(v.equals("ActuatorFunction"))
			{
				var String urlSnippet = k.replace("_", "/");
				stringBuilder.append(						
						'''							
						app.get('/�urlSnippet�', function(req, res)
							{ 
								if(�k� == undefined)
								{
									res.send("undefined");
								} 
								else
								{  					    
							    	res.send(�k�);
							    }
						    	console.log("Return �k�: " + �k�)    								    
							});	
																
						'''				
						)		
			}
		}]
	}
	
	def GenerateIfFunctions(StringBuilder stringBuilder, ConditionalAction conditionalAction, Resource r, String type, Server s, int counter)
	{
		/*
		var conditionalStringBuilder = new StringBuilder();
		var content = GetConditionalStatementContent(conditionalStringBuilder, conditionalAction.condition);		
		var scopeContent = GetConditionalStatementScopeContent(conditionalAction.expMembers);								
		var splittedScopeContent = scopeContent.split("");	
		var elseScopeStringBuilder = new StringBuilder();	
		
		var index = 0;		
		for(String character : splittedScopeContent)
		{			
			if(character.equals("=") && splittedScopeContent.get(index-1).equals("!"))
			{
				elseScopeStringBuilder.deleteCharAt(index-1)
				elseScopeStringBuilder.append("==")
			}
			else if(character.equals("=") && splittedScopeContent.get(index-1).equals("="))
			{
				elseScopeStringBuilder.deleteCharAt(index-1)
				elseScopeStringBuilder.append("!=")
			}
			else if(character.equals("=") && splittedScopeContent.get(index-1).equals("<"))
			{
				elseScopeStringBuilder.deleteCharAt(index-1)
				elseScopeStringBuilder.append(">=")
			}
			else if(character.equals("=") && splittedScopeContent.get(index-1).equals(">"))
			{
				elseScopeStringBuilder.deleteCharAt(index-1)
				elseScopeStringBuilder.append("<=")
			}
			else if(character.equals("<"))
			{
				elseScopeStringBuilder.append(">")				
			}
			else if(character.equals(">"))
			{
				elseScopeStringBuilder.append("<")
			}
			else
			{
				elseScopeStringBuilder.append(character)
			}
											
			index++;
		}					
						
		stringBuilder.append(						
		'''										
			function ServerFunction�counter�()
			{    					    			    			    
			    �type�(�content�)
			    {  
			    	�scopeContent�				    	
			    }
			    else
			    {
			    	�elseScopeStringBuilder.toString.replace("= true", "= false")�					
				}
			}	
						
		'''				
		)		
		*/																
	}
	
	def GetConditionalStatementScopeContent(List<ExpMember> content) {
		/* TODO
		val scopeContentBuilder = new StringBuilder();		
		
		for (exp : content) 
		{
			if(exp instanceof ConditionalAction) 
			{
				var tempBuilder = new StringBuilder();
				var text = GetConditionalStatementContent(tempBuilder, exp.condition)
				scopeContentBuilder.append(exp.type + "(" + text + ")\n")				
				
				if(exp.expMembers.size > 0)
				{
					scopeContentBuilder.append("{\n" + GetConditionalStatementScopeContent(exp.expMembers) + "}\n")
				}
			} 
			else if(exp instanceof Function) 
			{				
				if(exp instanceof ModuleFunction) 
				{
					if(exp.moduleType instanceof ActuatorType) 
					{
						var out = exp.board.name + "_" + exp.moduleType.typeName + "_" + exp.moduleType.name + "_" + exp.functionName.name + "_" + "boolean"						
						scopeContentBuilder.append("\t" + out + " = true\n");
					} // Else: Do nothing - Should only contain global variables for actuators
				}																			
			}
		}
		
		return scopeContentBuilder.toString;
		*/
	}
	
	def GetConditionalStatementContent(StringBuilder stringBuilder, Condition condition)
	{		
		/*															
		if(condition.logicEx.compExp.left.outputfunction != null)
		{		
			val String boardName = condition.logicEx.compExp.left.outputfunction.board.name;
			val String functionName = condition.logicEx.compExp.left.outputfunction.functionName.name;	
					
			variableNamesForPostAndGetRoutes.forEach[k, v| {
				if(k.contains(boardName) && k.contains(functionName))
					stringBuilder.append(k);
			}]								
		}	
		else
		{
			stringBuilder.append(String.valueOf(condition.logicEx.compExp.left.outputValue));
		}
		
		var operator = condition.logicEx.compExp.op;
		stringBuilder.append(" " + operator + " ")
		
		if(condition.logicEx.compExp.right.outputfunction != null)
		{
			val String boardName = condition.logicEx.compExp.left.outputfunction.board.name;
			val String functionName = condition.logicEx.compExp.left.outputfunction.functionName.name;	
					
			variableNamesForPostAndGetRoutes.forEach[k, v| {
				if(k.contains(boardName) && k.contains(functionName))
					stringBuilder.append(k);
			}]	
		}
		else
		{
			stringBuilder.append(String.valueOf(condition.logicEx.compExp.right.outputValue));
		}				
		
		if(condition.operator != null)
		{
			stringBuilder.append(" " + condition.operator + " ");
		}	
		
		if(condition.nestedCondition != null)
		{
			GetConditionalStatementContent(stringBuilder, condition.nestedCondition)
		}	
		
		return stringBuilder.toString;
		*/
	}
	
	
	
}