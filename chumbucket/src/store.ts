import * as obakejs from 'obake.js';

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
  dropColumn: string;
  currentPage: Route,
  fileTodos: Todo[],
	mousePosition: MousePosition,
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
	dropColumn: '',
	mousePosition: {x: 0, y: 0},
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

type MousePosition = {
	x: number,
	y: number
}

export const reducers = {
	updateCurrentPage: obakejs.reducer((state: State, value: Route) => {
		state.currentPage = value;
	}),
	updateNotification: obakejs.reducer((state: State, value:{text: string, show: boolean}) => {
		state.notification = value;
	}),
	addKanbanColumn: obakejs.reducer((state: State, value:string) => {
		state.kanbanColumns = [...state.kanbanColumns, value];
	}),
	addNewTodo: obakejs.reducer((state: State, value:Todo) => {
		state.fileTodos = [value, ...state.fileTodos];
	}),
	setFileTodos: obakejs.reducer((state: State, value:Todo[]) => {
		state.fileTodos = value;
	}),
	setOpenModel: obakejs.reducer((state: State, value: boolean) => {
		state.modelOpen = value;
	}),
	setKanbanColumns: obakejs.reducer((state: State, value: string[]) => {
		state.kanbanColumns = value;
	}),
	setSelectedItem: obakejs.reducer((state: State, value: string) => {
		state.selectedItem = value;
	}),
	setFilePath: obakejs.reducer((state: State, value: string) => {
		state.selectedFile = value;
	}),
	setDropColumn: obakejs.reducer((state: State, value: string) => {
		state.dropColumn = value;
	}),
	setMousePosition: obakejs.reducer((state: State, value: MousePosition) => {
		state.mousePosition = value;
	}),
};
