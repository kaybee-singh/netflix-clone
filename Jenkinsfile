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
                // Ensure your GitHub URL is correct
                git branch: 'main', url: 'https://github.com/kaybee-singh/netflix-clone/'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    echo "Building Docker Image locally on EC2..."
                    // Using Containerfile as per your setup
                    sh "sudo docker build -t ${IMAGE_NAME} -f Containerfile ."
                }
            }
        }

        stage('Load Image into Kind') {
            steps {
                script {
                    echo "Sideloading image into Kind nodes..."
                    sh "sudo kind load docker-image ${IMAGE_NAME} --name ${CLUSTER_NAME}"
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                script {
                    echo "Generating Kubeconfig (Host-Accessible)..."
                    // Removed --internal to force the use of 127.0.0.1 instead of the container name
                    sh "sudo kind get kubeconfig --name ${CLUSTER_NAME} > jenkins-kube.config"
                    sh "sudo chmod 666 jenkins-kube.config"

                    echo "Applying Deployment and Service..."
                    // Using the flag ensures we hit Kind and NOT Jenkins port 8080
                    sh """
                        sudo kubectl apply -f deployment.yaml --kubeconfig=jenkins-kube.config --validate=false
                        sudo kubectl rollout restart deployment/netflix-deployment --kubeconfig=jenkins-kube.config
                    """
                }
            }
        }

        stage('Verify Rollout') {
            steps {
                script {
                    echo "Monitoring the Rolling Update..."
                    sh "sudo kubectl rollout status deployment/netflix-deployment --kubeconfig=jenkins-kube.config"
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Final Pod Status..."
                // Use the local config for the final status check
                sh "sudo kubectl get pods --kubeconfig=jenkins-kube.config"
                // Delete the temporary config for safety
                sh "rm -f jenkins-kube.config"
            }
        }
    }
}
