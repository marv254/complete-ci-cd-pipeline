library identifier: 'jenkins-shared-library@master', retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://github.com/marv254/jenkins-shared-library',
     credentialsId: 'github-creds'
    ]
)


pipeline {
    agent any

    tools{
        maven "maven3.8.5"
    }
  
    stages{
        stage("Increment Version"){
            steps{
                script{
                    sh "mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit"
                    def matcher = readFile('pom.xml') =~ "<version>(.+)</version>"
                    def version = matcher[0][1]
                    env.IMAGE_NAME="$version-$BUILD_NUMBER"
                }
            }
        }


        stage("Build Jar File"){
            steps{
                script{
                    buildJar()
                }
            }
        }

       stage("Build Image"){
            steps{
                script{
                    buildImage($IMAGE_NAME)
                }
            }
        }

       stage("Deploy Image to Dockerhub"){
            steps{
                script{
                    dockerLogin()
                    dockerPush($IMAGE_NAME)

                }
            }
        }

       stage("Deploy Image to EC2 Instance..."){
            steps{
                script{
                    echo "Will deploy EC2 instance..."

                }
            }
        }

       stage("Increment Version"){
            steps{
                script{
                    echo  "will increment Version.."
                }
            }
        }




    }

}