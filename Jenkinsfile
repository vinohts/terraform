pipeline {
  agent any

  parameters {
    booleanParam(name: 'AUTO_APPROVE', defaultValue: false, description: 'If true, terraform apply will run automatically')
  }

  environment {
    TF_IN_AUTOMATION = "true"
    // optional: set TF_LOG=TRACE for debugging
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh 'terraform init -input=false'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh 'terraform plan -out=tfplan -input=false'
          sh 'terraform show -no-color tfplan > plan.txt'
        }
        archiveArtifacts artifacts: 'plan.txt', allowEmptyArchive: false
      }
    }

    stage('Approval / Apply') {
      when {
        anyOf {
          expression { return params.AUTO_APPROVE == true }
          expression { return params.AUTO_APPROVE == 'true' } // in case of string
        }
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh 'terraform apply -input=false -auto-approve tfplan'
        }
      }
    }

    stage('Manual Apply (if not auto)') {
      when {
        expression { return params.AUTO_APPROVE == false }
      }
      steps {
        input message: "Approve terraform apply?", ok: "Apply"
        withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh 'terraform apply -input=false -auto-approve tfplan'
        }
      }
    }
  }

  post {
    always {
      deleteDir()
    }
  }
}
