library identifier: 'jenkins-shared-library@master', retriever: modernSCM(
        [$class: 'GitSCMSource',
         remote: 'https://gitlab.com/Marv254/jenkins-shared-library',
         credentialsId: 'gitlab-creds'
        ]
)

pipeline {
    agent any

    tools {
        maven 'maven-3.8.5'
    }
    environment {

       DOCKER_REPO = "marv254/my-repo"
      
    }

    stages {

        stage('Increment Version') {
            environment {
                TF_VAR_env_prefix = "test"
            }
            steps {
                script {
                    sh "mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit"
                    def matcher = readFile('pom.xml') =~ "<version>(.+)</version>"
                    def version = matcher[0][1]
                    env.IMAGE_NAME="jma$version-$BUILD_NUMBER"
                }
            }
        }

        stage('Build Jar') {
            steps {
                script {
                    buildJar()
                }
            }
        }

        stage('Build & deploy Image to private repo') {
            steps {
                script {
                    buildImage("${DOCKER_REPO}:$IMAGE_NAME")
                    dockerLogin()
                  
                    dockerPush("${DOCKER_REPO}:$IMAGE_NAME")
                }
            }
        }

        stage('Provision server'){
            steps {
                script {
                    dir('terraform'){
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        sh "terraform output"
                        EC2_PUBLIC_IP = sh (
                            script: "terraform output ec2_public_ip"
                            returnStdout: true
                            ).trim()
                    }
                }
            }
        }

        stage("Deploy Image to EC2 Instance") {
            steps {
                script {
                    echo "waiting for Ec2 server to initialize.."
                    sleep(time: 90, unit: "SECONDS")

                    echo "Deploying docker image to ec2 Instance ..."
                    echo "${EC2_PUBLIC_IP}"

                    def APP_URL = "${DOCKER_REPO}:${IMAGE_NAME}"
                    def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"
                    def shellCmd = "bash entry-script.sh $APP_URL"
            
                    sshagent(['myapp-server-ssh-key']) {
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                    sh "scp -o StrictHostKeyChecking=no entry-script.sh ${ec2Instance}:/home/ec2-user"

                    sh "ssh -o StrictHostKeyChecking=no  ${ec2Instance} ${shellCmd}"
                
                }
            }
        }}

        stage("Version Increment"){
            steps {
                script {
                    echo  "Incrementing Version in pom.xml..."
                    withCredentials([usernamePassword (credentialsId: 'github-token', usernameVariable: 'USER', passwordVariable: 'PASS')]){
                        sh "git config --global user.name 'jenkins' "
                        sh "git config --global user.email 'jenkins@gmail.com' "
                        // sh "git remote add origin https://${USER}/complete-ci-cd-pipeline.git"
                        // sh "git remote set-url origin https://${USER}:${PASS}@github.com/marv254/complete-ci-cd-pipeline.git"
                        sh "git add . "
                        sh "git commit -m 'commit CI version bump of pom.xml file'"
                        sh "git push https://${USER}:${PASS}@github.com/${USER}/complete-ci-cd-pipeline.git HEAD:master"
                    }
                }
            }
        }

    }
}



