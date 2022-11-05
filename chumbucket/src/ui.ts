import * as ACTIONS from './actions';
import html from 'nanohtml';
import {ROUTES, Route, State, NAVBAR, Todo} from './store';
import { notificationStyle } from 'styles';

export function ui(state: State): HTMLElement {
	return html`
    <div id="app">
      <div class="page">${routing(state)}</div>
      ${notification(state)}
    </div>
  `;
}

export function TopSection(state: State): HTMLElement {
  return html`
  <div class="container row center">
  <div class="item"><button>${FeatherIcon('plus')}</button></div>
  <div class="item xs-6">${TodoFilter(state)}</div>
  <div class="item xs-4">${Navbar(state)}</div>
  </div>
  `
}

export function routing(state: State): HTMLElement {
	switch (state.currentPage) {
		case 'HOME':
			return html`
        ${TopSection(state)}
        <div class="container column">
          ${state.fileTodos.filter(t => !t.complete).map(t => {
            return TodoItem(t)
          })}
        </div>
        <div class="container column">
          ${state.fileTodos.filter(t => t.complete).map(t => {
            return TodoItem(t)
          })}
        </div>

      `;
		case 'KANBAN':
			return html`
      ${TopSection(state)}
      <div class="container row">
          ${KanbanColumn('remaining', state.fileTodos.filter(t => !t.complete))}
          ${state.kanbanColumns.map(listTag => {
            return KanbanColumn(listTag, state.fileTodos.filter(t => t.tags.includes(listTag)))
          })}
          ${KanbanColumnCreate(ACTIONS.addKanbanColumn)}

          ${KanbanColumn('done', state.fileTodos.filter(t => t.complete))}
      </div>
     

      `;
		default:
			return html` <h1>404 CHUM</h1> `;
	}
}

export function KanbanColumnCreate(onKeyUp: (event: KeyboardEvent) => void){
    return html`
    <div class="item kanban-column">
    <div class="container column">
      <div class="item"><input onkeyup="${onKeyUp}" class="add-column" type="text" placeholder="add tag..."></div>
      </div>
  </div>
    `
}

export function KanbanColumn(title: string, list: Todo[]) {
  return html`
    <div class="item kanban-column">
    <div class="container column">
      <div class="item title">${title}</div>
      ${list.map(t => {
        return TodoItem(t)
      })}
      </div>
  </div>
  `
}

export function TodoProity(t: string){
  return html`<span class="priority">${t}</span>`
}

export function TodoFilter(state: State){
  return html`<input class="tag-filter" placeholder="border filter...">${state.tagFilters.join(',')}</input>`
}

export function TodoTagList(tags: string[]){
  return html`<ul class="tags container row">${(tags).map(name => {
    return html`<li class="item tag">${name}</li>`
  })}</ul>`
}

export function TodoItem(todo: Todo): HTMLElement {
  const isCompleteClass = todo.complete ? 'completed' : ''
  return html`
  <div class="item todo ${isCompleteClass}">
  <div class="box">
  <div class="container space-between">
    <div class="item text">${todo.text}</div>
    <div class="item prority">${TodoProity(todo.prority)}</div>
    </div>
  </div>
  ${todo.tags.length > 0 ? TodoTagList(todo.tags): null}
  </div>
  `
}

export function Navbar(state: State): HTMLElement {
	return html`
    <div class="nav">
      <ul class="container">
          <li class="item">
          <a class="box item" href="javascript:void(0)" onclick=${ACTIONS.handleButtonClick} >${FeatherIcon("folder")}</a>
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
export function FeatherIcon(name: string){
  switch (name) {
    case 'grid':
    case 'KANBAN':
      return html`<i data-feather="grid"></i>`
    case 'HOME':
		case 'list':
			return html`<i data-feather="list"></i>`
    case 'plus':
      return html`<i data-feather="plus"></i>`
		default:
			return html`<i data-feather="folder"></i>`;
	}
}

function notification(state: State): HTMLElement {
  notificationStyle()
	return html`
    <div class="notification ${state.notification.show ? 'show' : 'hide'}">
      ${state.notification.text}
    </div>
  `;
}
