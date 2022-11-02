import webview

def load_css(window):
    window.load_css(r"""
        body,html {
        margin: 0;
        padding: 0;
        background-color: #F4BE9A;
        color: #d2607e;
        font-family: silk_flower;
        font-size: 16vw;
        position: relative;
        width:100vw;
        height:100vh;
        overflow: hidden;
    }

    img {
        width: auto;
        margin: 0 auto;
        left: 0;
        right: 0;
        top: 0;
        height: 100%;
        z-index: 1;
        position: absolute;
    }

    button {
        position: relative;
        z-index: 2;
        font-size: 100%;
        margin: 0vh auto;
        height: 50vh;
        width: 100%;
        text-transform: uppercase;
        background-color: transparent;
        border: 0;
    }
    button:hover {
        color: #df7d69;
        cursor: pointer;
    }
    @font-face {
        font-family: silk_flower;
        src: url("silk_flower.otf") format("opentype");
    }
    * {
        font-family: silk_flower;
        color: #d2607e;
    }
    
    """)

def evaluate_js(window):
    window.evaluate_js(
        r"""
        window.addEventListener('pywebviewready', function() {
            console.log('@pywebview is ready', pywebview.api)
        })

        function getImage() { pywebview.api.getImage().then((response) => {
            const fish = document.createElement('img');
            fish.src = response.result;
            document.body.appendChild(fish)
        }) 
        }
        function saveFile() { pywebview.api.saveFile("exampleFilename").then((response) => {
            const fish = document.createElement('div');
            fish.innerHTML = response.result;
            document.body.appendChild(fish)
        }) 
        }
        """
    )
def load_api(window):
    evaluate_js(window)
    load_css(window)
    
class Api:
    # function available pywebview.api.X

    def saveFile(self, filename):
        result = window.create_file_dialog(webview.SAVE_DIALOG, directory='/', save_filename=filename)
        response = {
            'result': result
        }
        return response


    def getImage(self):
        file_types = ('Image Files (*.bmp;*.jpg;*.gif)', 'All files (*.*)')
        result = window.create_file_dialog(webview.OPEN_DIALOG, allow_multiple=True, file_types=file_types)
        response = {
            'result': result
        }
        return response

if __name__ == '__main__':
    api = Api()
    window = webview.create_window('API example', 'www/index.html', js_api=api)
    webview.start(load_api, window)