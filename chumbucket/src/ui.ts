import * as ACTIONS from './actions';
import html from 'nanohtml';
import {ROUTES, Route, State, NAVBAR, Todo} from './store';
import {getRandomColorClass, notificationStyle} from 'styles';

export function ui(state: State): HTMLElement {
	return html`
    <div id="app">
    ${notification(state)}
      <div class="page">${routing(state)}</div>
    </div>
  `;
}

export function TopSection(state: State): HTMLElement {
	return html`
  <div class="container row center top-section">
  <div class="item"><button onclick=${ACTIONS.showAddModel}>${FeatherIcon('plus')}</button></div>
  <div class="item xs-6">${TodoFilter(state)}</div>
  <div class="item xs-4">${Navbar(state)}</div>
  </div>
  `;
}

export function routing(state: State): HTMLElement {
	switch (state.currentPage) {
		case 'HOME':
			return html`
        ${TopSection(state)}
        ${AddNewModel(state, ACTIONS.handleNewTodoTextInput)}
        <div class="container column">
          ${state.fileTodos.filter(t => !t.complete).map(t => TodoItem(t))}
        </div>
        <div class="container column">
          ${state.fileTodos.filter(t => t.complete).map(t => TodoItem(t))}
        </div>

      `;
		case 'KANBAN':
			return html`
      ${TopSection(state)}      
      ${AddNewModel(state, ACTIONS.handleNewTodoTextInput)}
      <div class="container row">
          ${KanbanColumn('remaining', ACTIONS.normalizedRemoveCompletedItems(ACTIONS.normalizedRemoveKanbanItems(state.fileTodos)), false)}
          ${state.kanbanColumns.map(listTag => KanbanColumn(listTag, ACTIONS.normalizedRemoveCompletedItems(ACTIONS.normalizedContainsTagItems(state.fileTodos, listTag)), true))}
          ${KanbanColumnCreate(ACTIONS.addKanbanColumn)}
          ${KanbanColumn('done', state.fileTodos.filter(t => t.complete), false)}
      </div>
     

      `;
		default:
			return html` <h1>404 CHUM</h1> `;
	}
}

export function KanbanColumnCreate(onKeyUp: (event: KeyboardEvent) => void) {
	return html`
    <div class="item kanban-column">
    <div class="container column">
      <div class="item"><input onkeyup="${onKeyUp}" class="add-column" type="text" placeholder="add tag..."></div>
      </div>
  </div>
    `;
}

export function KanbanColumn(title: string, list: Todo[], canRemove: boolean) {
	const removeButton = canRemove ? html`<button class="close" onclick=${() => ACTIONS.removeKanbanCol(title)}>${FeatherIcon('close')}</button>` : undefined;
	return html`
    <div class="item kanban-column">
    <div class="container column">
      <div class="item title">${title} ${removeButton}</div>
      ${list.map(t => TodoItem(t))}
      </div>
  </div>
  `;
}

export function TodoProity(t: string) {
	return t && html`<span class="priority ${getRandomColorClass()}">${t}</span>`;
}

export function TodoFilter(state: State) {
	return html`<input class="tag-filter" placeholder="border filter...">${state.tagFilters.join(',')}</input>`;
}

export function TodoTagList(tags: string[]) {
	return html`<ul class="tags container row">${(tags).map(name => html`<li class="item tag ${name[1]}">${name}</li>`)}</ul>`;
}

export function TodoItem(todo: Todo): HTMLElement {
	const isCompleteClass = todo.complete ? 'completed' : '';
	return html`
  <div id=${todo.id} class="item todo ${isCompleteClass}" onmouseenter="${ACTIONS.focusedItem}">
  <div class="box">
  <div class="container space-between">
    <div class="item text">${todo.text}</div>
    <div class="item prority">${TodoProity(todo.prority)}</div>
    </div>
  </div>
  ${todo.tags.length > 0 ? TodoTagList(todo.tags) : null}
  </div>
  `;
}

export function Navbar(state: State): HTMLElement {
	return html`
    <div class="nav">
      <ul class="container">
          <li class="item">
          <a class="box item" href="javascript:void(0)" onclick=${ACTIONS.openFileFromDisk} >${FeatherIcon('folder')}</a>
        </li>
        ${(Object.keys(ROUTES) as Route[]).map(name => {
		const isActive = state.currentPage === name;
		return html` <li class="${isActive ? 'active' : ''}">
            <a class="box" href="${ROUTES[name]}">${FeatherIcon(name)}</a>
          </li>`;
	})}
      </ul>
    </div>
  `;
}

export function FeatherIcon(name: string) {
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

function AddNewModel(state: State, onKeyUp: (event: KeyboardEvent) => void): HTMLElement | undefined {
	if (!state.modelOpen) {
		return;
	}

	return html`
  <div class="container row center">
      <div class="item xs-6">
      <textarea placeholder="add text" onkeyup=${onKeyUp}></textarea>
      </div>
      </div>
  `;
}
