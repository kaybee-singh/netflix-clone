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
                // Ensure this URL is correct for your repo
                git branch: 'main', url: 'https://github.com/kaybee-singh/netflix-clone/'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    echo "Building Docker Image locally on EC2..."
                    // Building with sudo as required
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
                    echo "Generating temporary Kubeconfig file..."
                    // We save the config to a file in the workspace
                    sh "sudo kind get kubeconfig --name ${CLUSTER_NAME} --internal > jenkins-kube.config"
                    // Make it readable for the next command
                    sh "sudo chmod 666 jenkins-kube.config"

                    echo "Applying Deployment and Service..."
                    // We use --kubeconfig FLAG to bypass the Jenkins port conflict (8080)
                    // We use --validate=false to skip the OpenAPI check that causes the HTML error
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
                    // Using the flag here as well for consistency
                    sh "sudo kubectl rollout status deployment/netflix-deployment --kubeconfig=jenkins-kube.config"
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Final Pod Status Check..."
                // Check pods one last time using the local config
                sh "sudo kubectl get pods --kubeconfig=jenkins-kube.config"
                // Cleanup the config file
                sh "rm -f jenkins-kube.config"
            }
        }
    }
}
