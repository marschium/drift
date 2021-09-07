pipeline {
    agent any
    stages {
        stage ('windows') {
            steps {
                dir("${env.WORKSPACE}") {
                    echo 'Building..'
                    sh 'godot --export \'Windows Desktop\' the_game.exe'
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'the_game.exe, the_game.pck', fingerprint: true
        }
    }
}
