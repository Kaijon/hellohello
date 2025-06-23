pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile' // Specifies the Dockerfile to use (defaults to 'Dockerfile')
            dir '.'              // Specifies the directory where the Dockerfile is located (defaults to '.' for workspace root)
            args '-v ${WORKSPACE}/ca42-automation:/app'
        }
    }
    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                sh 'ls -l'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
