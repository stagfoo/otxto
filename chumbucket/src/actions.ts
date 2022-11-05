import { State, Todo } from 'store';
import { state } from './index';
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
	const target = event.target;
	const tag = (target as any).value;
	if (event.key === "Enter" && tag.length > 0) {
		state._update('addKanbanColumn', tag)
	}
}

export function createTodoTextLine(complete: boolean, text: string, priority?: string, completedAt?: string, createdAt?: string, project?: string, tags?: string[]) {
	return `${complete ? 'x' : ''} (${priority}) ${completedAt} ${createdAt} ${text} ${project} ${tags?.join(' ')}`
}

//openFile
//saveFIle

export async function openFileFromDisk() {
	const win = window as any;
	const pywebview = win.pywebview;
	const result = await (pywebview as PywebviewAPI).api.getFile()
	state._update('setFileTodos', normalizerTodoTxtToState(result.fileContent))
}

export function isPrority(txt: string) {
	console.log(txt)
	if (txt.length === 0) {
		return false;
	}
	return txt[0] == "(" && txt[2] == ")";
}
export function isDateShape(txt: string) {
	if (txt.length === 0) {
		return false;
	}
	const currentCentury = '20'
	const parts = txt.split('-')
	return txt[0] === currentCentury[0] && txt[1] === currentCentury[1] && parts.length === 3;
}
export function isTag(txt: string) {
	return txt[0] === '@'
}
export function isProject(txt: string) {
	return txt[0] === '+';
}


//TODO set tag color here
export function normalizerTodoTxtToState(fileContent: string): Todo[] {
	const lineList = fileContent.split('\n').filter((l) => l !== '');
	return lineList.map(l => {
		const parts = l.split(' ');
		const complete = parts[0] === 'x';
		const prority = parts.filter(p => isPrority(p))[0]


		console.log(parts[0]);
		return {
			id: nid(12),
			complete,
			prority,
			completedAt: isDateShape(parts[2]) ? new Date(parts[2]).toDateString() : '',
			createdAt: isDateShape(parts[3]) ? new Date(parts[3]).toDateString() : '',
			text: parts.filter((p, i) => {
				return !(parts[0] === 'x' && i === 0) && !isDateShape(p) && !isPrority(p) && !isTag(p) && !isProject(p)
			}).join(' '),
			project: parts.filter((p: string) => isProject(p))[0],
			tags: parts.filter((p: string) => isTag(p)),
			spec: []
		}
	})
}

export function handleNewTodoTextInput(event: KeyboardEvent) {
	const target = event.target;
	const text = (target as any).value;

	const newTodo =  {
		id: nid(12),
		complete: false,
		prority: undefined,
		completedAt: '',
		createdAt: new Date().toDateString(),
		text,
		project: undefined,
		tags: [],
		spec: [],
	}
	if (event.key === "Enter") {
		state._update('addNewTodo', newTodo)
		state._update('setOpenModel', false)
	}
}
export function showAddModel(){
	state._update('setOpenModel', true)
}

export function removeKanbanCol(tag: string ){
	state._update('setKanbanColumns', state.kanbanColumns.filter(t => t !== tag))
}

export function fileSave(state: State){
	console.log(state)
}