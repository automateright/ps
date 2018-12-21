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
        stage('PS') {
          steps {
            script {
              echo 'PS Call'
              def file2 = "\"${WORKSPACE}\\Ping-Something.ps1\""
              echo "${file2}"
              def stat = powershell(script: "Import-Module -Name ${file2} -Scope Global -Force -Verbose", returnStatus: false, returnStdout: true)
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
              def ret = powershell(script: "${file3}", returnStatus: true, returnStdout: false)
              echo "ret: ${ret}"
            }

          }
        }
        stage('ping') {
          steps {
            sh 'ping localhost'
          }
        }
      }
    }
  }
}