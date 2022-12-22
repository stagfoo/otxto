import * as STORE_MODULE from './store';
import * as ACTIONS from './actions';
import * as URL_MODULE from './url';
import * as obakejs from 'obake.js';
import * as UI_MODULE from './ui';
import * as STYLE_MODULE from './styles';
import morph from 'nanomorph';
import * as keyboard from 'keyboard-handler';

// Default render
const ROOT_NODE = document.body.querySelector('#app');

// Create Store
export const state:STORE_MODULE.State = obakejs.createStore(
	STORE_MODULE.defaultState,
	{
		renderer,
	},
	STORE_MODULE.reducers,
);

// Render Loop function
// spec - https://dom.spec.whatwg.org/#concept-node-equals
function renderer(newState: STORE_MODULE.State) {
	morph(ROOT_NODE, UI_MODULE.ui(newState), {
		onBeforeElUpdated(fromEl: HTMLElement, toEl: HTMLElement) {
			return !fromEl.isEqualNode(toEl);
		},
	});
	window.feather.replace();
}

// Start Router listener
URL_MODULE.startRouters();
STYLE_MODULE.STYLES.add('styles', STYLE_MODULE.globalStyles(STYLE_MODULE.DS), window.document.createElement('style'), true);

keyboard.keyPressed((e:any) => {
	const currentElement = document?.activeElement?.tagName;
	const textElements = ['INPUT', 'TEXTAREA'];
	if (!textElements.includes(`${currentElement}`)) {
		if (e.key === 'x') {
			ACTIONS.deleteItem(state.selectedItem);
		}
	}
});
