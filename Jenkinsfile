pipeline {
  agent any
  stages {
    stage('Init') {
      steps {
        echo 'Initializing Pipeline'
        echo "Workspace:${WORKSPACE}"
        input(message: 'Need input to get started', id: 'ejm1', submitter: 'ok', submitterParameter: '531.137')
      }
    }
    stage('Interactive_Input') {
      steps {
        script {
          def inputConfig
          def inputTest

          // Get the input
          def userInput = input(
            id: 'userInput', message: 'Enter path of test reports:?',
            parameters: [

              string(defaultValue: 'None',
              description: 'Path of config file',
              name: 'Config'),
              string(defaultValue: 'None',
              description: 'Test Info file',
              name: 'Test'),
            ])

            // Save to variables. Default to empty string if not found.
            inputConfig = userInput.Config?:''
            inputTest = userInput.Test?:''

            // Echo to console
            echo("IQA Sheet Path: ${inputConfig}")
            echo("Test Info file path: ${inputTest}")

            // Write to file
            writeFile file: "inputData.txt", text: "Config=${inputConfig}\r\nTest=${inputTest}"

            // Archive the file (or whatever you want to do with it)
            archiveArtifacts 'inputData.txt'
          }

        }
      }
      stage('Checking Environment') {
        parallel {
          stage('Stage 1') {
            steps {
              echo 'Initializing Pipeline'
              echo "Workspace:${WORKSPACE}"
            }
          }
          stage('Stage 2') {
            steps {
              echo 'Initializing Pipeline'
              echo "Workspace:${WORKSPACE}"
            }
          }
        }
      }
      stage('API Calls') {
        parallel {
          stage('Get Parms') {
            steps {
              script {
                httpRequest(url: 'http://vengauto1:3000/api/devops/settings/5bc7606cb02e7c16941bf570', acceptType: 'APPLICATION_JSON', consoleLogResponseBody: true, contentType: 'APPLICATION_JSON', httpMode: 'GET', responseHandle: 'STRING', validResponseCodes: '200', outputFile: 'settings.json')
                def myFile = readFile 'settings.json'
                echo "${myFile}"
              }

            }
          }
          stage('stage a') {
            steps {
              script {
                def file2 = "\"${WORKSPACE}\\start.ps1\""
                echo "${file2}"
                def stat = powershell(script: "${file2}", returnStatus: false, returnStdout: true)
                echo "stat: ${stat}"
              }

            }
          }
          stage('stage b') {
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
              powershell '''
              Import-Module -Name .\\\\Automation-Module.psm1 -Verbose
              Get-Command Ping-Localhost
              Ping-Localhost asdasd
            '''
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
      stage('Closing') {
        parallel {
          stage('Stage 1 closing') {
            steps {
              echo 'Initializing Pipeline'
              echo "Workspace:${WORKSPACE}"
            }
          }
          stage('Stage 2 closing') {
            steps {
              echo 'Initializing Pipeline'
              echo "Workspace:${WORKSPACE}"
            }
          }
        }
      }
    }
  }