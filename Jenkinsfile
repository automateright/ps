pipeline {
  agent any
  stages {
    stage('Init') {
      steps {
        echo 'Initializing Pipeline'
        echo "Workspace:${WORKSPACE}"
      }
    }
    stage('Get Params') {
      parallel {
        stage('Get Params') {
          steps {
            powershell(returnStatus: true, returnStdout: true, script: 'Write-Host "hello world"')
            script {
              def name = 'Guillaume' // a plain string
              def greeting = "Hello ${name}"
              echo greeting
            }

          }
        }
        stage('APICall') {
          steps {
            script {
              echo 'API Call'
              def response = httpRequest(url: 'http://vengauto1:3000/api/devops/settings/5bc7606cb02e7c16941bf570', acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', httpMode: 'GET', responseHandle: 'STRING', validResponseCodes: '200')

              echo "${response}"
              echo "${response.data.env}"
            }

          }
        }
      }
    }
  }
}