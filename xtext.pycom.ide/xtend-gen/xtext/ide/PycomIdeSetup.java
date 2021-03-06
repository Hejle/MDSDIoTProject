/**
 * generated by Xtext 2.16.0
 */
package xtext.ide;

import com.google.inject.Guice;
import com.google.inject.Injector;
import org.eclipse.xtext.util.Modules2;
import xtext.PycomRuntimeModule;
import xtext.PycomStandaloneSetup;
import xtext.ide.PycomIdeModule;

/**
 * Initialization support for running Xtext languages as language servers.
 */
@SuppressWarnings("all")
public class PycomIdeSetup extends PycomStandaloneSetup {
  @Override
  public Injector createInjector() {
    PycomRuntimeModule _pycomRuntimeModule = new PycomRuntimeModule();
    PycomIdeModule _pycomIdeModule = new PycomIdeModule();
    return Guice.createInjector(Modules2.mixin(_pycomRuntimeModule, _pycomIdeModule));
  }
}
