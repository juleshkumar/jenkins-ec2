pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
        string(name: 'instance_sg_name', defaultValue: 'ec2-sg', description: 'sg name')
        string(name: 'vpc_id', defaultValue: 'vpc-id', description: 'vpc id')
        string(name: 'ami', defaultValue: 'ami-1234', description: 'ami here')
        string(name: 'instance_type', defaultValue: 't2.micro', description: 'instance type')
        string(name: 'subnet_id', defaultValue: 'sub-1234', description: 'subnet id')
        string(name: 'key_pair', defaultValue: 'keyparir', description: 'key pair ')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/juleshkumar/jenkins-ec2.git'
            }
        }
        stage('Terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Plan') {
            steps {
                sh "terraform plan -out tfplan \
                        -var 'instance_sg_name=${params.instance_sg_name}' \
                        -var 'vpc_id=${params.vpc_id}' \
                        -var 'ami=${params.ami}' \
                        -var 'instance_type=${params.instance_type}' \
                        -var 'subnet_id=${params.subnet_id}' \
                        -var 'key_pair=${params.key_pair}'"
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }
        
        stage('Apply / Destroy') {
            steps {
                script {
                    if (params.action == 'apply') {
                        if (!params.autoApprove) {
                            def plan = readFile 'tfplan.txt'
                            input message: "Do you want to apply the plan?",
                            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                        }

                        sh "terraform ${params.action} -input=false tfplan"
                    } else if (params.action == 'destroy') {
                        sh "terraform ${params.action} --auto-approve \
                                -var 'instance_sg_name=${params.instance_sg_name}' \
                                -var 'vpc_id=${params.vpc_id}' \
                                -var 'ami=${params.ami}' \
                                -var 'instance_type=${params.instance_type}' \
                                -var 'subnet_id=${params.subnet_id}' \
                                -var 'key_pair=${params.key_pair}'"
                    } else {
                        error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                    }
                }
            }
        }
    }
}
