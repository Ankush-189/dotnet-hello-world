pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        AWS_CREDENTIALS = credentials('aws-credentials')
        DOCKER_IMAGE = "your-dockerhub-username/dotnet-hello-world"
        DOCKER_TAG = "latest"
    }
    
    parameters {
        choice(
            choices: ['production'],
            description: 'Select environment to deploy',
            name: 'DEPLOY_ENV'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                url: 'https://github.com/Ankush-189/dotnet-hello-world.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'dotnet restore'
                sh 'dotnet build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'dotnet test'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${env.DOCKER_IMAGE}:${env.DOCKER_TAG}")
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                        docker.image("${env.DOCKER_IMAGE}:${env.DOCKER_TAG}").push()
                    }
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                expression { params.DEPLOY_ENV == 'production' }
            }
            steps {
                script {
                    def dockerRunCommand = """
                        docker run -d \
                        --name dotnet-hello-world \
                        -p 80:80 \
                        ${env.DOCKER_IMAGE}:${env.DOCKER_TAG}
                    """
                    
                    sshagent(['aws-ssh-credentials']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${env.PRODUCTION_IP} \
                            "docker pull ${env.DOCKER_IMAGE}:${env.DOCKER_TAG} && \
                            docker stop dotnet-hello-world || true && \
                            docker rm dotnet-hello-world || true && \
                            ${dockerRunCommand}"
                        """
                    }
                }
            }
        }
        
        stage('Health Check') {
            when {
                expression { params.DEPLOY_ENV == 'production' }
            }
            steps {
                script {
                    // Wait for application to start
                    sleep time: 30, unit: 'SECONDS'
                    
                    // Health check
                    sh """
                        curl -f http://${env.PRODUCTION_IP}/weatherforecast || exit 1
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
