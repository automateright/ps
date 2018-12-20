import groovy.json.JsonSlurperClassic 
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
            def response = httpRequest(url: 'http://vengauto1:3000/api/devops/settings/5bc7606cb02e7c16941bf570', acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', httpMode: 'GET', responseHandle: 'STRING')
            println("Status: "+response.status)
            println("Content: "+response.content)
            //def json = new JsonSlurperClassic().parseText(response.content)            
            //assert json instanceof Map
            //echo "EnvName: ${json.data.env.name}"
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
