/*
 * SonarQube pipeline stages extracted from the complete Jenkins pipeline.
 * This file represents the SonarQube integration contributed to the
 * NexGuard-SecureFlow DevSecOps project.
 */

// SonarQube Configuration

environment {
    SCANNER_HOME = tool('SonarScanner')
    SONAR_URL = "http://<EC2-PUBLIC-IP>:9000"
}


// SonarQube Analysis Stage

stage('SonarQube Analysis') {

    steps {

        dir('frontend') {

            withSonarQubeEnv('SonarQube-Server') {

                sh """

                ${SCANNER_HOME}/bin/sonar-scanner \
                -Dsonar.projectKey=NexGuard-SecureFlow \
                -Dsonar.projectName=NexGuard-SecureFlow \
                -Dsonar.sources=src \
                -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info

                """

            }
        }
    }
}



// Quality Gate Verification

stage('Quality Gate') {

    steps {

        timeout(time: 5, unit: 'MINUTES') {

            script {

                def qg = waitForQualityGate()

                echo "Quality Gate Status: ${qg.status}"

                if (qg.status != 'OK') {
                    echo "Quality Gate Failed, continuing pipeline..."
                }

            }
        }
    }
}


