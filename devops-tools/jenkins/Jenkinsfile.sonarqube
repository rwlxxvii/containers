pipeline {
    // ① Select a Jenkins slave with Docker capabilities
    agent {
        label 'docker'
    }

    environment {
        PRODUCT = 'ghcli'
        GIT_HOST = 'somewhere'
        GIT_REPO = 'repo'
    }

    options {
        ansiColor('xterm')
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        // ② Checkout the right branch
        stage('Checkout') {
            steps {
                script {
                    BRANCH_NAME = env.CHANGE_BRANCH ? env.CHANGE_BRANCH : env.BRANCH_NAME
                    deleteDir()
                    git url: "git@<host>:<org>/${env.PRODUCT}.git", branch: BRANCH_NAME
                }
            }
        }

	// ③ Build a container with the code source of the application
        stage('Build') {
            steps {
                sh "docker build . -t ${env.PRODUCT}:py"
            }
        }

	// ④ Run the test using the built docker image
        stage('Test') {
            steps {
                script {
                    sh "docker run --tty --name ${env.PRODUCT} ${env.PRODUCT}:py /usr/bin/make test"
                }
            }
        }

    	// ⑤ Analyse code quality using previous container as a Docker Container Volume
        stage('Quality') {
            steps {
                withCredentials([string(credentialsId: '<credentialsId>', variable: 'SONAR_LOGIN')]) {
                    script {
			// ⑥ Compute some arguments depending we are on main, branch or pull request.
                        if (env.CHANGE_ID) {
                            options = "-Dsonar.pullrequest.branch=${env.CHANGE_BRANCH} "
                            options += " -Dsonar.pullrequest.key=${env.CHANGE_ID} "
                            options += " -Dsonar.pullrequest.base=${env.CHANGE_TARGET}"
                        } else if (BRANCH_NAME == 'main') {
                            options = ''
                        } else {
                            options = "-Dsonar.branch.name=${BRANCH_NAME}"
                        }

			// ⑦ Mount the previous Docker Container as a Volume
		    	// to Sonar container to analyse the code
                        sh "docker run \
                            --rm \
                            -e SONAR_HOST_URL=https://<sonarHost> \
                            -e SONAR_LOGIN=${SONAR_LOGIN} \
                            --volumes-from ${env.PRODUCT} \
                            sonarsource/sonar-scanner-cli \
                            sonar-scanner ${options}"
                    }
                }
            }
        }
    }

	// ⑧ Cleanup
    post {
        always {
            script {
                sh "docker rm ${env.PRODUCT}"
            }
            deleteDir()
        }
    }
}
