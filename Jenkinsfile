pipeline {
  agent any
  stages {
    stage('Init') {
      steps {
        echo 'Initializing Pipeline'
        echo "Workspace:${WORKSPACE}"
        sh 'java -version'
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
              def file2 = "\"${WORKSPACE}\\Automation-Module.psm1\""
              echo "${file2}"
              def stat = powershell(script: "Install-Module ${file2} -Force -Scope CurrentUser -Verbose", returnStatus: false, returnStdout: true)
              echo "stat: ${stat}"

              def mods = powershell(script: "Get-Command Ping-Localhost", returnStatus: false, returnStdout: true)
              echo "mods: ${mods}"

              def stat2 = powershell(script: "Ping-Localhost asdf", returnStatus: false, returnStdout: true)
              echo "stat2: ${stat2}"
            }

          }
        }
        stage('psui') {
          steps {
            script {
              def file3 = "\"${WORKSPACE}\\Start.ps1\""
              def ret = powershell(script: "${file3}", returnStatus: false, returnStdout: true)
              echo "ret: ${ret}"
            }

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