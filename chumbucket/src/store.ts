import {reducer} from 'obake.js';

type Notification = {
  text: string,
  show: boolean
}
export type Priority = '(A)' | '(B)' | '(C)' | '(D)' | '(E)' | '(F)' | '(G)' | '(H)' | '(I)' | '(J)' | string

export type Todo = {
	id: string,
	complete: boolean,
	priority: Priority,
	completedAt: string;
	createdAt: string;
	text: string;
	project: string;
	tags: string[];
	spec: string[];

}

export type Route = 'HOME' | 'KANBAN'
export type State = {
  selectedItem: string;
  currentPage: Route,
  fileTodos: Todo[],
  tagFilters: string[],
  selectedFile: string,
  kanbanColumns: string[],
  notification: Notification,
  modelOpen: boolean;
  _update:(_reducerName: string, _data: unknown) => Promise<State>
}

export const defaultState: Omit<State, '_update'> = {
	currentPage: 'HOME',
	fileTodos: [],
	tagFilters: [],
	kanbanColumns: [],
	modelOpen: false,
	selectedItem: '',
	selectedFile: '',
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
	updateNotification: reducer((state: State, value:{text: string, show: boolean}) => {
		state.notification = value;
	}),
	addKanbanColumn: reducer((state: State, value:string) => {
		state.kanbanColumns = [...state.kanbanColumns, value];
	}),
	addNewTodo: reducer((state: State, value:Todo) => {
		state.fileTodos = [value, ...state.fileTodos];
	}),
	setFileTodos: reducer((state: State, value:Todo[]) => {
		state.fileTodos = value;
	}),
	setOpenModel: reducer((state: State, value: boolean) => {
		state.modelOpen = value;
	}),
	setKanbanColumns: reducer((state: State, value: string[]) => {
		state.kanbanColumns = value;
	}),
	setSelectedItem: reducer((state: State, value: string) => {
		state.selectedItem = value;
	}),
	setFilePath: reducer((state: State, value: string) => {
		state.selectedFile = value;
	}),
};
