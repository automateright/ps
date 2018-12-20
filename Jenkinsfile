pipeline {
  agent any
  stages {
    stage('Init') {
      steps {
        echo 'Initializing Pipeline'
        echo 'Workspace:${WORKSPACE}'
      }
    }
    stage('Get Params') {
      parallel {
        stage('Get Params') {
          steps {
            powershell(returnStatus: true, returnStdout: true, script: 'Write-Host "hello world"')
          }
        }
        stage('APICall') {
          steps {
            echo 'API Call'
            httpRequest(url: 'http://vengauto1:3000/api/devops/settings/5bc7606cb02e7c16941bf570', acceptType: 'APPLICATION_JSON', contentType: 'APPLICATION_JSON', httpMode: 'GET', responseHandle: 'STRING', validResponseCodes: '200', outputFile: 'response.txt')
          }
        }
      }
    }
    stage('Run Powershell') {
      steps {
        echo 'Check Params'
        powershell(script: '${WORKSPACE}\\start.ps1', returnStatus: true, returnStdout: true)
      }
    }
  }
}