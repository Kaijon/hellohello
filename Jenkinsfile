pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                git 'https://github.com/Kaijon/hellohello.git'
                dir('hellohello') {
                    echo 'Listing files in the cloned repository:'
                    sh 'ls -l' // Use sh 'ls -l' for shell commands

                    echo 'Compiling hello.cpp:'
                    sh 'g++ hello.cpp -o hellokc'
                }
                sh 'g++ hello.cpp -o hellokc'                
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
