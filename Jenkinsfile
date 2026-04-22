pipeline {
    agent any

    environment {
        APP_NAME = "netflix-clone"
        IMAGE_NAME = "netflix:local"
        CLUSTER_NAME = "bootcamp-cluster"
    }

    stages {
        stage('Cleanup') {
            steps {
                echo "Cleaning up previous workspace..."
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                // This clones your repo into the Jenkins workspace
                git branch: 'main', url: 'https://github.com/kaybee-singh/netflix-clone/'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    echo "Building Docker Image locally on EC2..."
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Load Image into Kind') {
            steps {
                script {
                    echo "Sideloading image into Kind nodes (fixing the 'not found' error)..."
                    // This moves the image from the EC2 host into the Kind cluster nodes
                    sh "kind load docker-image ${IMAGE_NAME} --name ${CLUSTER_NAME}"
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                script {
                    echo "Applying Deployment and Service..."
                    sh "kubectl apply -f deployment.yaml"
                    
                    echo "Restarting deployment to show rolling update..."
                    // This ensures K8s picks up the newly loaded 'local' image
                    sh "kubectl rollout restart deployment/netflix-deployment"
                }
            }
        }

        stage('Verify Rollout') {
            steps {
                echo "Monitoring the Wow Moment..."
                sh "kubectl rollout status deployment/netflix-deployment"
            }
        }
    }

    post {
        always {
            sh "kubectl get pods"
        }
    }
}
