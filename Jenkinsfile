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
        stage('APICall') {
          steps {
            script {
              httpRequest(url: 'http://vengauto1:3000/api/devops/settings/5bc7606cb02e7c16941bf570', acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', httpMode: 'GET', responseHandle: 'STRING', validResponseCodes: '200', outputFile: 'settings.json')
              def myFile = readFile 'settings.json'
              echo "${myFile}"
            }

          }
        }
        stage('PS') {
          steps {
            script {
              def file2 = "\"${WORKSPACE}\\start.ps1\""
              echo "${file2}"
              def stat = powershell(script: "${file2}", returnStatus: false, returnStdout: true)
              echo "stat: ${stat}"
            }

          }
        }
        stage('PS') {
          steps {
            script {
              def file2 = "\"${WORKSPACE}\\start.ps1\""
              echo "${file2}"
              def stat = powershell(script: "${file2}", returnStatus: false, returnStdout: true)
              echo "stat: ${stat}"
            }

          }
        }
        stage('powershell') {
          steps {
            powershell '.\\\\start.ps1'
            powershell '.\\\\ping-something.ps1 asdasd'
            powershell 'Import-Module -Name .\\\\Automation-Module.psm1 -Verbose'
            powershell 'Get-Command Ping-Localhost'
          }
        }
        stage('ping') {
          steps {
            script {
              def ping = powershell(script: 'ping localhost', returnStatus: false, returnStdout: true)
              echo "ping: ${ping}"
            }

          }
        }
      }
    }
  }
}