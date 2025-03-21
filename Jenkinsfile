
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "weather_data_pipeline_doc_image"
        ACR_NAME = "weatheracrname" // Replace with your Azure Container Registry name
        ACR_LOGIN_SERVER = "weatheracrname.azurecr.io"
        AKS_CLUSTER = "myWeatherDataAKSCluster"
        RESOURCE_GROUP = "Azure_Df_rg"
        DAG_ID = "weather_data_dag"
        AIRFLOW_URL = "http://your-airflow-url/api/v1/dags/$DAG_ID/dagRuns"
        AIRFLOW_TOKEN = credentials('AIRFLOW_API_TOKEN') // Store Airflow API token in Jenkins credentials
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/Varsha1603/weather_data_sf.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t $DOCKER_IMAGE .
                    docker tag $DOCKER_IMAGE $ACR_LOGIN_SERVER/$DOCKER_IMAGE:latest
                    """
                }
            }
        }

        stage('Push to Azure Container Registry (ACR)') {
            steps {
                script {
                    sh """
                    az acr login --name $ACR_NAME
                    docker push $ACR_LOGIN_SERVER/$DOCKER_IMAGE:latest
                    """
                }
            }
        }

        stage('Deploy to AKS') {
            steps {
                script {
                    sh """
                    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER
                    kubectl apply -f k8s-deployment.yaml
                    """
                }
            }
        }

        stage('Trigger Airflow DAG') {
            steps {
                script {
                    sh """
                    curl -X POST "$AIRFLOW_URL" -H "Authorization: Bearer $AIRFLOW_TOKEN" -H "Content-Type: application/json" --data '{}'
                    """
                }
            }
        }
    }
}
