pipeline {
  agent any
  tools {
  
  maven 'MAVEN'
   
  }
    stages {

      stage ('Checkout SCM'){
        steps {
          checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://oluseye00@bitbucket.org/oluseye00/testing.git']]])
        }
      }
	  
	  stage ('Build')  {
	      steps {
            dir('webapp'){
            sh "pwd"
            sh "ls -lah"
            sh "mvn package"
          }
        }
         
      }
   

    stage ('Artifactory configuration') {
            steps {
                rtServer (
                    id: "jfrog",
                    url: "http://54.221.70.105:8082/artifactory",
                    credentialsId: "jfrog"
                )

                rtMavenDeployer (
                    id: "MAVEN_DEPLOYER",
                    serverId: "jfrog",
                    releaseRepo: "iternus-libs-release-local",
                    snapshotRepo: "iternus-libs-snapshot-local"
                )

                rtMavenResolver (
                    id: "MAVEN_RESOLVER",
                    serverId: "jfrog",
                    releaseRepo: "iternus-libs-release",
                    snapshotRepo: "iternus-libs-snapshot"
                )
            }
    }

    stage ('Deploy Artifacts') {
            steps {
                rtMavenRun (
                    tool: "MAVEN", // Tool name from Jenkins configuration
                    pom: 'webapp/pom.xml',
                    goals: 'clean install',
                    deployerId: "MAVEN_DEPLOYER",
                    resolverId: "MAVEN_RESOLVER"
                )
         }
    }

    stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "jfrog"
             )
        }
    }

    stage('Copy Dockerfile & Playbook to Ansible Server') {
            
            steps {
                  sshagent(['ssh_agent']) {
                       sh "chmod 400  SeyeKY.pem"
                       sh "ls -lah"
                        sh "scp -i SeyeKY.pem -o StrictHostKeyChecking=no Dockerfile ubuntu@44.196.112.15:/home/ubuntu"
                        sh "scp -i SeyeKY.pem -o StrictHostKeyChecking=no dockerfile ubuntu@44.196.112.15:/home/ubuntu"
                        sh "scp -i SeyeKY.pem -o StrictHostKeyChecking=no deploy-dockerhub.yaml ubuntu@44.196.112.15:/home/ubuntu"
                    }
                }
            
        } 

    stage('Build Container Image') {
            
            steps {
                  sshagent(['ssh_key']) {
                        sh "ssh -i SeyeKY.pem -o StrictHostKeyChecking=no ubuntu@44.196.112.15 -C \"ansible-playbook  -vvv -e build_number=${BUILD_NUMBER} deploy-dockerhub.yaml\""
                        
                    }
                }
            
        } 

    stage('Copy Deployment & Service Defination to K8s Master') {
            
            steps {
                  sshagent(['ssh_key']) {
                        sh "scp -i SeyeKY.pem -o StrictHostKeyChecking=no deploy.yaml ubuntu@52.2.195.204:/home/ubuntu"
                        sh "scp -i SeyeKY.pem -o StrictHostKeyChecking=no service.yaml ubuntu@52.2.195.204:/home/ubuntu"
                    }
                }
            
        } 

    stage('Waiting for Approvals') {
            
        steps{

				input('Test Completed ? Please provide  Approvals for Prod Release ?')
			  }
            
    }     
    stage('Deploy Artifacts to Production') {
            
            steps {
                  sshagent(['ssh_key']) {
                        sh "ssh -i SeyeKY.pem -o StrictHostKeyChecking=no ubuntu@52.2.195.204 -C \"kubectl set image deployment/itern-deploy iterncon=oluseye00/lab:${BUILD_NUMBER}\""
                       //sh "ssh -i SeyeKY.pem -o StrictHostKeyChecking=no ubuntu@52.2.195.204 -C \"kubectl delete pod itern-deploy\""
                        sh "ssh -i SeyeKY.pem -o StrictHostKeyChecking=no ubuntu@52.2.195.204 -C \"kubectl apply -f deploy.yaml\""
                        sh "ssh -i SeyeKY.pem -o StrictHostKeyChecking=no ubuntu@52.2.195.204 -C \"kubectl apply -f service.yaml\""
                        
                    }
                }
            
        } 
         
   } 
}


