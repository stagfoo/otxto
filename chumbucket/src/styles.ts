import Joro from 'joro';

export const DS = {
	fontFamily: {
		default: 'monospace',
		alt: 'arial',
	},
	fontSizes: {
		sm: 12,
		md: 16,
		lg: 24,
		xl: 32,

	},
	gutters: {
		xs: 4,
		sm: 8,
		md: 16,
		lg: 24,
		xl: 32,
	},
	borderRadius: 4,
	colors: {
		black: '#000000',
		white: '#ffffff',
		gray: '#424242',
		purple: '#7E4FED',
		lime: '#C8FF04',
		pink: '#FF6EBD',
		blue: '#04E1FF',
		green: '#15DA2A',
	},
};
type DesignSystem = {
  borderRadius: number; fontFamily?: { default: string; alt: string; }; fontSizes: any; gutters: any; colors: any;
};

export const STYLES = new Joro(window);

function bgColorClass(DS: DesignSystem) {
	return `${Object.keys(DS.colors).map((c => `
      .bg-${c} {
        background-color: ${DS.colors[c]};
      }
    `)).join('')}`;
}

function buttonStyle(DS: DesignSystem) {
	return `
  background-color: ${DS.colors.black};
  color:  ${DS.colors.white};
  font-size: ${DS.fontSizes.lg}px;
  padding: ${DS.gutters.sm}px;
  border: 1px solid ${DS.colors.white};
  line-height: 1px;
  border-radius: ${DS.borderRadius}px;
  `;
}

function gridSystem() {
	return `
  .container {
    display: flex; 
    row-gap: ${DS.gutters.sm}px;
    column-gap: ${DS.gutters.md}px;
    padding: ${DS.gutters.md}px;
    justify-content: top;
    align-items: top;
  }
  .container.column {
    flex-direction: column;
  }
  .container.space-between {
    justify-content: space-between;
  }
  .item {
    align-self: center;
  }
  .item.xs-6 {
    flex: 6
  }
  .item.xs-2 {
    flex: 2
  }
  .container.center {
    justify-content: center;
    align-items: center;
  }
  .item.kanban-column {
    align-self: flex-start;
  }
  `;
}

function priority(DS:DesignSystem) {
	return `.priority {
    font-weight: 800;
    font-family: 'Red Hat Mono', monospace;
    border-radius: ${DS.borderRadius}px;
    right: ${DS.gutters.md}px;
    bottom: ${DS.gutters.md}px;
    padding:  ${DS.gutters.md}px;
    background: ${DS.colors.green};
    color: ${DS.colors.white};
    font-size: ${DS.fontSizes.md}px;
  }`;
}

function tagList(DS:DesignSystem) {
	return `.tags {
    row-gap: ${DS.gutters.sm}px;
    column-gap: ${DS.gutters.sm}px;
    margin: ${DS.gutters.sm}px 0px;
    flex-wrap: wrap;
  }
  .tag {
    color: ${DS.colors.black};
    padding: ${DS.gutters.sm}px;
    font-size: ${DS.fontSizes.sm}px;
    border-radius: ${DS.borderRadius}px;
  }
  `;
}

function alphaColors(DS: DesignSystem) {
	const abcde = ['a', 'b', 'c', 'd', 'e'];
	const fghij = ['f', 'g', 'h', 'i', 'j'];
	const klmno = ['k', 'l', 'm', 'n', 'o'];
	const pqrs = ['p', 'g', 'r', 's'];
	const tvwxyz = ['u', 'v', 'w', 'y', 'x', 'z', 't'];
	return `
    ${abcde.map(l => `.${l}`).join(',')} {
      background: ${DS.colors.purple}
    }
    ${fghij.map(l => `.${l}`).join(',')} {
      background: ${DS.colors.lime}
    }
    ${klmno.map(l => `.${l}`).join(',')} {
      background: ${DS.colors.lime}
    }
    ${pqrs.map(l => `.${l}`).join(',')} {
      background: ${DS.colors.blue}
    }
    ${tvwxyz.map(l => `.${l}`).join(',')} {
      background: ${DS.colors.green}
    }
  `;
}

