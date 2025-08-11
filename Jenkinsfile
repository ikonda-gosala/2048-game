pipeline {
    agent any

    environment {
        EKS_CLUSTER_NAME = "my_cluster"
        AWS_REGION = "us-east-1"
        DOCKER_IMAGE = "konda33/2048-game:${BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
        AWS_CREDENTIALS = "aws_credentials"
        GIT_REPO_DOCKER = "https://github.com/ikonda-gosala/2048-game.git"
        GIT_REPO_TERRAFORM = "https://github.com/ikonda-gosala/2048-game-tf-files.git"
        GIT_REPO_K8S = "https://github.com/ikonda-gosala/2048-game-k8s.git"
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
        
        stage("Validate AWS Credentials") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: 'aws_credentials']]) {
                    sh '''
                        echo "Validating AWS credentials..."
                        aws sts get-caller-identity
                    '''
                }
            }
        }


        stage("Create EKS Cluster with Terraform files") {
            steps {
                dir("terraform") {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',credentialsId: "${AWS_CREDENTIALS}" ]]){
                    sh """
                        terraform init
                        terraform plan
                        terraform apply --auto-approve
                    """
                    }
                }
            }
        }
        stage("Update the kubeconfig command.") {
        steps {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS}"]]) {
                sh """
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    export AWS_DEFAULT_REGION=${AWS_REGION}
                    aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}
                    kubectl get nodes
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
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS}"]]) {
                dir("k8s") {
                    sh """
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        export AWS_DEFAULT_REGION=${AWS_REGION}
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                    """
                    }
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
