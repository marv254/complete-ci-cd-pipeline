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

        stage('Build Image') {
            steps {
                script {
                    buildImage("${DOCKER_REPO}:$IMAGE_NAME")
                }
            }
        }

        stage('Deploy image to private repo'){
            steps {
                script {
                    dockerLogin()
                  
                    dockerPush("${DOCKER_REPO}:$IMAGE_NAME")
                }
            }
        }

        stage("Deploy Image to EC2 Instance") {
            steps {
                script {
                    echo "Deploying to ec2 Instance ..."
                    def APP_URL = "${DOCKER_REPO}:${IMAGE_NAME}"
                    def ec2Instance = "ec2-user@13.246.20.124"
                    def shellCmd = "bash entry-script.sh ${APP_URL}"
            
                    sshagent(['ec2-webserver']) {
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                    sh "scp -o StrictHostKeyChecking=no entry-script.sh ${ec2Instance}:/home/ec2-user"

                    sh "ssh -o StrictHostKeyChecking=no  ${ec2Instance} ${shellCmd}"
                    echo "Checking if docker app is up & running"
                    sh "docker ps"
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
                        sh "git push https://${USER}:${PASS}@github.com/${USER}/complete-ci-cd-pipeline.git"
                    }
                }
            }
        }

    }
}



