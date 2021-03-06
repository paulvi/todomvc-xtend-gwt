package org.eclipse.xtend.gwt.todomvc.client

import com.google.gwt.user.client.ui.CheckBox
import com.google.gwt.user.client.ui.Composite
import com.google.gwt.user.client.ui.HTMLPanel
import com.google.gwt.user.client.ui.Label
import com.google.gwt.user.client.ui.TextBox
import org.eclipse.xtend.gwt.todomvc.shared.Todo

import static extension org.eclipse.xtend.gwt.ui.UiBuilder.*
import static com.google.gwt.event.dom.client.KeyCodes.*

class TodoComposite extends Composite {

	HTMLPanel li
	TextBox textBox
	CheckBox checkBox
	Label label

	Todo todo
	(Todo)=>void updateTodo
	(Todo)=>void deleteTodo

	new(Todo todo, (Todo)=>void updateTodo, (Todo)=>void deleteTodo) {
		this.todo = todo
		this.updateTodo = updateTodo
		this.deleteTodo = deleteTodo
		initWidget(createWidget())
		updateView()
	}

	def createWidget() {
		li = 'li'.htmlPanel [
			textBox = textBox [
				styleName = 'edit'
				onBlur [
					todo.title = textBox.value
					viewMode
					updateTodo.apply(todo)
				]
				onKeyPress [
					switch nativeEvent.keyCode {
						case KEY_ENTER: {
							todo.title = textBox.value
							viewMode
							updateTodo.apply(todo)
						}
						case KEY_ESCAPE: {
							viewMode
							updateTodo.apply(todo)
						}
					}
				]
			]
			flowPanel [
				styleName = 'view'
				checkBox = checkBox [
					styleName = 'toggle'
					onClick [
						todo.done = !todo.done
						updateView
						updateTodo.apply(todo)
					]
				]
				label = label [
					onDoubleClick [
						editMode
					]
				]
				button [
					styleName = 'destroy'
					onClick [
						deleteTodo.apply(todo)
					]
				]
			]
		]
	}

	def viewMode() {
		updateView
		li.element.removeAttribute('class')
	}

	def editMode() {
		updateView
		li.element.setAttribute('class', 'editing')
		textBox.focus = true
	}

	def updateView() {
		textBox.text = todo.title
		label.text = todo.title
		checkBox.value = todo.done
		if (todo.done) {
			li.element.setAttribute("class", "completed")
		} else {
			li.element.removeAttribute("class")
		}
	}

}
