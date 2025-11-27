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
        SONAR_CREDENTIALS_ID = 'jenkins-sonar'
        SONAR_HOST_URL = 'http://sonarqube:9000'
        SONAR_SERVER = 'sonarqube'
        CATALOG_REPO   = 'https://github.com/rrajo-portfolio/catalog-service.git'
        USERS_REPO     = 'https://github.com/rrajo-portfolio/users-service.git'
        ORDERS_REPO    = 'https://github.com/rrajo-portfolio/orders-service.git'
        GATEWAY_REPO   = 'https://github.com/rrajo-portfolio/gateway-service.git'
        NOTIFICATION_REPO = 'https://github.com/rrajo-portfolio/notification-service.git'
        FRONTEND_REPO  = 'https://github.com/rrajo-portfolio/frontend-service.git'
        MVN_TEST_CMD   = './mvnw -B test'
        SONAR_CMD      = './mvnw -B org.sonarsource.scanner.maven:sonar-maven-plugin:3.10.0.2594:sonar'
        IMAGE_NAMESPACE = 'rrajo-portfolio'
        MAVEN_OPTS = '-Xmx1024m -XX:TieredStopAtLevel=1'
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
                stage('frontend-service repo') {
                    steps {
                        dir('frontend-service') {
                            git branch: 'main', credentialsId: env.GITHUB_CREDS_ID, url: env.FRONTEND_REPO
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
        stage('Frontend build') {
            steps {
                dir('frontend-service') {
                    sh '''
                        if [ ! -f package-lock.json ]; then
                            echo "package-lock.json not found. Generating one with npm install --package-lock-only"
                            npm install --package-lock-only
                        fi
                        npm ci
                    '''
                    sh 'npm run build -- --configuration production'
                }
            }
        }
        stage('SonarQube analysis') {
            when {
                expression { return params.RUN_SONAR }
            }
            steps {
                script {
                    if (!env.SONAR_CREDENTIALS_ID?.trim()) {
                        error 'SONAR_CREDENTIALS_ID is not configured. Please set a Jenkins secret text credential id.'
                    }
                    if (!env.SONAR_HOST_URL?.trim()) {
                        error 'SONAR_HOST_URL is not configured. Please set the SonarQube server URL.'
                    }
                    withCredentials([string(credentialsId: env.SONAR_CREDENTIALS_ID, variable: 'SONAR_TOKEN')]) {
                        withSonarQubeEnv(env.SONAR_SERVER) {
                            parallel(
                            'catalog-service sonar': {
                                dir('catalog-service') {
                                    sh 'chmod +x mvnw'
                                    sh """
                                        $SONAR_CMD \
                                          -Dsonar.projectKey=catalog-service \
                                          -Dsonar.projectName=catalog-service \
                                          -Dsonar.host.url=\\${env.SONAR_HOST_URL} \
                                          -Dsonar.login=\\$SONAR_TOKEN
                                    """
                                }
                            },
                            'users-service sonar': {
                                dir('users-service') {
                                    sh 'chmod +x mvnw'
                                    sh """
                                        $SONAR_CMD \
                                          -Dsonar.projectKey=users-service \
                                          -Dsonar.projectName=users-service \
                                          -Dsonar.host.url=\\${env.SONAR_HOST_URL} \
                                          -Dsonar.login=\\$SONAR_TOKEN
                                    """
                                }
                            },
                            'orders-service sonar': {
                                dir('orders-service') {
                                    sh 'chmod +x mvnw'
                                    sh """
                                        $SONAR_CMD \
                                          -Dsonar.projectKey=orders-service \
                                          -Dsonar.projectName=orders-service \
                                          -Dsonar.host.url=\\${env.SONAR_HOST_URL} \
                                          -Dsonar.login=\\$SONAR_TOKEN
                                    """
                                }
                            },
                            'gateway-service sonar': {
                                dir('gateway-service') {
                                    sh 'chmod +x mvnw'
                                    sh """
                                        $SONAR_CMD \
                                          -Dsonar.projectKey=gateway-service \
                                          -Dsonar.projectName=gateway-service \
                                          -Dsonar.host.url=\\${env.SONAR_HOST_URL} \
                                          -Dsonar.login=\\$SONAR_TOKEN
                                    """
                                }
                            },
                            'notification-service sonar': {
                                dir('notification-service') {
                                    sh 'chmod +x mvnw'
                                    sh """
                                        $SONAR_CMD \
                                          -Dsonar.projectKey=notification-service \
                                          -Dsonar.projectName=notification-service \
                                          -Dsonar.host.url=\\${env.SONAR_HOST_URL} \
                                          -Dsonar.login=\\$SONAR_TOKEN
                                    """
                                }
                            }
                            )
                        }
                    }
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
                    def repoRoot = env.WORKSPACE
                    def servicesRootEnv = '.'
                    if (!fileExists("${repoRoot}/docker-compose.yml") && fileExists("${repoRoot}/infra-dev/docker-compose.yml")) {
                        repoRoot = "${env.WORKSPACE}/infra-dev"
                        servicesRootEnv = '..'
                    }
                    def composeFile = "${repoRoot}/docker-compose.yml"
                    def scriptsDir = "${repoRoot}/scripts"
                    def volumeNamespace = "ci"
                    sh "chmod +x ${scriptsDir}/wait-for-service.sh"
                    withEnv([
                        "SERVICES_ROOT=${servicesRootEnv}",
                        "COMPOSE_PROJECT_NAME=portfolio",
                        "CONTAINER_PREFIX=ci-",
                        "VOLUME_NAMESPACE=${volumeNamespace}",
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
                        "NOTIFICATION_HTTP_PORT=18086",
                        "SONAR_HTTP_PORT=19000",
                        "JENKINS_HTTP_PORT=18090",
                        "JENKINS_AGENT_PORT=25000",
                        "FRONTEND_HTTP_PORT=18081",
                        "FRONTEND_API_URL=http://host.docker.internal:18085",
                        "FRONTEND_KEYCLOAK_URL=http://host.docker.internal:17080/auth",
                        "ADMINER_HTTP_PORT=18088",
                        "RABBITMQ_AMQP_PORT=25672",
                        "RABBITMQ_HTTP_PORT=35672",
                        "NGINX_BUILD_CONTEXT=${repoRoot}/nginx"
                    ]) {
                        try {
                            sh "docker compose -f ${composeFile} down --remove-orphans || true"
                            sh "docker rm -f ci-keycloak ci-keycloak_db || true"
                            sh "docker volume rm ${volumeNamespace}_kafka-data || true"
                            sh "docker compose -f ${composeFile} up -d --build"
                            sh "${scriptsDir}/wait-for-service.sh ${composeFile} kafka 30 kafka-topics --bootstrap-server localhost:9092 --list"
                            sh "docker compose -f ${composeFile} exec -T kafka kafka-topics --bootstrap-server localhost:9092 --create --if-not-exists --topic catalog-product-events --partitions 1 --replication-factor 1"
                            sh "docker compose -f ${composeFile} exec -T kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic catalog-product-events"
                            sh "${scriptsDir}/wait-for-service.sh ${composeFile} keycloak-db 30 pg_isready -h localhost -U keycloak"
                            sh "${scriptsDir}/wait-for-service.sh ${composeFile} host 0 curl -sf http://host.docker.internal:$KEYCLOAK_HTTP_PORT/auth/realms/portfolio/.well-known/openid-configuration"
                            sh "${scriptsDir}/wait-for-service.sh ${composeFile} host 40 curl -sf http://host.docker.internal:$GATEWAY_HTTP_PORT/actuator/health"
                            sh "${scriptsDir}/wait-for-service.sh ${composeFile} host 40 curl -sf http://host.docker.internal:$NOTIFICATION_HTTP_PORT/actuator/health"
                            sh "${scriptsDir}/wait-for-service.sh ${composeFile} host 40 curl -sf http://host.docker.internal:$FRONTEND_HTTP_PORT"
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
                                sh "docker build -t \\${env.IMAGE_NAMESPACE}/catalog-service:\\${env.BUILD_NUMBER} ."
                            }
                        },
                        'users image': {
                            dir('users-service') {
                                sh "docker build -t \\${env.IMAGE_NAMESPACE}/users-service:\\${env.BUILD_NUMBER} ."
                            }
                        },
                        'orders image': {
                            dir('orders-service') {
                                sh "docker build -t \\${env.IMAGE_NAMESPACE}/orders-service:\\${env.BUILD_NUMBER} ."
                            }
                        },
                        'gateway image': {
                            dir('gateway-service') {
                                sh "docker build -t \\${env.IMAGE_NAMESPACE}/gateway-service:\\${env.BUILD_NUMBER} ."
                            }
                        },
                        'notification image': {
                            dir('notification-service') {
                                sh "docker build -t \\${env.IMAGE_NAMESPACE}/notification-service:\\${env.BUILD_NUMBER} ."
                            }
                        },
                        'frontend image': {
                            dir('frontend-service') {
                                sh "docker build -t \\${env.IMAGE_NAMESPACE}/frontend-service:\\${env.BUILD_NUMBER} ."
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
                error 'Helm deploy is not supported in this Jenkins environment. Run the helm commands manually from a cluster-aware agent or shell.'
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



