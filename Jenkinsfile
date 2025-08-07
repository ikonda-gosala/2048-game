pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "yourdockerhub/2048-game:latest"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
        GIT_REPO_DOCKER = "https://github.com/your-org/2048-docker-repo.git"
        GIT_REPO_TERRAFORM = "https://github.com/your-org/minikube-terraform.git"
        GIT_REPO_K8S = "https://github.com/your-org/2048-k8s-deployment.git"
    }

    stages {
        stage("Clone Dockerfile Repo") {
            steps {
                git url: "${GIT_REPO_DOCKER}", branch: "main"
            }
        }

        stage("Build Docker Image") {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage("Push Docker Image to Registry") {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage("Clone Terraform Repo") {
            steps {
                dir("terraform") {
                    git url: "${GIT_REPO_TERRAFORM}", branch: "main"
                }
            }
        }

        stage("Create Minikube Cluster with Terraform") {
            steps {
                dir("terraform") {
                    sh """
                        terraform init
                        terraform plan
                        terraform apply --auto-approve
                    """
                }
            }
        }

        stage("Clone Kubernetes Manifests Repo") {
            steps {
                dir("k8s") {
                    git url: "${GIT_REPO_K8S}", branch: "main"
                }
            }
        }

        stage("Apply Kubernetes Manifests") {
            steps {
                dir("k8s") {
                    sh """
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed. Check logs for details.'
        }
    }
}
