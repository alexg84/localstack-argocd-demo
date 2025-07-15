from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello_world():
    return '''
    <html>
        <head>
            <title>Hello World App</title>
            <style>
                body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
                h1 { color: #333; }
                p { color: #666; }
            </style>
        </head>
        <body>
            <h1>Hello World!</h1>
            <p>This is a simple Flask application running in Kubernetes</p>
            <p>Deployed with ArgoCD and provisioned with Crossplane</p>
        </body>
    </html>
    '''

@app.route('/health')
def health_check():
    return {'status': 'healthy', 'message': 'Application is running'}

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)