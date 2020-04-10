#!groovy

pipeline {
  options {
    gitLabConnection('gitlab@cr.imson.co')
    gitlabBuilds(builds: ['jenkins'])
    disableConcurrentBuilds()
    timestamps()
  }
  post {
    failure {
      mattermostSend color: 'danger', message: "Build failed: [${env.JOB_NAME}${env.BUILD_DISPLAY_NAME}](${env.BUILD_URL}) - @channel"
      updateGitlabCommitStatus name: 'jenkins', state: 'failed'
    }
    unstable {
      mattermostSend color: 'warning', message: "Build unstable: [${env.JOB_NAME}${env.BUILD_DISPLAY_NAME}](${env.BUILD_URL}) - @channel"
      updateGitlabCommitStatus name: 'jenkins', state: 'failed'
    }
    aborted {
      updateGitlabCommitStatus name: 'jenkins', state: 'canceled'
    }
    success {
      mattermostSend color: 'good', message: "Build completed: [${env.JOB_NAME}${env.BUILD_DISPLAY_NAME}](${env.BUILD_URL})"
      updateGitlabCommitStatus name: 'jenkins', state: 'success'
    }
    always {
      cleanWs()
    }
  }
  agent {
    label 'dockerhost'
  }
  environment {
    CI = 'true'
  }
  stages {
    stage('Prepare') {
      steps {
        updateGitlabCommitStatus name: 'jenkins', state: 'running'
      }
    }

    stage('QA') {
      parallel {
        stage('bash syntax checks') {
          steps {
            sh 'find . -type f -iname "*.sh" -print0 | xargs -0 bash -n'
          }
        }
        stage('docker-compose syntax checks') {
          steps {
            sh 'find . -type f -iname "*docker-compose.yml" -print0 | xargs -n 1 -0 -I \'{}\' docker-compose -f {} config -q'
          }
        }
      }
    }
  }
}
