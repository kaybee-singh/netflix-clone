pipeline {
    agent any

    environment {
        APP_NAME = "netflix-clone"
        IMAGE_NAME = "netflix:local"
        // The port your EC2 will expose to the internet
        HOST_PORT = "80" 
        // The port your app is listening on inside the container
        CONTAINER_PORT = "80" 
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                echo "Cleaning up previous build files..."
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/kaybee-singh/netflix-clone/'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    echo "Building Docker Image..."
                    sh "sudo docker build -t ${IMAGE_NAME} -f Containerfile ."
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    echo "Removing old container if it exists..."
                    // '|| true' ensures the pipeline doesn't fail if the container isn't there yet
                    sh "sudo docker stop ${APP_NAME} || true"
                    sh "sudo docker rm ${APP_NAME} || true"

                    echo "Starting new container on port ${HOST_PORT}..."
                    sh "sudo docker run -d --name ${APP_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_NAME}"
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "Waiting for app to start..."
                    sleep 5
                    sh "sudo docker ps"
                    // Check if the app is responding locally
                    sh "curl -I http://localhost:${HOST_PORT} || echo 'Warning: Localhost check failed'"
                }
            }
        }
    }

    post {
        success {
            echo "-----------------------------------------------------------"
            echo "SUCCESS! Access your app at: http://your-ec2-public-ip"
            echo "-----------------------------------------------------------"
        }
    }
}
