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
import xtext.pycom.FunctionDefinitions
import xtext.pycom.ParameterString
import xtext.pycom.ParameterInt
import xtext.pycom.ParameterPin
import xtext.pycom.ParameterBoolean

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class PycomGenerator extends AbstractGenerator {
	
	var HashMap<String, String> importcode
	var HashMap<String, String> codeMap
	
	var HashMap<String, String> logicmap
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		
		for (board : resource.allContents.toIterable.filter(typeof(Board))) {
			fsa.generateFile(board.name + ".py", generatePycomFiles(board, resource))			
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
	
	def generatePycomFiles(Board b, Resource r) {
		generatePycom(b)
		var functions = generateFunctions(b, r)
		'''
		import pycom
		import urequests
		import machine
		import time 
		
		�generatePycomImports�
		�generateImports(b)�
		isRunning = True
		pycom.heartbeat(False)
			
		�generatePycomCode()�
		
		#External Functions	
		�generateExternalFunctions(b)�
		
		#Main Code
		while(isRunning):
			�functions�
		#CODE GENERATION END
		'''
	}
	
	def generatePycomImports() { 
		val sb = new StringBuilder();
		importcode.forEach[k, v| {
			sb.append(v + "\n")
		}]
		return sb.toString
	}
	
	def generatePycomCode() { 
		val sb = new StringBuilder();
		sb.append("\n")
		codeMap.forEach[k, v| {
			sb.append(v + "\n")
		}]
		return sb.toString
	}
	
	def generateLogic() {
		val sb = new StringBuilder();
		sb.append("\n")
		logicmap.forEach[k, v| {
			sb.append(v + "\n")
		}]
		return sb.toString
	}
	
	def generatePycom(Board b) {
		importcode = new HashMap<String, String>();
		codeMap = new HashMap<String, String>();
		logicmap = new HashMap<String, String>();
		generatePycomActuator(b)
		generatePycomSensor(b)
		generateFunctionImports(b)
		generateExternalFunctions(b)
	}
	
	def generatePycomActuator(Board b) {
		for (actuator : b.hardware.boardMembers.filter(typeof(Actuator))) {
			for (actuatortype : actuator.actuatorTypes.filter(typeof(ModuleType))) {
				if (!importcode.containsKey(actuatortype.typeName)) {
					var import = generateModuleImport(actuatortype)
					var code = generateModuleCode(actuatortype)
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
	
	def generatePycomSensor(Board b) {
		for (sensor : b.hardware.boardMembers.filter(typeof(Sensor))) {
			for (sensortype : sensor.sensorTypes.filter(typeof(ModuleType))) {
				if (!importcode.containsKey(sensortype.typeName)) {
					var import = generateModuleImport(sensortype)
					var code = generateModuleCode(sensortype)
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
	
	def String generateModuleImport(ModuleType type) {			
		if(type.filename !== null && !type.filename.name.empty) {
			return '''from �type.filename.name� import �type.filename.name� '''	
		}
		return null;		
	}
	
	def String generateModuleCode(ModuleType type) {
		if(type.filename !== null && !type.filename.name.empty) {
			return '''�type.name� = �type.filename.name�()'''
		} else {
			return null
		}
	}
	
	def generateFunctionImports(Board board) {
		var hardware = board.hardware
		for (function : hardware.function.functiondef) {
			var filename = function.externalFunction.filename.name
			if(!importcode.containsKey("externalfile" + filename)) {
				importcode.put("externalfile" + filename, '''import �filename�''')
			}
			
		}
	}

	def generateExternalFunctions(Board board) {
		var sb = new StringBuilder()	
		var str = ""	
		for(function : board.hardware.function.functiondef) {
			var paramStringBuilder = new StringBuilder()
			for (param : function.parameters) {
				paramStringBuilder.append(param.value  + ', ')				
			}
			if(!paramStringBuilder.toString.nullOrEmpty) {
				str = paramStringBuilder.toString.substring(0, (paramStringBuilder.length - 2))
			}
			var String returnstatement = ""
			if(!function.externalFunction.returnType.equalsIgnoreCase("Nothing")) {
				returnstatement = "return "
			}
			
			sb.append('''
			def �function.name�(�str�):
				�returnstatement��function.externalFunction.filename.name�.�genExternalFunctionCall(function)�
			''')
			sb.append("\n")
		}
		return sb.toString
	}
	
	def genExternalFunctionCall(FunctionDefinitions function) {
		var sb = new StringBuilder()
		var paramStringBuilder = new StringBuilder()
		var str = ""
		for (param : function.parameters) {
			paramStringBuilder.append(param.value + ', ')
		}
		if(!paramStringBuilder.toString.nullOrEmpty) {
			str = paramStringBuilder.toString.substring(0, paramStringBuilder.length - 2)
		}
		sb.append('''
		�function.externalFunction.name�(�str�)
		''')
		return sb.toString
	}
	
	def generateImports(Board b) {
		var sb = new StringBuilder()
		for (imp : b.hardware.imports) {
			for (impfiles : imp.importfiles) {
				sb.append('''from �impfiles.name� import �impfiles.name�''')
				sb.append("\n")
			}
		}
	}
	
	
	
	def generateFunctions(Board board, Resource resource) {
		val sb = new StringBuilder();
		for (exp : board.exps) {
			if(exp instanceof ConditionalAction) {
				sb.append(genInternalConditionalAction(exp, board, 0))
			} else if (exp instanceof FunctionCall) {
				sb.append(genInternalFunction(exp))
			}
			sb.append("\n")	
		}
		for (server : resource.allContents.toIterable.filter(typeof(Server))) {
			for (condaction : server.exps) {
				genConditionalAction(board, condaction, server)
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
	
	def String genInternalConditionalAction(ConditionalAction action, Board board, int depth) {
		var exp = genPycomCondition(action.condition)
		var s = '''
		�genDepth(depth)�if �exp�:
		�genInternalConditionBody(action, board, depth+1)�
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
	
	def genInternalConditionBody(ConditionalAction action, Board board, int depth) {
		var sb = new StringBuilder()
		for (exp : action.expMembers) {
			if(exp instanceof ConditionalAction) {
				sb.append(genInternalConditionalAction(exp, board, depth))
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
			if(param instanceof ParameterInt) {
				sb.append(param.value + ', ')
			} else if (param instanceof ParameterString) {
				sb.append(param.value + ', ')
			} else if (param instanceof ParameterPin) {
				sb.append(param.value + ', ')
			} else if (param instanceof ParameterBoolean) {
				sb.append(param.value + ', ')
			}
		}
		if(!sb.toString.nullOrEmpty) {
			var str = sb.toString.substring(0, sb.length - 2)
			return '''�call.function.name�(�str�)'''
		}
		return '''�call.function.name�()'''
	}
	
	def void genConditionalAction(Board board, ConditionalAction conAction, Server server) {
		genCondition(board, conAction.condition, server)
		for (exp : conAction.expMembers) {
			if(exp instanceof ConditionalAction) {
				genConditionalAction(board, exp, server)
			} else if(exp instanceof FunctionCall) {
				genFunction(board, exp, server)
			}
		}
	}
	
	def void genCondition(Board board, Condition condition, Server server) {
		
		 if(condition.nestedCondition !== null) {
			genCondition(board, condition.nestedCondition, server)
		}
		if(condition.logicEx.compExp !== null) {
			if(condition.logicEx.compExp.left.outputfunction !== null) {
				if (condition.logicEx.compExp.left.outputfunction.board.equals(board)) {
					var func = condition.logicEx.compExp.left.outputfunction
					var op = condition.logicEx.compExp.op
					if(condition.logicEx.compExp.right.outputfunction === null) {
						var thresholdvalue = condition.logicEx.compExp.right.outputValue
						generateThresholdFunction(board, func, thresholdvalue, op, server)
					} else if (condition.logicEx.compExp.right.outputfunction.board.equals(board)) {
						var thresholdfunc = condition.logicEx.compExp.right.outputfunction
						generateDoubleFunction(board, func, thresholdfunc, op, server)
					} else {
						generateNoLimitFunction(board, func, server)
					}
				}
			}
			if(condition.logicEx.compExp.right.outputfunction !== null) {
				if (condition.logicEx.compExp.right.outputfunction.board.equals(board)) {
					var func = condition.logicEx.compExp.right.outputfunction
					var op = condition.logicEx.compExp.op
					if(condition.logicEx.compExp.left.outputfunction === null) {
						var thresholdvalue = condition.logicEx.compExp.left.outputValue
						generateThresholdFunction(board, func, thresholdvalue, op, server)
					} else if (condition.logicEx.compExp.left.outputfunction.board.equals(board)) {
						var thresholdfunc = condition.logicEx.compExp.left.outputfunction
						generateDoubleFunction(board, func, thresholdfunc, op, server)
					} else {
						generateNoLimitFunction(board, func, server)
					}
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
	
	def generateThresholdFunction(Board board, FunctionCall function, int i, String op, Server server) {	
		
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
		
		logicmap.put(function.function.name + op + i, threshold)
	}
	
	def generateDoubleFunction(Board board, FunctionCall function, FunctionCall function2, String op, Server server) {
		var possibleKey1 = function.function.name + op + function2.function.name
		var possibleKey2 = function2.function.name + op + function.function.name
		if(!(logicmap.containsKey(possibleKey1) || logicmap.containsKey(possibleKey2))) {
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
				sendurl = "�getServerAddress(server.conn)��postaddress�".format(False)
				res = urequests.post(sendurl)   
				print("Res code: ", res.status_code)
				print("Res: ", res.reason)
			'''
	
			logicmap.put(function.function.name + op + function2.function.name, transmitcode)
		}
		
	}
	
	def generateNoLimitFunction(Board board, FunctionCall function, Server server) {
		var postaddress = getPostAddress(board, function)
		var functioncall = genInternalFunction(function)
		var noLimitCode = '''
		�function.function.name�Value = �functioncall�
		passedTreshold = not passedTreshold
		sendurl = "�getServerAddress(server.conn)��postaddress�".format(�function.function.name�Value)
		res = urequests.post(sendurl)   
		print("Res code: ", res.status_code)
		print("Res: ", res.reason)
		'''				
		logicmap.put(function.function.name, noLimitCode)
	}
	
	def genFunction(Board board, FunctionCall functioncall, Server server) {
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
	
//	SEVER CODE BELOW
	
	var HashMap<String, String>  globalVariables
	var HashMap<String, String>  variableNamesForPostAndGetRoutes
	
	def GenerateServerHeader(Server s) {
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
	
	def generateServerFiles(Server s, Resource r) {					
		var stringBuilder = new StringBuilder;
		var postbuilder = new StringBuilder;
		var getbuilder = new StringBuilder;
		stringBuilder.append(GenerateServerHeader(s))			
		stringBuilder.append(GenerateGlobalVariables(s))
		GeneratePostRoutes(postbuilder, getbuilder, r, s)
		stringBuilder.append("\n")
		stringBuilder.append(postbuilder.toString)
		stringBuilder.append("\n")
		stringBuilder.append(getbuilder.toString)
		var counter = 0;
		for(ConditionalAction conditionalAction : s.exps)
		{
			var type = conditionalAction.type;			
			GenerateIfFunctions(stringBuilder, conditionalAction, r, type, s, counter)
			counter++;	
		}
		
		return stringBuilder.toString;
	}
	
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
		var String varname = exp.board.name + "_" + exp.function.name
		if(!globalVariables.containsKey(varname)) {
			globalVariables.put(varname, varname + " = undefined" + "\n")
			variableNamesForPostAndGetRoutes.put(varname,"Function")
		}															
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
	
	def GeneratePostRoutes(StringBuilder postbuilder, StringBuilder getbuilder, Resource r, Server s) {			
		variableNamesForPostAndGetRoutes.forEach[k, v| {
			var numberList = new ArrayList<String>
			for(var i = 0; i < s.exps.filter(typeof(ConditionalAction)).size; i++) {
					numberList.add(i.toString)
			}
			var String snippet = k.replace("_", "/");
			postbuilder.append(						
				'''							
				app.post('/�snippet�/:value', function(req, res)	{
				    �k� = req.params.value; 
				    �FOR number : numberList�							    	
				    	ServerFunction�number�();
				    �ENDFOR�
					res.send("Message received: " + �k�);
					console.log("Message received: " + �k�)
				});	
				''')				
				getbuilder.append(				
					'''							
					app.get('/�snippet�', function(req, res) {
						if(�k� == undefined) {
							res.send("undefined");
						} else {
							res.send(�k�);
						}
						console.log("Return �k�: " + �k�)
					});
					''')
		}]
	}
	
	def GenerateIfFunctions(StringBuilder stringBuilder, ConditionalAction conditionalAction, Resource r, String type, Server s, int counter)
	{
		
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
																	
	}
	
	def GetConditionalStatementScopeContent(List<ExpMember> content) {
		val scopeContentBuilder = new StringBuilder();		
		
		for (exp : content) {
			if(exp instanceof ConditionalAction) {
				var tempBuilder = new StringBuilder();
				var text = GetConditionalStatementContent(tempBuilder, exp.condition)
				scopeContentBuilder.append(exp.type + "(" + text + ")\n")				
				
				if(exp.expMembers.size > 0)	{
					scopeContentBuilder.append("{\n" + GetConditionalStatementScopeContent(exp.expMembers) + "}\n")
				}
			} else if(exp instanceof FunctionCall) {
				var out = exp.board.name + "_" + exp.function.name + "_" + "setmethod"						
				scopeContentBuilder.append("\t" + out + " = true\n");																			
			}
		}
		return scopeContentBuilder.toString;
	}
	
	def GetConditionalStatementContent(StringBuilder stringBuilder, Condition condition) {															
		if(condition.logicEx.compExp.left.outputfunction != null) {		
			val String boardName = condition.logicEx.compExp.left.outputfunction.board.name;
			val String functionName = condition.logicEx.compExp.left.outputfunction.function.name;	
			variableNamesForPostAndGetRoutes.forEach[k, v| {
				if(k.contains(boardName) && k.contains(functionName))
					stringBuilder.append(k);
			}]								
		}	
		else {
			stringBuilder.append(String.valueOf(condition.logicEx.compExp.left.outputValue));
		}
		
		var operator = condition.logicEx.compExp.op;
		stringBuilder.append(" " + operator + " ")
		
		if(condition.logicEx.compExp.right.outputfunction != null) {
			val String boardName = condition.logicEx.compExp.left.outputfunction.board.name;
			val String functionName = condition.logicEx.compExp.left.outputfunction.function.name;	
					
			variableNamesForPostAndGetRoutes.forEach[k, v| {
				if(k.contains(boardName) && k.contains(functionName))
					stringBuilder.append(k);
			}]	
		}
		else {
			stringBuilder.append(String.valueOf(condition.logicEx.compExp.right.outputValue));
		}				
		
		if(condition.operator !== null) {
			stringBuilder.append(" " + condition.operator + " ");
		}	
		
		if(condition.nestedCondition != null) {
			GetConditionalStatementContent(stringBuilder, condition.nestedCondition)
		}	
		
		return stringBuilder.toString;
	}
}