import webview

def load_css(window):
    window.load_css(r"""
    """)

def evaluate_js(window):
    window.evaluate_js(
        r"""
        window.addEventListener('pywebviewready', function() {
            console.log('@pywebview is ready', pywebview.api)
        })

        function getImage() { 
            pywebview.api.getImage().then((response) => {
                response.result;
            }) 
        }
        function saveFile() { 
            pywebview.api.saveFile("exampleFilename", "whater").then((response) => {
                return response.result;
            }) 
        }
        """
    )
def load_api(window):
    evaluate_js(window)
    load_css(window)
    
class Api:
    # function available pywebview.api.X

    def saveFile(self, filename, fileContent):
        result = window.create_file_dialog(webview.SAVE_DIALOG, directory='~/', save_filename=filename)
        path = "".join(result)
        file = open(path, 'w')
        file.write(fileContent)
        file.close()
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