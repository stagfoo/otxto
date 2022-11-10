import {reducers, defaultState, State} from './store';
import * as ACTIONS from './actions';
import {startRouters} from './url';
import {createStore} from 'obake.js';
import {ui} from './ui';
import {STYLES, globalStyles, DS} from './styles';
import morph from 'nanomorph';
import * as keyboard from 'keyboard-handler';

// Default render
const ROOT_NODE = document.body.querySelector('#app');

// Create Store
export const state:State = createStore(
	defaultState,
	{
		renderer,
		fileSave: ACTIONS.fileSave,
	},
	reducers,
);

// Render Loop function
// spec - https://dom.spec.whatwg.org/#concept-node-equals
function renderer(newState: State) {
	morph(ROOT_NODE, ui(newState), {
		onBeforeElUpdated: (fromEl: HTMLElement, toEl: HTMLElement) => !fromEl.isEqualNode(toEl),
	});
	window.feather.replace();
}

// Start Router listener
startRouters();
STYLES.add('styles', globalStyles(DS), window.document.createElement('style'), true);

keyboard.keyPressed((e:any) => {
	console.log(e.key);
	if (e.key === 'x') {
		ACTIONS.deleteItem();
	}
});
