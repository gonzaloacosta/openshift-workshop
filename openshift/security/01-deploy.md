# Deploy App
oc new-project flask --description="Python Flask App" --display-name="Flask App"
oc new-app --strategy=source python:3.5~https://github.com/RedHatGov/OCP-App.git --name=flask-app
oc logs -f bc/flask-app
