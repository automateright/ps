pipeline {
  agent any
  stages {
    stage('PS 2') {
      steps {
        echo 'PS2 '
        echo "Workspace:${WORKSPACE}"
      }
    }
    stage('Checking Environment PS2') {
      parallel {
        stage('Stage 1 ps2') {
          steps {
            echo 'Initializing Pipeline'
            echo "Workspace:${WORKSPACE}"
          }
        }
        stage('Stage 2 ps2') {
          steps {
            echo 'Initializing Pipeline'
            echo "Workspace:${WORKSPACE}"
          }
        }
      }
    }
  }
}