package org.eclipse.xtend.gwt

import com.google.gwt.user.client.rpc.AsyncCallback
import com.google.gwt.user.client.rpc.RemoteService
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath
import com.google.gwt.user.server.rpc.RemoteServiceServlet
import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Target(ElementType.TYPE)
@Active(GwtServiceProcessor)
annotation GwtService {
}

class GwtServiceProcessor extends AbstractClassProcessor {

	private static final String IMPL = "Impl"

	private static final String SERVER = ".server"

	private static final String SHARED = ".shared"

	override doRegisterGlobals(ClassDeclaration it, RegisterGlobalsContext context) {
		context.registerInterface(interfaceName)
		context.registerInterface(interfaceAsyncName)
	}

	override doTransform(MutableClassDeclaration it, extension TransformationContext context) {
		if (!simpleName.endsWith(IMPL)) {
			addError('''The name must end with '�IMPL�'.''')
		}

		if (!packageName.contains(SERVER)) {
			addError("A service must reside under the 'server' package.")
		}

		if (extendedClass != typeof(Object).newTypeReference) {
			addError("A service must not extend another class.")
		}

		val interfaceType = findInterface(interfaceName)
		val interfaceAsyncType = findInterface(interfaceAsyncName)

		interfaceType.extendedInterfaces = interfaceType.extendedInterfaces + #[typeof(RemoteService).newTypeReference]
		interfaceType.addAnnotation(typeof(RemoteServiceRelativePath).newTypeReference.type).set('value',
			interfaceSimpleName.toFirstLower)

		for (method : declaredMethods.filter[visibility == Visibility::PUBLIC]) {
			interfaceType.addMethod(method.simpleName,
				[
					returnType = method.returnType
					method.parameters.forEach(p|addParameter(p.simpleName, p.type))
				])
			interfaceAsyncType.addMethod(method.simpleName,
				[
					method.parameters.forEach(p|addParameter(p.simpleName, p.type))
					addParameter('result',
						typeof(AsyncCallback).newTypeReference(
							switch method.returnType {
								case primitiveVoid: newTypeReference(typeof(Void))
								case primitiveBoolean: newTypeReference(typeof(Boolean))
								case primitiveInt: newTypeReference(typeof(Integer))
								case primitiveLong: newTypeReference(typeof(Long))
								//...
								default: method.returnType
							}))
				])
		}

		extendedClass = typeof(RemoteServiceServlet).newTypeReference
		implementedInterfaces = implementedInterfaces + #[interfaceType.newTypeReference]
	}

	def static interfaceAsyncName(ClassDeclaration it) {
		interfaceName + 'Async'
	}

	def static interfaceName(ClassDeclaration it) {
		packageName.replace(SERVER, SHARED) + "." + interfaceSimpleName
	}

	def static interfaceSimpleName(ClassDeclaration it) {
		simpleName.substring(0, simpleName.length - IMPL.length)
	}

	def static String packageName(ClassDeclaration it) {
		qualifiedName.substring(0, qualifiedName.length - simpleName.length - 1)
	}

}
