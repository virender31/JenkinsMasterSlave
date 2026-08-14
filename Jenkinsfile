// Jenkins Master-Slave Pipeline
// Build runs on Node A (Linux), Test runs on Node B (Mac)
// Uses stash/unstash since each agent has its own isolated workspace

pipeline {
    agent none

    options {
        timestamps()
    }

    stages {
        stage('Build') {
            agent { label 'linux-node' }
            steps {
                checkout scm
                echo "Running BUILD stage on Node A (Linux) - host: ${env.NODE_NAME}"
                sh 'chmod +x sample-app/build.sh'
                sh './sample-app/build.sh'
                stash includes: 'build/**', name: 'build-artifacts'
            }
        }

        stage('Test') {
            agent { label 'mac-node' }
            steps {
                checkout scm
                echo "Running TEST stage on Node B (Mac) - host: ${env.NODE_NAME}"
                unstash 'build-artifacts'
                sh 'chmod +x sample-app/test.sh'
                sh './sample-app/test.sh'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully: Build (Linux) -> Test (Mac)'
        }
        failure {
            echo 'Pipeline failed - check the console log for the failing stage'
        }
    }
}
