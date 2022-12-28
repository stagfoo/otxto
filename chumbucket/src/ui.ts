import * as ACTIONS from './actions';
import html from 'nanohtml';
import {ROUTES, Route, State, Todo} from './store';
import {getRandomColorClass, notificationStyle} from './styles';

export function ui(state: State): HTMLElement {
	return html`
    <div id="app">
    ${notification(state)}
      <div class="page">${routing(state)}</div>
    </div>
  `;
}

export function topSection(state: State): HTMLElement {
	return html`
  <div class="container row center top-section">
  <div class="item xs-6">${addNewModel(true, ACTIONS.handleNewTodoTextInput)}</div>
  <div class="item xs-4">${navbar(state)}</div>
  </div>
  `;
}

export function routing(state: State): HTMLElement {
	switch (state.currentPage) {
		case 'HOME':
			return html`
        ${topSection(state)}
        <div class="container column">
          ${state.fileTodos.filter(t => !t.complete).map(t => todoItem(t))}
        </div>
        <div class="container column">
          ${state.fileTodos.filter(t => t.complete).map(t => todoItem(t))}
        </div>

      `;
		case 'KANBAN':
			return html`
      ${topSection(state)}      
      <div class="container row">
          ${kanbanColumn('remaining', ACTIONS.normalizedRemoveCompletedItems(ACTIONS.normalizedRemoveKanbanItems(state.fileTodos)), false)}
          ${state.kanbanColumns.map(listTag => kanbanColumn(listTag, ACTIONS.normalizedRemoveCompletedItems(ACTIONS.normalizedContainsTagItems(state.fileTodos, listTag)), true))}
          ${kanbanColumnCreate(ACTIONS.addKanbanColumn)}
          ${kanbanColumn('done', state.fileTodos.filter(t => t.complete), false)}
      </div>
     

      `;
		default:
			return html` <h1>404 CHUM</h1> `;
	}
}

export function kanbanColumnCreate(onKeyUp: (_event: KeyboardEvent) => void) {
	return html`
    <div class="item kanban-column">
    <div class="container column">
      <div class="item"><input onkeyup="${onKeyUp}" class="add-column" type="text" placeholder="add tag..."></div>
      </div>
  </div>
    `;
}

export function kanbanColumn(title: string, list: Todo[], canRemove: boolean) {
	const removeButton = canRemove ? html`<button class="close" onclick=${() => ACTIONS.removeKanbanCol(title)}>${featherIcon('close')}</button>` : undefined;
	return html`
    <div class="item kanban-column" ondragenter="${(e: MouseEvent) => ACTIONS.onMouseEnterKanban(e, title)}">
    <div class="container column">
      <div class="item title ${removeButton ? title[1] + ' tag-title' : ''}">${title} ${removeButton}</div>
      ${list.map(t => todoItem(t))}
      </div>
  </div>
  `;
}

export function todoPriority(t: string) {
	return t && html`<span class="priority ${getRandomColorClass()}">${t}</span>`;
}

export function todoFilter(state: State) {
	return html`<input class="tag-filter" placeholder="border filter...">${state.tagFilters.join(',')}</input>`;
}

export function todoTagList(firstElm: any, tags: string[]) {
	return html`<ul class="tags container row">${firstElm} ${(tags).map(name => html`<li class="item tag ${name[1]}">${name}</li>`)}</ul>`;
}

export function todoItem(todo: Todo): HTMLElement {
	const isCompleteClass = todo.complete ? 'completed' : '';
	return html`
  <div data-nanomorph-component-id="${todo.id}" id=${todo.id} draggable="true" ondrag="${ACTIONS.onMouseDownDragSelf}" ondragend="${ACTIONS.onMouseDownDragSelf}" ondrop="${ACTIONS.onMouseDownDragSelf}" ondragover="${ACTIONS.onMouseDownDragSelf}" class="item todo ${isCompleteClass}" onmouseenter="${ACTIONS.focusedItem}">
  <div class="box">
  <div class="container space-between">
    <div class="item text">${todo.text}</div>
    <div class="item">${todoPriority(todo.priority)}</div>
    </div>
  </div>
  ${todo.tags.length > 0 ? todoTagList(timestamp(todo.createdAt), todo.tags) : null}
  </div>
  `;
}

export function timestamp(text: string): HTMLElement | string {
	if (text.length === 0) {
		return '';
	}

	return html`<li class="timestamp">${text ? '⏱️ ' + text : ''}</li>`;
}

export function navbar(state: State): HTMLElement {
	return html`
    <div class="nav">
      <ul class="container">
          <li class="item">
          <a class="box item" href="javascript:void(0)" onclick=${ACTIONS.openFileFromDisk} >${featherIcon('folder')}</a>
        </li>
        ${(Object.keys(ROUTES) as Route[]).map(name => {
		const isActive = state.currentPage === name;
		return html` <li class="${isActive ? 'active' : ''}">
            <a class="box" href="${ROUTES[name]}">${featherIcon(name)}</a>
          </li>`;
	})}
      </ul>
    </div>
  `;
}

export function featherIcon(name: string) {
	switch (name) {
		case 'grid':
		case 'KANBAN':
			return html`<i data-feather="grid"></i>`;
		case 'HOME':
		case 'list':
			return html`<i data-feather="list"></i>`;
		case 'plus':
			return html`<i data-feather="plus"></i>`;
		case 'close':
			return html`<i data-feather="x"></i>`;
		default:
			return html`<i data-feather="folder"></i>`;
	}
}

function notification(state: State): HTMLElement {
	notificationStyle();
	return html`
    <div class="notification ${state.notification.show ? 'show' : 'hide'}">
      ${state.notification.text}
    </div>
  `;
}

function addNewModel(modelOpen: boolean, onKeyUp: (_event: KeyboardEvent) => void): HTMLElement | undefined {
	if (!modelOpen) {
		return;
	}

	return html`
      <input placeholder="add new todo text" onkeyup=${onKeyUp}></input>
  `;
}
