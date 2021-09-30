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
      updateGitlabCommitStatus name: 'jenkins', state: 'failed'
    }
    unstable {
      updateGitlabCommitStatus name: 'jenkins', state: 'failed'
    }
    aborted {
      updateGitlabCommitStatus name: 'jenkins', state: 'canceled'
    }
    success {
      updateGitlabCommitStatus name: 'jenkins', state: 'success'
    }
    always {
      cleanWs()
    }
  }
  agent {
    docker {
      image 'containers.cr.imson.co/cr.imson.co/docker-homelab-ci'
      registryUrl 'https://containers.cr.imson.co/'
      registryCredentialsId 'f8a2eb1f-3ccc-4dff-ad31-f3d7987f81c0'
    }
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
        stage('rubocop checks') {
          steps {
            sh """
              rubocop \
                -c ${env.WORKSPACE}/cookbooks/.rubocop.yml \
                --cache false
            """.stripIndent()
          }
        }
      }
    }
  }
}
