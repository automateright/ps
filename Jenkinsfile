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
            httpRequest(url: 'http://vengauto1:3000/api/devops/settings/5bc7606cb02e7c16941bf570', acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', httpMode: 'GET', responseHandle: 'STRING', validResponseCodes: '200', outputFile: 'settings.json')
            readFile 'settings.json'
          }
        }
        stage('PS') {
          steps {
            script {
              def file2 = "\"${WORKSPACE}\\Ping-Something.ps1\""
              echo "${file2}"
              def stat = powershell(script: "Install-Module ${file2}", returnStatus: false, returnStdout: true)
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