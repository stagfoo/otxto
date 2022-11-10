import {State, Todo} from 'store';
import {state} from './index';
import nid from 'nid';

type PywebviewAPI = {
	api: {
		getFile: () => any,
		saveFile: (name: string, fileContent: string) => any
	}
}

export function hideNotifications(timeout: number) {
	setTimeout(() => {
		state._update('updateNotification', {
			text: '',
			show: false,
		});
	}, timeout);
}

export function showNotifications(message: string) {
	state._update('updateNotification', {
		text: message,
		show: true,
	});
}

export function addKanbanColumn(event: KeyboardEvent) {
	const {target} = event;
	const tag = (target as any).value;
	if (event.key === 'Enter' && tag.length > 0) {
		state._update('addKanbanColumn', tag);
	}
}

export function createTodoTextLine(complete: boolean, text: string, priority?: string, completedAt?: string, createdAt?: string, project?: string, tags?: string[]) {
	return `${complete ? 'x' : ''} ${priority ? '(' + priority + ')' : ''} ${completedAt} ${createdAt} ${text} ${project ? project : ''} ${tags?.join(' ')}`;
}

// OpenFile
// saveFIle

export async function openFileFromDisk() {
	const win = window as any;
	const {pywebview} = win;
	const result = await (pywebview as PywebviewAPI).api.getFile();
	console.log(result);
	state._update('setFilePath', result.path);
	state._update('setFileTodos', normalizerTodoTxtToState(result.fileContent));
}

export function isPrority(txt: string) {
	if (txt.length === 0) {
		return false;
	}

	return txt[0] === '(' && txt[2] === ')';
}

export function isDateShape(txt: string) {
	if (txt.length === 0) {
		return false;
	}

	const currentCentury = '20';
	const parts = txt.split('-');
	return txt[0] === currentCentury[0] && txt[1] === currentCentury[1] && parts.length === 3;
}

export function isTag(txt: string) {
	return txt[0] === '@';
}

export function isProject(txt: string) {
	return txt[0] === '+';
}

// TODO set tag color here
export function normalizerTodoTxtToState(fileContent: string): Todo[] {
	const lineList = fileContent.split('\n').filter(l => l !== '');
	return lineList.map(l => {
		const parts = l.split(' ');
		const complete = parts[0] === 'x';
		const prority = parts.filter(p => isPrority(p))[0];

		console.log(parts[0]);
		return {
			id: nid(12),
			complete,
			prority: prority ? prority[1] : '',
			completedAt: isDateShape(parts[2]) ? new Date(parts[2]).toDateString() : '',
			createdAt: isDateShape(parts[3]) ? new Date(parts[3]).toDateString() : '',
			text: parts.filter((p, i) => !(parts[0] === 'x' && i === 0) && !isDateShape(p) && !isPrority(p) && !isTag(p) && !isProject(p)).join(' '),
			project: parts.filter((p: string) => isProject(p))[0],
			tags: parts.filter((p: string) => isTag(p)),
			spec: [],
		};
	});
}

export function handleNewTodoTextInput(event: KeyboardEvent) {
	const {target} = event;
	const text = (target as any).value;

	const newTodo = {
		id: nid(12),
		complete: false,
		prority: undefined,
		completedAt: '',
		createdAt: new Date().toDateString(),
		text,
		project: undefined,
		tags: [],
		spec: [],
	};
	if (event.key === 'Enter') {
		state._update('addNewTodo', newTodo);
		state._update('setOpenModel', false);
	}
}

export function showAddModel() {
	state._update('setOpenModel', true);
}

export function removeKanbanCol(tag: string) {
	state._update('setKanbanColumns', state.kanbanColumns.filter(t => t !== tag));
}

export async function fileSave(state: State) {
	const win = window as any;
	const {pywebview} = win;
	const normalizedFile = state.fileTodos.map(item => createTodoTextLine(item.complete, item.text, item.prority, item.completedAt, item.createdAt, item.project, item.tags)).join('\n');
	if (state.selectedFile.length > 0) {
		try {
			await (pywebview as PywebviewAPI).api.saveFile(state.selectedFile, normalizedFile);
		} catch (err) {
			console.log(err);
		}
	}
}

export function focusedItem(e: MouseEvent) {
	const item = e.target as any;
	if (item.className.includes('item todo')) {
		console.log(item.id);
		state._update('setSeletedItem', item.id);
	}
}

export function deleteItem() {
	const cleanList = state.fileTodos.map(item => {
		if (item.id === state.selectedItem) {
			item.complete = !item.complete;
			return item;
		}

		return item;
	});
	state._update('setFileTodos', cleanList);
}

export function normalizedRemoveKanbanItems(list: Todo[]) {
	return list.filter(t => t.tags.every(tag => !state.kanbanColumns.includes(tag)));
}

export function normalizedRemoveCompletedItems(list: Todo[]) {
	return list.filter(t => !t.complete);
}

export function normalizedContainsTagItems(list: Todo[], tag: string) {
	return list.filter(t => t.tags.includes(tag));
}
