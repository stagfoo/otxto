import {reducer} from 'obake.js';
import nid from 'nid';

type Notification = {
  text: string,
  show: boolean
}
export type Prority = "(A)" | "(B)" | "(C)" | "(D)" | "(E)" | "(F)" | "(G)" | "(H)" | "(I)" | "(J)"

export type Todo = {
	complete: boolean,
	prority: Prority,
	completedAt: string;
	createdAt: string;
	text: string;
	project:  string;
	tags:  string[];
	spec:  string[];

}

export type Route = 'HOME' | 'KANBAN'
export type State = {
  bucket: string,
  currentPage: Route,
  fileTodos: Todo[],
  tagFilters: string[],
  kanbanColumns: string[],
  notification: Notification,
  _update:(_reducerName: string, _data: unknown) => Promise<State>
}

function fakeTodo(text: string, tags: boolean, complete:boolean): Todo{
	const _tags = tags ?  [
		`@${nid(5)}`,
		`@${nid(7)}`,
		`@${nid(12)}`,
		`@${nid(2)}`,
		`@${nid(2)}`,
		`@${nid(2)}`,
		'@map'
	] : []
	return {
	complete,
	prority:  "(A)",
	completedAt: new Date().toDateString(),
	createdAt: new Date().toDateString(),
	text,
	project: `+${nid(5)}`,
	tags:  _tags,
	spec:  [
		'cool:guy'
	]
	}
}

export const defaultState: Omit<State, '_update'> = {
	bucket: '',
	currentPage: 'HOME',
	fileTodos: [
		fakeTodo('testing', true, false),
		fakeTodo('make stickers', true, false),
		fakeTodo('make map logi', false, true),
		
	],
	tagFilters: [],
	kanbanColumns: ['@map'],
	notification: {
		text: '',
		show: false,
	},
};

export const ROUTES = {
	HOME: '/',
	KANBAN: '/kanban',
};
export const NAVBAR = {
	HOME: 'list',
	KANBAN: 'kanban',
};

export const reducers = {
	updateCurrentPage: reducer((state: State, value: Route) => {
		state.currentPage = value;
	}),
	updateBucket: reducer((state: State, value: string) => {
		state.bucket = value;
	}),
	updateNotification: reducer((state: State, value:{text: string, show: boolean}) => {
		state.notification = value;
	}),
	addKanbanColumn: reducer((state: State, value:string) => {
		state.kanbanColumns = [...state.kanbanColumns, value]
	}),
};
