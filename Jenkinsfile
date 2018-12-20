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
            echo 'API Call'
            httpRequest(url: 'http://vengauto1:3000/api/devops/settings/5bc7606cb02e7c16941bf570', acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', httpMode: 'GET', responseHandle: 'STRING', validResponseCodes: '200')
          }
        }
      }
    }
    stage('Run Powershell') {
      steps {
        echo 'Run PowerShell'
        script {
          def expol=powershell(script: "Get-ExecutionPolicy", returnStatus: false, returnStdout: true)
          echo "${expol}"

          def file = "\"${WORKSPACE}\\start.ps1\""
          echo "${file}"
          def stat0 = powershell(script: "${file}", returnStatus: false, returnStdout: true)
          echo "stat0: ${stat0}"

          def file2 = "\"${WORKSPACE}\\Automation-Module.psm1\""
          echo "${file2}"
          def stat = powershell(script: "Import-Module ${file2}", returnStatus: false, returnStdout: true)
          echo "stat: ${stat}"

          def mods=powershell(script: "Get-Module", returnStatus: false, returnStdout: true)
          echo "${mods}"


          def stat2 = powershell(script: "Ping-Localhost", returnStatus: false, returnStdout: true)
          echo "stat2: ${stat2}"
        }

      }
    }
  }
}