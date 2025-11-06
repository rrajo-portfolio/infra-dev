pipeline {
    agent any
    options {
        timestamps()
        disableConcurrentBuilds()
    }
    parameters {
        booleanParam(
            name: 'RUN_SONAR',
            defaultValue: false,
            description: 'Enabling this flag runs SonarQube analysis for each service (requires Sonar server + token).'
        )
        booleanParam(
            name: 'RUN_DOCKER_SMOKE',
            defaultValue: false,
            description: 'Bring up the docker-compose stack for a smoke test (requires Docker on the agent).'
        )
    }
    environment {
        GITHUB_CREDS_ID = 'github-pat'
        CATALOG_REPO   = 'https://github.com/rrajo-portfolio/catalog-service.git'
        USERS_REPO     = 'https://github.com/rrajo-portfolio/users-service.git'
        ORDERS_REPO    = 'https://github.com/rrajo-portfolio/orders-service.git'
        MVN_TEST_CMD   = './mvnw -B test'
        SONAR_CMD      = './mvnw -B sonar:sonar'
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
            }
        }
        stage('Unit tests') {
            parallel {
                stage('catalog-service tests') {
                    steps {
                        dir('catalog-service') {
                            sh env.MVN_TEST_CMD
                        }
                    }
                }
                stage('users-service tests') {
                    steps {
                        dir('users-service') {
                            sh env.MVN_TEST_CMD
                        }
                    }
                }
                stage('orders-service tests') {
                    steps {
                        dir('orders-service') {
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
                                withSonarQubeEnv('sonarqube') {
                                    sh env.SONAR_CMD
                                }
                            }
                        },
                        'users-service sonar': {
                            dir('users-service') {
                                withSonarQubeEnv('sonarqube') {
                                    sh env.SONAR_CMD
                                }
                            }
                        },
                        'orders-service sonar': {
                            dir('orders-service') {
                                withSonarQubeEnv('sonarqube') {
                                    sh env.SONAR_CMD
                                }
                            }
                        }
                    )
                }
            }
        }
        stage('docker-compose smoke test') {
            when {
                expression { return params.RUN_DOCKER_SMOKE }
            }
            steps {
                dir(env.WORKSPACE) {
                    sh 'docker compose -f infra-dev/docker-compose.yml down --remove-orphans || true'
                    sh 'docker compose -f infra-dev/docker-compose.yml up -d --build'
                    sh '''
                        docker compose -f infra-dev/docker-compose.yml exec -T kafka /opt/bitnami/kafka/bin/kafka-topics.sh \\
                          --bootstrap-server localhost:9092 \\
                          --create --if-not-exists --topic catalog-product-events --partitions 1 --replication-factor 1
                        docker compose -f infra-dev/docker-compose.yml exec -T kafka /opt/bitnami/kafka/bin/kafka-topics.sh \\
                          --bootstrap-server localhost:9092 --describe --topic catalog-product-events
                    '''
                }
            }
        }
    }
    post {
        always {
            script {
                sh 'docker compose -f infra-dev/docker-compose.yml down --remove-orphans || true'
            }
            junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
            archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
        }
    }
}
