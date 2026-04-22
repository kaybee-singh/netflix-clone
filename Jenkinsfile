pipeline {
    agent any

    environment {
        APP_NAME = "netflix-clone"
        IMAGE_NAME = "netflix:local"
        CLUSTER_NAME = "bootcamp-cluster"
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                // Replace with your actual repo URL
                git branch: 'main', url: 'https://github.com/kaybee-singh/netflix-clone'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    echo "Building Docker Image locally..."
                    // We build with a local tag to avoid registry dependencies
                    sh "docker build -t ${IMAGE_NAME} -f Containerfile ."
                }
            }
        }

        stage('Load Image into Kind') {
            steps {
                script {
                    echo "Loading image into Kind nodes... (No internet needed)"
                    // This is the most robust part of the demo
                    sh "kind load docker-image ${IMAGE_NAME} --name ${CLUSTER_NAME}"
                }
            }
        }

        stage('Deploy/Update K8s') {
            steps {
                script {
                    echo "Triggering Rolling Update..."
                    // First time: apply the manifest. Subsequent times: update image
                    sh "kubectl apply f deployment.yaml"
                    
                    // Force a restart to show the rolling update visually even if 
                    // the image tag remains 'latest' or 'local'
                    sh "kubectl rollout restart deployment/netflix-deployment"
                }
            }
        }

        stage('Verify Health') {
            steps {
                script {
                    echo "Waiting for pods to stabilize..."
                    sh "kubectl rollout status deployment/netflix-deployment"
                }
            }
        }
    }

    post {
        success {
            echo "Demo Successful! Refresh your browser now."
        }
        failure {
            echo "Something went wrong. Check 'kubectl get pods' or Jenkins logs."
        }
    }
}
