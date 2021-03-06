/**
 * generated by Xtext 2.17.0
 */
package xtext.pycom;

import org.eclipse.emf.ecore.EObject;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Condition</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link xtext.pycom.Condition#getLogicEx <em>Logic Ex</em>}</li>
 *   <li>{@link xtext.pycom.Condition#getOperator <em>Operator</em>}</li>
 *   <li>{@link xtext.pycom.Condition#getNestedCondition <em>Nested Condition</em>}</li>
 * </ul>
 *
 * @see xtext.pycom.PycomPackage#getCondition()
 * @model
 * @generated
 */
public interface Condition extends EObject
{
  /**
   * Returns the value of the '<em><b>Logic Ex</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Logic Ex</em>' containment reference.
   * @see #setLogicEx(LogicExp)
   * @see xtext.pycom.PycomPackage#getCondition_LogicEx()
   * @model containment="true"
   * @generated
   */
  LogicExp getLogicEx();

  /**
   * Sets the value of the '{@link xtext.pycom.Condition#getLogicEx <em>Logic Ex</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Logic Ex</em>' containment reference.
   * @see #getLogicEx()
   * @generated
   */
  void setLogicEx(LogicExp value);

  /**
   * Returns the value of the '<em><b>Operator</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Operator</em>' attribute.
   * @see #setOperator(String)
   * @see xtext.pycom.PycomPackage#getCondition_Operator()
   * @model
   * @generated
   */
  String getOperator();

  /**
   * Sets the value of the '{@link xtext.pycom.Condition#getOperator <em>Operator</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Operator</em>' attribute.
   * @see #getOperator()
   * @generated
   */
  void setOperator(String value);

  /**
   * Returns the value of the '<em><b>Nested Condition</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Nested Condition</em>' containment reference.
   * @see #setNestedCondition(Condition)
   * @see xtext.pycom.PycomPackage#getCondition_NestedCondition()
   * @model containment="true"
   * @generated
   */
  Condition getNestedCondition();

  /**
   * Sets the value of the '{@link xtext.pycom.Condition#getNestedCondition <em>Nested Condition</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Nested Condition</em>' containment reference.
   * @see #getNestedCondition()
   * @generated
   */
  void setNestedCondition(Condition value);

} // Condition
