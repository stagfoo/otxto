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
        """
    )
def load_api(window):
    evaluate_js(window)
    load_css(window)
    
class Api:
    openFile = ''
    # function available pywebview.api.X
    

    def saveFile(self, filename, fileContent):
        print('--------')
        print(filename)
        print('--------')
        file = open('.task/example.txt', 'w')
        file.write(fileContent)
        file.close()
        response = {
            'result': result
        }
        return response


    def getFile(self):
        file_types = ('Txt Files (*.txt)', 'All files (*.*)')
        result = window.create_file_dialog(webview.OPEN_DIALOG, allow_multiple=False, file_types=file_types)
        print(result[0])
        file = open(result[0], 'r')
        response = {
            'path': result[0],
            'fileContent': file.read()
        }
        file.close()
        return response

if __name__ == '__main__':
    api = Api()
    window = webview.create_window('otxto', 'chumbucket/dist/index.html', js_api=api)
    webview.start(load_api, window, debug=True)