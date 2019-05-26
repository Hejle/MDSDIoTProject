/*
 * generated by Xtext 2.16.0
 */
package xtext.validation

import org.eclipse.xtext.validation.Check
import java.util.HashSet
import xtext.pycom.PycomPackage
import xtext.pycom.FunctionCall
import org.eclipse.xtext.EcoreUtil2
import xtext.pycom.Connection
import java.util.regex.Pattern
import xtext.pycom.ParameterInt
import xtext.pycom.ParameterName
import xtext.pycom.ParameterString
import xtext.pycom.ParameterPin
import xtext.pycom.ParameterBoolean
import xtext.pycom.FunctionDefinitions
import xtext.pycom.ParameterDefinitions

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class PycomValidator extends AbstractPycomValidator {
	
	public static val INVALID_PARAMETER = 'invalidParameter'


	val INTEGER = "Integer"
	val STRING = "String"
	val VOID = "Nothing"
	val BOOLEAN = "Boolean"
	val PIN = "Pin"
	
	val IPv4_REGEX =
			"^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$";

	val IPv4_PATTERN = Pattern.compile(IPv4_REGEX)
	
	@Check
	def CheckBoardName(xtext.pycom.System system) {
		var boardNames  = new HashSet<String>()
		for(board: system.boards) {
			if(!boardNames.contains(board.name)) {
				boardNames.add(board.name)
			}else{
				error('The name of a board must be unique', board, PycomPackage.Literals.BOARD__NAME)
			}
		}
	}
	
	@Check
	def CheckParameters(FunctionCall function) {
		if(function.function !== null && function.function.name !== null) {
			if(function.parameters.length != function.function.parameters.length) {
				if(function.parameters.length > function.function.parameters.length) {
					var correntamount = function.function.parameters.length
					error('Too many parameters! There should only be ' + correntamount + ' parameters in ' + function.function.name, function, PycomPackage.Literals.FUNCTION_CALL__PARAMETERS)
				} else {
					var correntamount = function.function.parameters.length
					error('Too few parameters! There should be ' + correntamount + ' parameters in ' + function.function.name, function, PycomPackage.Literals.FUNCTION_CALL__PARAMETERS)
				}
			}
		}
	}

	
	@Check
	def checkParameterType(ParameterName parameterName) {
		if(EcoreUtil2.getContainerOfType(parameterName, FunctionCall) instanceof FunctionCall) {
			var parentFunction = EcoreUtil2.getContainerOfType(parameterName, FunctionCall)
			var index = parentFunction.parameters.indexOf(parameterName)
			if (parentFunction.function.parameters.length >= index && parentFunction.function.parameters.length !== 0 && index >= 0) {
				var referencetype = parentFunction.function.parameters.get(index).type
			
				if (parameterName instanceof ParameterInt && !referencetype.equalsIgnoreCase(INTEGER)) {
	     			error('Expected ' + referencetype + ' but got an ' + INTEGER, parameterName, PycomPackage.Literals.PARAMETER_INT__VALUE)
	     		}
	     		if (parameterName instanceof ParameterString && !referencetype.equalsIgnoreCase(STRING)) {
	     			error('Expected ' + referencetype + ' but got a ' + STRING, PycomPackage.Literals.PARAMETER_STRING__VALUE)
	     		}
	     		if (parameterName instanceof ParameterPin && !referencetype.equalsIgnoreCase(PIN)) {
	     			error('Expected ' + referencetype + ' but got a ' + PIN, PycomPackage.Literals.PARAMETER_PIN__VALUE)
	     		}
	     		if (parameterName instanceof ParameterBoolean && !referencetype.equalsIgnoreCase(BOOLEAN)) {
	     			error('Expected ' + referencetype + ' but got a ' + BOOLEAN, PycomPackage.Literals.PARAMETER_BOOLEAN__VALUE)
	     		}
			}
		}
	}
	
	@Check
	def checkParameterDefinitionType(ParameterDefinitions parameterDefinitions) {
		if(EcoreUtil2.getContainerOfType(parameterDefinitions, FunctionDefinitions) instanceof FunctionDefinitions) {
			var parentFunction = EcoreUtil2.getContainerOfType(parameterDefinitions, FunctionDefinitions)
			var index = parentFunction.parameters.indexOf(parameterDefinitions)
			var type = parameterDefinitions.type
			if (parentFunction.externalFunction.parameters.length >= index && parentFunction.externalFunction.parameters.length !== 0 && index >= 0) {
				var externalType = parentFunction.externalFunction.parameters.get(index).type
			
				if (!type.equalsIgnoreCase(externalType)) {
	     			error('Expected ' + externalType + ' but got a ' + type, parameterDefinitions, PycomPackage.Literals.PARAMETER_DEFINITIONS__TYPE, INVALID_PARAMETER, externalType)
	     		}
			}	
		}
	}
	
	@Check
	def portnumberWithinRange(Connection connection) {
		if(!connection.portnumber.isNullOrEmpty) {
			try {
				var port = Integer.parseInt((connection.portnumber))
				if (port < 0) {
					error('Port number should not be negative', PycomPackage.Literals.CONNECTION__PORTNUMBER)		
				}
				if (port > 65535) {
					error('Port number should be less than 65535', PycomPackage.Literals.CONNECTION__PORTNUMBER)		
				}
				if (port <= 1024) {
					warning('It is recommended to not use ports in the range of 1 - 1024', PycomPackage.Literals.CONNECTION__PORTNUMBER)		
				}
			} catch (NumberFormatException e) {
				error('Ports should be a number', PycomPackage.Literals.CONNECTION__PORTNUMBER)
			}
		}
	}
	
	@Check
	def checkHost(Connection connection) {
		if(!connection.host.ipAdr.isNullOrEmpty) {
			if(!validIPAddress(connection.host.ipAdr)) {
				error('Invalid IP-Address', PycomPackage.Literals.CONNECTION__HOST)			
			}
		}
	}
	
	/**
	 * IP-Validator taken from https://www.techiedelight.com/validate-ip-address-java/
	 */
	def validIPAddress(String ip) {
		if (ip === null) {
			return false;
		}
		if (!IPv4_PATTERN.matcher(ip).matches()) {
			return false;
		}
			var parts = ip.split("\\.");
		try {
			for (String segment: parts) {

				if (Integer.parseInt(segment) > 255 ||
						    (segment.length() > 1 && segment.startsWith("0"))) {
					return false;
				}
			}
		} catch(NumberFormatException e) {
			return false;
		}
		return true;
	}
	
}
