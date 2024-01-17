# kubectl
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv./kubectl /usr/local/bin
kubectl version -short-client
# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
# create eks cluster
eksctl create cluster \
--name my-eks-cluster \
--region=ap-south-1 \
--zone=ap-south-1a,ap-south-1b \
--without-nodegroup
eksctl utils associate-iam-oidc-provider \
--region ap-south-1 \
--cluster my-eks-cluster
--approve

eksctl create nodegroup --cluster=my-eks-cluster \
--region-ap-south-1 \
--name=node2
--node-type=t3.medium \
-nodes=3
--nodes-min=2 \
--nodes-max=3\
--node-volume-size=20 \
eksctl create nodegroup --cluster=my-eks2 \
--region-ap-south-1 \
All
--name=node2 \
--node-type=t3.medium \
--nodes=3 \
-nodes-min=2
--nodes-max=3
--node-volume-size=20 \
--ssh-access \
-ssh-public-key=key123 \
--managed \
--asg-access \
--external-dns-access \
--full-ecr-access \
--appmesh-access \
--alb-ingress-access





# creatinf service account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: webapps


#create role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: webapps
rules:
  - apiGroups:
    -""
    - apps
    - autoscaling
    - batch
    - extensions
    - policy
    - rbac.authorization.k8s.io
  resources:
    - pods
    - componentstatuses
    - configmaps
    - daemonsets
    - deployments
    - events
    - endpoints
    - horizontalpodautoscalers
    - ingress
    - jobs
    - limitranges
    - namespaces
    - nodes
    - pods
    - persistentvolumes
    - persistentvolumeclaims
    - resourcequotas
    - replicasets
    - replicationcontrollers
    - serviceaccounts
    - services
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]


# bind the role to service account
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-rolebinding
  namespace: webapps
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: app-role
subjects:
- namespace: webapps
  kind: ServiceAccount
  name: jenkins


# token generation
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: mysecretname
  annotations:
    kubernetes.io/service-account.name: jenkins



# pipeline

pipeline{
    agent any
    enviroment{
        SCANNER_HOME = tool'sonar-scanner'
    }
    satges{
        stage('Git checkout') {
            steps{
                git 
            }
        }
        stage('sonarqube') {
            steps{
                withSonarQubeEnv('sonar'){
                sh '''
                    $SCANNER_HOME/bin/sonar-scanner
                    -Dsonar.projectkey=10-Tier
                    -Dsonar.projectName=10-Tier
                    -Dsonar.java.binaries=.

                '''
                }
            }
        }
        stage('adservice') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/adservice/')
                    sh '''
                        docker build -t siba9439/adservice:latest .
                        docker push -t siba9439/adservice:latest
                        docker rmi -t siba9439/adservice:latest
                    '''
                }
            }
        }
        stage('cartservice') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/cartservice/src/')
                    sh '''
                        docker build -t siba9439/cartservice:latest .
                        docker push -t siba9439/cartservice:latest
                        docker rmi -t siba9439/cartservice:latest
                    '''
                }
            }
        }
        stage('checkoutservice') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/checkoutservice/')
                    sh '''
                        docker build -t siba9439/checkoutservice:latest .
                        docker push -t siba9439/checkoutservice:latest
                        docker rmi -t siba9439/checkoutservice:latest
                    '''
                }
            }
        }
        stage('currencyservice') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/currencyservice/')
                    sh '''
                        docker build -t siba9439/currencyservice:latest .
                        docker push -t siba9439/currencyservice:latest
                        docker rmi -t siba9439/currencyservice:latest
                    '''
                }
            }
        }
        stage('emailservice') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/emailservice/')
                    sh '''
                        docker build -t siba9439/emailservice:latest .
                        docker push -t siba9439/emailservice:latest
                        docker rmi -t siba9439/emailservice:latest
                    '''
                }
            }
        }
        stage('frontend') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/frontend/')
                    sh '''
                        docker build -t siba9439/frontend:latest .
                        docker push -t siba9439/frontend:latest
                        docker rmi -t siba9439/frontend:latest
                    '''
                }
            }
        }
        stage('loadgenerator') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/loadgenerator/')
                    sh '''
                        docker build -t siba9439/loadgenerator:latest .
                        docker push -t siba9439/loadgenerator:latest
                        docker rmi -t siba9439/loadgenerator:latest
                    '''
                }
            }
        }
        stage('paymentservice') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/paymentservice/')
                    sh '''
                        docker build -t siba9439/paymentservice:latest .
                        docker push -t siba9439/paymentservice:latest
                        docker rmi -t siba9439/paymentservice:latest
                    '''
                }
            }
        }
        stage('productcatalogservice') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/productcatalogservice/')
                    sh '''
                        docker build -t siba9439/productcatalogservice:latest .
                        docker push -t siba9439/productcatalogservice:latest
                        docker rmi -t siba9439/productcatalogservice:latest
                    '''
                }
            }
        }
        stage('recommendationservice') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/recommendationservice/')
                    sh '''
                        docker build -t siba9439/recommendationservice:latest .
                        docker push -t siba9439/recommendationservice:latest
                        docker rmi -t siba9439/recommendationservice:latest
                    '''
                }
            }
        }
        stage('shippingservice') {
            steps{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker'){
                    dir('/var/lib/jenkins/workspace/10-tier/src/shippingservice/')
                    sh '''
                        docker build -t siba9439/shippingservice:latest .
                        docker push -t siba9439/shippingservice:latest
                        docker rmi -t siba9439/shippingservice:latest
                    '''
                }
            }
        }
    }
}
    

    
