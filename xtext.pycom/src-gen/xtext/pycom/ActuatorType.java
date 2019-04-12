/**
 * generated by Xtext 2.17.0
 */
package xtext.pycom;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EObject;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Actuator Type</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link xtext.pycom.ActuatorType#getTypeName <em>Type Name</em>}</li>
 *   <li>{@link xtext.pycom.ActuatorType#getName <em>Name</em>}</li>
 *   <li>{@link xtext.pycom.ActuatorType#getPins <em>Pins</em>}</li>
 * </ul>
 *
 * @see xtext.pycom.PycomPackage#getActuatorType()
 * @model
 * @generated
 */
public interface ActuatorType extends EObject
{
  /**
   * Returns the value of the '<em><b>Type Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Type Name</em>' attribute.
   * @see #setTypeName(String)
   * @see xtext.pycom.PycomPackage#getActuatorType_TypeName()
   * @model
   * @generated
   */
  String getTypeName();

  /**
   * Sets the value of the '{@link xtext.pycom.ActuatorType#getTypeName <em>Type Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Type Name</em>' attribute.
   * @see #getTypeName()
   * @generated
   */
  void setTypeName(String value);

  /**
   * Returns the value of the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Name</em>' attribute.
   * @see #setName(String)
   * @see xtext.pycom.PycomPackage#getActuatorType_Name()
   * @model
   * @generated
   */
  String getName();

  /**
   * Sets the value of the '{@link xtext.pycom.ActuatorType#getName <em>Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Name</em>' attribute.
   * @see #getName()
   * @generated
   */
  void setName(String value);

  /**
   * Returns the value of the '<em><b>Pins</b></em>' containment reference list.
   * The list contents are of type {@link xtext.pycom.Pin}.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Pins</em>' containment reference list.
   * @see xtext.pycom.PycomPackage#getActuatorType_Pins()
   * @model containment="true"
   * @generated
   */
  EList<Pin> getPins();

} // ActuatorType