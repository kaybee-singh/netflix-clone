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
                git branch: 'main', url: 'https://github.com/kaybee-singh/netflix-clone/'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    echo "Building Docker Image locally on EC2..."
                    // Added sudo as requested, using Containerfile
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
                    echo "Generating temporary Kubeconfig..."
                    // This creates a local config file so kubectl knows where the Kind cluster is
                    sh "sudo kind get kubeconfig --name ${CLUSTER_NAME} --internal > jenkins-kube.config"
                    sh "sudo chmod 666 jenkins-kube.config"

                    echo "Applying Deployment and Service..."
                    // Added --validate=false to bypass the Jenkins login/port conflict error
                    sh """
                        export KUBECONFIG=jenkins-kube.config
                        sudo kubectl apply -f deployment.yaml --validate=false
                        sudo kubectl rollout restart deployment/netflix-deployment
                    """
                }
            }
        }

        stage('Verify Rollout') {
            steps {
                script {
                    echo "Monitoring the Wow Moment..."
                    sh "export KUBECONFIG=jenkins-kube.config && sudo kubectl rollout status deployment/netflix-deployment"
                }
            }
        }
    }

    post {
        always {
            script {
                // Ensure we use the local config for the final pod check
                sh "export KUBECONFIG=jenkins-kube.config && sudo kubectl get pods"
                sh "rm -f jenkins-kube.config"
            }
        }
    }
}
