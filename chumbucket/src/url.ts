import page from 'page';
import {state} from './index';

// Handlers
const HOME_PAGE = () => {
	state._update('updateCurrentPage', 'HOME');
};

const KANBAN = () => {
	state._update('updateCurrentPage', 'KANBAN');
};

// Routes
page('/', HOME_PAGE);
page('/kanban', KANBAN);

export function startRouters(): void {
	page.start();
}

// Network Call
export async function getData(url: string) {
	const resp = await fetch(url);
	if (resp.ok) {
		return resp.json();
	}

	throw new TypeError('getData response is not Ok');
}
