import {State, Todo} from 'store';
import {state} from './index';
import nid from 'nid';
import dayjs from 'dayjs';
import _ from 'lodash';

let globalMouseListener: any = null;

type PywebviewAPI = {
	api: {
		getFile: () => any,
		saveFile: (_name: string, _fileContent: string) => any
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
	return `${complete ? 'x ' : ''}${priority ? '(' + priority + ') ' : ''}${completedAt + ' '}${createdAt + ' '}${text + ' '}${project ? project + ' ' : ''}${tags?.join(' ')}`.replaceAll('  ', ' ');
}

export async function openFileFromDisk() {
	const win = window as any;
	const {pywebview} = win;
	const result = await (pywebview as PywebviewAPI).api.getFile();
	state._update('setFilePath', result.path);
	state._update('setFileTodos', normalizerTodoTxtToState(result.fileContent));
}

export function isPriority(txt: string) {
	if (txt.length === 0) {
		return false;
	}

	return txt[0] === '(' && txt[2] === ')';
}

export function isDateLike(txt: string) {
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

export function normalizerTodoTxtToState(fileContent: string): Todo[] {
	const lineList = fileContent.split('\n').filter(l => l !== '');
	return lineList.map(l => {
		const parts = l.split(' ');
		const complete = parts[0] === 'x';
		const priority = parts.filter(p => isPriority(p))[0];
		const completedAt = complete ? parts.filter(p => isDateLike(p))[0] : '';
		const createdAt = completedAt ? parts.filter(p => isDateLike(p))[1] : parts.filter(p => isDateLike(p))[0];
		return {
			id: nid(12),
			complete,
			priority: priority ? priority[1] : '',
			completedAt: completedAt ? completedAt : '',
			createdAt: createdAt ? createdAt : '',
			text: parts.filter((p, i) => !(parts[0] === 'x' && i === 0) && !isDateLike(p) && !isPriority(p) && !isTag(p) && !isProject(p)).join(' '),
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
		priority: undefined,
		completedAt: '',
		createdAt: dayjs().format('YYYY-MM-DD'),
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
	const normalizedFile = state.fileTodos.map(item => createTodoTextLine(item.complete, item.text, item.priority, item.completedAt, item.createdAt, item.project, item.tags)).join('\n');
	if (state.selectedFile.length > 0) {
		try {
			await (pywebview as PywebviewAPI).api.saveFile(state.selectedFile, normalizedFile);
		} catch (err) {
			console.error(err);
		}
	}
}

export function focusedItem(e: MouseEvent) {
	const item = e.target as any;
	if (item.className.includes('item todo')) {
		state._update('setSelectedItem', item.id);
	}
}

// TODO rename to complete
export function deleteItem(id: string) {
	const cleanList = state.fileTodos.map(item => {
		if (item.id === id) {
			item.complete = !item.complete;
			return item;
		}

		return item;
	});
	state._update('setFileTodos', cleanList);
}

export function addTagToItem(id: string, newTag: string) {
	const cleanList = state.fileTodos.map(item => {
		console.log(id, newTag);
		if (item.id === id) {
			const nextTags = item.tags.filter(t => !state.kanbanColumns.includes(t));
			item.tags = _.uniq([...nextTags, newTag]);
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

export function onMouseDownDragSelf(e: MouseEvent) {
	e.preventDefault();
	const item = e.target as any;
	const column = state.dropColumn;
	const coreColumns = ['remaining', 'done'];
	switch (e.type) {
		case 'dragend':
			e.preventDefault();
			if (e.target && !coreColumns.includes(column)) {
				addTagToItem(`${item.id}`, state.dropColumn);
				state._update('setDropColumn', '');
			}

			if (e.target && column === 'done') {
				deleteItem(`${item.id}`);
				state._update('setDropColumn', '');
			}

			if (e.target && column === 'remaining') {
				addTagToItem(`${item.id}`, '');
				state._update('setDropColumn', '');
			}

			break;
		case 'drop':
		case 'dragover':
			e.preventDefault();
			break;
		case 'dragged':
		default:
			e.preventDefault();
			break;
	}
}

export function onMouseEnterKanban(e: MouseEvent, key: string) {
	e.preventDefault();
	state._update('setDropColumn', key);
}
