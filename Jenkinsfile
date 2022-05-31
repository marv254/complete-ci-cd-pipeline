library identifier: 'jenkins-shared-library@master', retriever: modernSCM(
        [$class: 'GitSCMSource',
         remote: 'https://gitlab.com/Marv254/jenkins-shared-library.git',
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
                    dockerLogin()
                }
            }
        }

        stage('Deploy image to private repo'){
            steps {
                script {
                  
                    deployApp("${DOCKER_REPO}:$IMAGE_NAME")
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
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml"
                    sh "scp -o StrictHostKeyChecking=no entry-script.sh"

                    sh "ssh -o StrictHostKeyChecking=no  ${ec2-Instance} ${shellCmd}"
                    echo "Checking if docker app is up & running"
                    sh "docker ps"
                }
            }
        }}

        stage("Version Increment"){
            steps {
                script {
                    echo  "Incrementing Version in pom.xml..."
                    withCredentials([usernamePassword (credentialsId: 'github-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]){
                        sh "git config --global user.name 'jenkins' "
                        sh "git config --global user.email 'jenkins@gmail.com' "
                        sh "git remote seturl origin https://${USER}:${PASS}@gitlab.com/marv254/java-maven-app.git"
                        sh "git add . "
                        sh "git commit -m 'commit CI version bump of pom.xml file'"
                        sh "git push -u origin jenkins-jobs"
                    }
                }
            }
        }

    }
}