function kanbanColumn(DS:DesignSystem) {
	return `
    .kanban-column .title {
      position: relative;
      border: 1px solid ${DS.colors.white};
      min-height: 45px;
      line-height: 45px;
      display:block;
      border-radius: ${DS.borderRadius}px;
      width: 100%;
      padding: 0px ${DS.gutters.md}px;
      box-sizing: border-box;
      color: ${DS.colors.white};
      text-align: center;
      font-size: ${DS.fontSizes.sm}px;
      margin-bottom: ${DS.gutters.sm}px;
    }
    .kanban-column .tag-title {
      color: ${DS.colors.black};
      border: 0px;
    }
    .kanban-column .title .close {
      display:none;
      border: 0px;
      padding: 0px;
      position: absolute;
      right: 0px;
      top: ${DS.gutters.sm}px;
      background: transparent;
      color: ${DS.colors.black};
      cursor: pointer;
    }
    .kanban-column .title:hover .close {
      display:block;
    }
    .kanban-column,
    .kanban-column .todo {
      width: 300px;
      min-width: 300px;
      
    }
    .kanban-column {
      min-height: 80vh;
    }
    .kanban-column .container {
      padding: 0;
    }
    .add-column {
      width: 300px;
      display:block;
      font-size: ${DS.fontSizes.sm}px;
    }
  `;
}

export function globalStyles(DS: DesignSystem) {
	return `
    html,body {
      background-image: url('/grid.png');
      margin: 0;
      padding: 0;
      background-color: ${DS.colors.black};
      color:  ${DS.colors.white};
      opacity: 1;
      font-family: monospace
    }
    button {
      ${buttonStyle(DS)}
    }

    ul,li {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    textarea,
    input {
      border: 1px solid ${DS.colors.white};
      min-height: 45px;
      background: ${DS.colors.black};
      border-radius: ${DS.borderRadius}px;
      width: 100%;
      padding: 0px ${DS.gutters.md}px;
      box-sizing: border-box;
      color: ${DS.colors.white};
    }
    textarea {
      padding: ${DS.gutters.md}px;
    }
    ${gridSystem()}
    ${bgColorClass(DS)}
    .nav {
      background: ${DS.colors.black};
      padding: ${DS.gutters.sm / 3}px ${DS.gutters.md}px;
      border: 1px solid ${DS.colors.white};
      border-radius: 30px;
    }
    .nav .container {
      padding: 0px;
      row-gap: 0px;
      column-gap: 8px;
    }
    .nav li {
      display:inline-block;
      padding: 0px;
    }
    .nav li.active a {
      color:  ${DS.colors.green};
    }
    .nav li a {
      background: transparent;
      height: 100%;
      padding: 8px;
      color: ${DS.colors.white};
      display:inline-block;
    }
    .top-section {
      padding-bottom: 0;
    }
    @keyframes notification {
      from {bottom: -120vh;}
      to { bottom: 5vh; }
    }
    @keyframes notification-out {
      to {bottom: -5vh; display:none;}
      from {bottom: 5vh; display:block;}
    }
    .box {
      background: ${DS.colors.white};
      border-radius: ${DS.borderRadius}px;
      color: ${DS.colors.black};
      padding: ${DS.gutters.sm}px;
      position: relative;
    }
    .box p {
      margin: 0;
      padding: ${DS.gutters.sm}px;

    }
    .todo {
      position: relative;
      width: 100%;
    }
    .todo .container {
      padding: 0px;
    }
    .todo .text {
      font-size: ${DS.fontSizes.md}px;
      min-height: 58px;

    }
    .todo.completed {
      opacity: 1;
      filter:grayscale(100%);
    }
    .todo.completed .box {
      background: ${DS.colors.black};
      color: ${DS.colors.gray};
      border: 1px solid;
    }
    .timestamp {
      font-size: ${DS.fontSizes.sm}px;
    }
    ${tagList(DS)}
    ${priority(DS)}
    ${kanbanColumn(DS)}
    ${alphaColors(DS)}
  `;
}

export function getRandomColorClass() {
	const list = Object.keys(DS.colors).filter(k => k !== 'white' && k !== 'black').map(k => `bg-${k}`);
	return list[Math.floor((Math.random() * list.length))];
}

export function notificationStyle() {
	STYLES.add('notificationStyle', `
  .notification {
    background: #fff;
    box-shadow: ${DS.gutters.sm}px ${DS.gutters.sm}px 0px #000;
    position:fixed;
    left: 0px;
    right: 0px;
    margin: 0 auto;
    font-size: ${DS.fontSizes.md}px;
    padding: ${DS.gutters.md}px;
    width: 320px;
    text-align:center;
    transition: ease all 0.3s;
    bottom: -10vh;
    height: 0px;
    }
    .notification.show {
      transition: ease all 0.3s;
      bottom: ${DS.gutters.lg}px;
      height: auto;
    }
  `, window.document.createElement('style'), true);
}
