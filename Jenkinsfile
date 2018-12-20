pipeline {
  agent any
  stages {
    stage('Init') {
      steps {
        echo 'Initializing Pipeline'
      }
    }
    stage('') {
      steps {
        powershell(returnStatus: true, returnStdout: true, script: 'Write-Host "hello world"')
      }
    }
  }
}