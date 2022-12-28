import {State, defaultState, reducers} from './store';
import * as ACTIONS from './actions';
import {startRouters} from './url';
import {createStore} from 'obake.js';
import {ui} from './ui';
import * as STYLE_MODULE from './styles';
import morph from 'nanomorph';
import * as keyboard from 'keyboard-handler';
import _ from 'lodash';

// Default render
const ROOT_NODE = document.body.querySelector('#app');
const _fileSave = _.debounce(ACTIONS.fileSave, 500);
// Create Store
export const state: State = createStore(
	defaultState,
	{
		renderer,
		log: console.log,
		filesave: _fileSave,
	},
	reducers,
);

// Render Loop function
// spec - https://dom.spec.whatwg.org/#concept-node-equals
function renderer(newState: State) {
	morph(ROOT_NODE, ui(newState), {
		onBeforeElUpdated(fromEl: HTMLElement, toEl: HTMLElement) {
			return !fromEl.isEqualNode(toEl);
		},
	});
	window.feather.replace();
}

// Start Router listener
startRouters();
STYLE_MODULE.STYLES.add('styles', STYLE_MODULE.globalStyles(STYLE_MODULE.DS), window.document.createElement('style'), true);

keyboard.keyPressed((e: any) => {
	const currentElement = document?.activeElement?.tagName;
	const textElements = ['INPUT', 'TEXTAREA'];
	if (!textElements.includes(`${currentElement}`)) {
		if (e.key === 'x') {
			ACTIONS.deleteItem(state.selectedItem);
		}
	}
});
