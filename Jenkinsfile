pipeline {
    agent any
    options {
        timestamps()
        disableConcurrentBuilds()
    }
    parameters {
        booleanParam(
            name: 'RUN_SONAR',
            defaultValue: true,
            description: 'Run SonarQube analysis for each service (requires Sonar server + token).'
        )
        booleanParam(
            name: 'RUN_DOCKER_SMOKE',
            defaultValue: false,
            description: 'Bring up the docker-compose stack for a smoke test (requires Docker on the agent).'
        )
        booleanParam(
            name: 'RUN_HELM_DEPLOY',
            defaultValue: false,
            description: 'Deploy services to the current kube-context using Helm charts.'
        )
    }
    environment {
        GITHUB_CREDS_ID = 'github-pat'
        CATALOG_REPO   = 'https://github.com/rrajo-portfolio/catalog-service.git'
        USERS_REPO     = 'https://github.com/rrajo-portfolio/users-service.git'
        ORDERS_REPO    = 'https://github.com/rrajo-portfolio/orders-service.git'
        GATEWAY_REPO   = 'https://github.com/rrajo-portfolio/gateway-service.git'
        NOTIFICATION_REPO = 'https://github.com/rrajo-portfolio/notification-service.git'
        MVN_TEST_CMD   = './mvnw -B test'
        SONAR_CMD      = './mvnw -B sonar:sonar'
        IMAGE_NAMESPACE = 'rrajo-portfolio'
    }
    stages {
        stage('Checkout infra-dev') {
            steps {
                checkout scm
            }
        }
        stage('Checkout services') {
            parallel {
                stage('catalog-service repo') {
                    steps {
                        dir('catalog-service') {
                            git branch: 'main', credentialsId: env.GITHUB_CREDS_ID, url: env.CATALOG_REPO
                        }
                    }
                }
                stage('users-service repo') {
                    steps {
                        dir('users-service') {
                            git branch: 'main', credentialsId: env.GITHUB_CREDS_ID, url: env.USERS_REPO
                        }
                    }
                }
                stage('orders-service repo') {
                    steps {
                        dir('orders-service') {
                            git branch: 'main', credentialsId: env.GITHUB_CREDS_ID, url: env.ORDERS_REPO
                        }
                    }
                }
                stage('gateway-service repo') {
                    steps {
                        dir('gateway-service') {
                            git branch: 'main', credentialsId: env.GITHUB_CREDS_ID, url: env.GATEWAY_REPO
                        }
                    }
                }
                stage('notification-service repo') {
                    steps {
                        dir('notification-service') {
                            git branch: 'main', credentialsId: env.GITHUB_CREDS_ID, url: env.NOTIFICATION_REPO
                        }
                    }
                }
            }
        }
        stage('Warmup mvnw') {
            steps {
                script {
                    ['catalog-service', 'users-service', 'orders-service', 'gateway-service', 'notification-service'].each { svc ->
                        dir(svc) {
                            sh 'chmod +x mvnw'
                            sh './mvnw -B -q --version'
                        }
                    }
                }
            }
        }
        stage('Unit tests') {
            parallel {
                stage('catalog-service tests') {
                    steps {
                        dir('catalog-service') {
                            sh 'chmod +x mvnw'
                            sh env.MVN_TEST_CMD
                        }
                    }
                }
                stage('users-service tests') {
                    steps {
                        dir('users-service') {
                            sh 'chmod +x mvnw'
                            sh env.MVN_TEST_CMD
                        }
                    }
                }
                stage('orders-service tests') {
                    steps {
                        dir('orders-service') {
                            sh 'chmod +x mvnw'
                            sh env.MVN_TEST_CMD
                        }
                    }
                }
                stage('gateway-service tests') {
                    steps {
                        dir('gateway-service') {
                            sh 'chmod +x mvnw'
                            sh env.MVN_TEST_CMD
                        }
                    }
                }
                stage('notification-service tests') {
                    steps {
                        dir('notification-service') {
                            sh 'chmod +x mvnw'
                            sh env.MVN_TEST_CMD
                        }
                    }
                }
            }
        }
        stage('SonarQube analysis') {
            when {
                expression { return params.RUN_SONAR }
            }
            steps {
                script {
                    parallel(
                        'catalog-service sonar': {
                            dir('catalog-service') {
                                sh 'chmod +x mvnw'
                                withSonarQubeEnv('sonarqube') {
                                    sh """
                                        ./mvnw -B sonar:sonar \\
                                          -Dsonar.projectKey=catalog-service \\
                                          -Dsonar.projectName=catalog-service \\
                                          -Dsonar.host.url=$SONAR_HOST_URL \\
                                          -Dsonar.login=$SONAR_AUTH_TOKEN
                                    """
                                }
                            }
                        },
                        'users-service sonar': {
                            dir('users-service') {
                                sh 'chmod +x mvnw'
                                withSonarQubeEnv('sonarqube') {
                                    sh """
                                        ./mvnw -B sonar:sonar \\
                                          -Dsonar.projectKey=users-service \\
                                          -Dsonar.projectName=users-service \\
                                          -Dsonar.host.url=$SONAR_HOST_URL \\
                                          -Dsonar.login=$SONAR_AUTH_TOKEN
                                    """
                                }
                            }
                        },
                        'orders-service sonar': {
                            dir('orders-service') {
                                sh 'chmod +x mvnw'
                                withSonarQubeEnv('sonarqube') {
                                    sh """
                                        ./mvnw -B sonar:sonar \\
                                          -Dsonar.projectKey=orders-service \\
                                          -Dsonar.projectName=orders-service \\
                                          -Dsonar.host.url=$SONAR_HOST_URL \\
                                          -Dsonar.login=$SONAR_AUTH_TOKEN
                                    """
                                }
                            }
                        },
                        'gateway-service sonar': {
                            dir('gateway-service') {
                                sh 'chmod +x mvnw'
                                withSonarQubeEnv('sonarqube') {
                                    sh """
                                        ./mvnw -B sonar:sonar \\
                                          -Dsonar.projectKey=gateway-service \\
                                          -Dsonar.projectName=gateway-service \\
                                          -Dsonar.host.url=$SONAR_HOST_URL \\
                                          -Dsonar.login=$SONAR_AUTH_TOKEN
                                    """
                                }
                            }
                        },
                        'notification-service sonar': {
                            dir('notification-service') {
                                sh 'chmod +x mvnw'
                                withSonarQubeEnv('sonarqube') {
                                    sh """
                                        ./mvnw -B sonar:sonar \\
                                          -Dsonar.projectKey=notification-service \\
                                          -Dsonar.projectName=notification-service \\
                                          -Dsonar.host.url=$SONAR_HOST_URL \\
                                          -Dsonar.login=$SONAR_AUTH_TOKEN
                                    """
                                }
                            }
                        }
                    )
                }
            }
        }
        stage('Sonar Quality Gate') {
            when {
                expression { return params.RUN_SONAR }
            }
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('docker-compose smoke test') {
            when {
                expression { return params.RUN_DOCKER_SMOKE }
            }
            steps {
                script {
                    def composeFile = "${env.WORKSPACE}/docker-compose.yml"
                    withEnv([
                        "SERVICES_ROOT=.",
                        "COMPOSE_PROJECT_NAME=portfolio",
                        "CONTAINER_PREFIX=ci-",
                        "CATALOG_DB_PORT=13307",
                        "USERS_DB_PORT=13308",
                        "ORDERS_DB_PORT=13309",
                        "MAILHOG_HTTP_PORT=18025",
                        "MAILHOG_SMTP_PORT=11025",
                        "ELASTIC_HTTP_PORT=19200",
                        "KIBANA_HTTP_PORT=15601",
                        "ZOOKEEPER_PORT=22181",
                        "KAFKA_PORT=19094",
                        "KEYCLOAK_HTTP_PORT=17080",
                        "NGINX_HTTP_PORT=18080",
                        "GATEWAY_HTTP_PORT=18085",
                        "SONAR_HTTP_PORT=19000",
                        "JENKINS_HTTP_PORT=18090",
                        "JENKINS_AGENT_PORT=25000",
                        "ADMINER_HTTP_PORT=18088",
                        "RABBITMQ_AMQP_PORT=25672",
                        "RABBITMQ_HTTP_PORT=35672",
                        "NGINX_BUILD_CONTEXT=${env.WORKSPACE}/nginx"
                    ]) {
                        try {
                            sh "docker compose -f ${composeFile} down --remove-orphans || true"
                            sh "docker compose -f ${composeFile} up -d --build"
                            sh """
                                ATTEMPTS=0
                                until docker compose -f ${composeFile} exec -T kafka kafka-topics --bootstrap-server kafka:9092 --list >/dev/null 2>&1; do
                                    ATTEMPTS=\$((ATTEMPTS+1))
                                    if [ \$ATTEMPTS -ge 30 ]; then
                                        echo "Kafka broker did not become ready in time"
                                        exit 1
                                    fi
                                    echo "Kafka not ready yet, retrying..."
                                    sleep 5
                                done
                            """
                            sh "docker compose -f ${composeFile} exec -T kafka kafka-topics --bootstrap-server kafka:9092 --create --if-not-exists --topic catalog-product-events --partitions 1 --replication-factor 1"
                            sh "docker compose -f ${composeFile} exec -T kafka kafka-topics --bootstrap-server kafka:9092 --describe --topic catalog-product-events"
                            sh """
                                docker compose -f ${composeFile} exec -T gateway_service curl -sf http://localhost:8080/actuator/health
                                docker compose -f ${composeFile} exec -T notification_service curl -sf http://localhost:8080/actuator/health
                            """
                        } finally {
                            sh "docker compose -f ${composeFile} down --remove-orphans || true"
                        }
                    }
                }
            }
        }
        stage('Docker build & tag') {
            steps {
                script {
                    parallel(
                        'catalog image': {
                            dir('catalog-service') {
                                sh "docker build -t ${env.IMAGE_NAMESPACE}/catalog-service:${env.BUILD_NUMBER} ."
                            }
                        },
                        'users image': {
                            dir('users-service') {
                                sh "docker build -t ${env.IMAGE_NAMESPACE}/users-service:${env.BUILD_NUMBER} ."
                            }
                        },
                        'orders image': {
                            dir('orders-service') {
                                sh "docker build -t ${env.IMAGE_NAMESPACE}/orders-service:${env.BUILD_NUMBER} ."
                            }
                        },
                        'gateway image': {
                            dir('gateway-service') {
                                sh "docker build -t ${env.IMAGE_NAMESPACE}/gateway-service:${env.BUILD_NUMBER} ."
                            }
                        },
                        'notification image': {
                            dir('notification-service') {
                                sh "docker build -t ${env.IMAGE_NAMESPACE}/notification-service:${env.BUILD_NUMBER} ."
                            }
                        }
                    )
                }
            }
        }
        stage('Helm deploy') {
            when {
                expression { return params.RUN_HELM_DEPLOY }
            }
            steps {
                dir('helm') {
                    sh """
                        helm dependency update ./portfolio-stack
                        helm upgrade --install portfolio-infra ./portfolio-infra
                        helm upgrade --install catalog-service catalog-service \\
                          --set image.repository=${env.IMAGE_NAMESPACE}/catalog-service \\
                          --set image.tag=${env.BUILD_NUMBER}
                        helm upgrade --install users-service users-service \\
                          --set image.repository=${env.IMAGE_NAMESPACE}/users-service \\
                          --set image.tag=${env.BUILD_NUMBER}
                        helm upgrade --install orders-service orders-service \\
                          --set image.repository=${env.IMAGE_NAMESPACE}/orders-service \\
                          --set image.tag=${env.BUILD_NUMBER}
                        helm upgrade --install gateway-service gateway-service \\
                          --set image.repository=${env.IMAGE_NAMESPACE}/gateway-service \\
                          --set image.tag=${env.BUILD_NUMBER}
                        helm upgrade --install notification-service notification-service \\
                          --set image.repository=${env.IMAGE_NAMESPACE}/notification-service \\
                          --set image.tag=${env.BUILD_NUMBER}
                    """
                }
            }
        }
    }
    post {
        always {
            junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
            archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
        }
    }
}


