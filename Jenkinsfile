pipeline {
  agent any
  stages {
    stage('Init') {
      steps {
        echo 'Initializing Pipeline'
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
            httpRequest 'http://vengauto1:3000/api/devops/settings/5bc7606cb02e7c16941bf570'
          }
        }
      }
    }
    stage('Run Powershell') {
      steps {
        echo 'Check Params'
        powershell(script: 'testps.ps1', returnStatus: true, returnStdout: true)
      }
    }
  }
}