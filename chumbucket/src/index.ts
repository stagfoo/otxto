import {reducers, defaultState, State} from './store';
import {startRouters} from './url';
import {createStore} from 'obake.js';
import {ui} from './ui';
import { STYLES, globalStyles, DS} from './styles';
import morph from 'nanomorph';

// Default render
const ROOT_NODE = document.body.querySelector('#app');

// Create Store
export const state:State = createStore(
	defaultState,
	{
	renderer, 
	log: console.log
	},
	reducers,
);

// Render Loop function
// spec - https://dom.spec.whatwg.org/#concept-node-equals
function renderer(newState: State) {
	morph(ROOT_NODE, ui(newState), {
		onBeforeElUpdated: (fromEl: HTMLElement, toEl: HTMLElement) => !fromEl.isEqualNode(toEl),
	});
	window.feather.replace()
}

// Start Router listener
startRouters();
STYLES.add('styles', globalStyles(DS), window.document.createElement('style'), true)