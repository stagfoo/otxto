import webview
class Api:
    openFile = ''
    # function available pywebview.api.X
    

    def saveFile(self, filename, fileContent):
        print('--------')
        print(filename)
        print('--------')
        file = open(filename, 'w')
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
    window = webview.create_window('otxto', './chumbucket/dist/index.html', js_api=api)
    #js_api=api doesnt work with http_server=True so you have to expose the function manually
    window.expose(api.saveFile, api.getFile)
    webview.start(http_server=True, debug=True)