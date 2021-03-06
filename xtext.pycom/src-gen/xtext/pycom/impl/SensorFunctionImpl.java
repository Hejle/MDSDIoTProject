/**
 * generated by Xtext 2.17.0
 */
package xtext.pycom.impl;

import org.eclipse.emf.common.notify.Notification;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;

import xtext.pycom.PycomPackage;
import xtext.pycom.SensorFunction;
import xtext.pycom.SensorType;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Sensor Function</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * </p>
 * <ul>
 *   <li>{@link xtext.pycom.impl.SensorFunctionImpl#getSensorType <em>Sensor Type</em>}</li>
 * </ul>
 *
 * @generated
 */
public class SensorFunctionImpl extends FunctionImpl implements SensorFunction
{
  /**
   * The cached value of the '{@link #getSensorType() <em>Sensor Type</em>}' reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getSensorType()
   * @generated
   * @ordered
   */
  protected SensorType sensorType;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected SensorFunctionImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass()
  {
    return PycomPackage.Literals.SENSOR_FUNCTION;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public SensorType getSensorType()
  {
    if (sensorType != null && sensorType.eIsProxy())
    {
      InternalEObject oldSensorType = (InternalEObject)sensorType;
      sensorType = (SensorType)eResolveProxy(oldSensorType);
      if (sensorType != oldSensorType)
      {
        if (eNotificationRequired())
          eNotify(new ENotificationImpl(this, Notification.RESOLVE, PycomPackage.SENSOR_FUNCTION__SENSOR_TYPE, oldSensorType, sensorType));
      }
    }
    return sensorType;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public SensorType basicGetSensorType()
  {
    return sensorType;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setSensorType(SensorType newSensorType)
  {
    SensorType oldSensorType = sensorType;
    sensorType = newSensorType;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, PycomPackage.SENSOR_FUNCTION__SENSOR_TYPE, oldSensorType, sensorType));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType)
  {
    switch (featureID)
    {
      case PycomPackage.SENSOR_FUNCTION__SENSOR_TYPE:
        if (resolve) return getSensorType();
        return basicGetSensorType();
    }
    return super.eGet(featureID, resolve, coreType);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eSet(int featureID, Object newValue)
  {
    switch (featureID)
    {
      case PycomPackage.SENSOR_FUNCTION__SENSOR_TYPE:
        setSensorType((SensorType)newValue);
        return;
    }
    super.eSet(featureID, newValue);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eUnset(int featureID)
  {
    switch (featureID)
    {
      case PycomPackage.SENSOR_FUNCTION__SENSOR_TYPE:
        setSensorType((SensorType)null);
        return;
    }
    super.eUnset(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public boolean eIsSet(int featureID)
  {
    switch (featureID)
    {
      case PycomPackage.SENSOR_FUNCTION__SENSOR_TYPE:
        return sensorType != null;
    }
    return super.eIsSet(featureID);
  }

} //SensorFunctionImpl
