pipeline {
  agent any

  parameters {
    booleanParam(name: 'AUTO_APPROVE', defaultValue: false, description: 'If true, terraform apply will run automatically')
    booleanParam(name: 'DESTROY', defaultValue: false, description: 'If true, terraform destroy will run instead of apply')
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
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh 'terraform init -input=false'
        }
      }
    }

    stage('Terraform Plan') {
      when {
        expression { return !params.DESTROY } // skip plan if destroying
      }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh 'terraform plan -out=tfplan -input=false'
          sh 'terraform show -no-color tfplan > plan.txt'
        }
        archiveArtifacts artifacts: 'plan.txt', allowEmptyArchive: false
      }
    }

    stage('Approval / Apply') {
      when {
        allOf {
          expression { return !params.DESTROY }
          anyOf {
            expression { return params.AUTO_APPROVE == true }
            expression { return params.AUTO_APPROVE == 'true' }
          }
        }
      }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh 'terraform apply -input=false -auto-approve tfplan'
        }
      }
    }

    stage('Manual Apply (if not auto)') {
      when {
        allOf {
          expression { return !params.DESTROY }
          expression { return params.AUTO_APPROVE == false }
        }
      }
      steps {
        input message: "Approve terraform apply?", ok: "Apply"
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh 'terraform apply -input=false -auto-approve tfplan'
        }
      }
    }

    stage('Terraform Destroy') {
      when {
        expression { return params.DESTROY }
      }
      steps {
        input message: "Are you sure you want to destroy all resources?", ok: "Destroy"
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh 'terraform destroy -auto-approve'
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
